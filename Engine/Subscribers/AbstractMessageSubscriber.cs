namespace CarrierLink.Controller.Engine.Subscribers
{
    using System;
    using System.Threading;
    using System.Threading.Tasks;
    using Caching;
    using Yate;
    using Yate.Messaging;

    /// <summary>
    /// This class is the base class for all receive-send subscribers
    /// </summary>
    internal abstract class AbstractMessageSubscriber : AbstractSubscriber, IManage
    {
        #region Fields

        /// <summary>
        /// Database Connection Object
        /// </summary>
        private Database.IDatabase database;

        /// <summary>
        /// Handles waiting for completed uninstallation
        /// </summary>
        private SemaphoreSlim waitForDeinstallation;

        /// <summary>
        /// Handles waiting for completed installation
        /// </summary>
        private SemaphoreSlim waitForInstallation;

        #endregion Fields

        #region Constructor

        /// <summary>
        /// Initializes a new instance of the <see cref="AbstractMessageSubscriber"/> class as handler
        /// </summary>
        /// <param name="node">Yate node information</param>
        /// <param name="type">Handler Type</param>
        /// <param name="priority">Handler priority in yates handler queue</param>
        internal AbstractMessageSubscriber(INode node, MessageType type, int priority)
            : base(node, type)
        {
            this.Priority = priority;
            this.SubscriptionType = SubscriberType.Handler;
            
            this.waitForInstallation = new SemaphoreSlim(initialCount: 0, maxCount: 1);
            this.waitForDeinstallation = new SemaphoreSlim(initialCount: 0, maxCount: 1);

            this.database = Pool.Database.Get();
        }

        /// <summary>
        /// Initializes a new instance of the <see cref="AbstractMessageSubscriber"/> class as watcher
        /// </summary>
        /// <param name="node">Yate node information</param>
        /// <param name="type">Handler Type</param>
        internal AbstractMessageSubscriber(INode node, MessageType type)
            : base(node, type)
        {
            this.Priority = 0;
            this.SubscriptionType = SubscriberType.Watcher;
            
            this.waitForInstallation = new SemaphoreSlim(initialCount: 0, maxCount: 1);
            this.waitForDeinstallation = new SemaphoreSlim(initialCount: 0, maxCount: 1);

            this.database = Caching.Pool.Database.Get();
        }

        #endregion Constructor

        #region Properties

        /// <summary>
        /// Gets handler priority
        /// </summary>
        internal int Priority { get; private set; }

        /// <summary>
        /// Gets subscriber type
        /// </summary>
        internal SubscriberType SubscriptionType { get; private set; }

        /// <summary>
        /// Gets handler type in Yate (technical)
        /// </summary>
        internal string YType
        {
            get
            {
                return Pool.MessageTypes.ToString(this.Type);
            }
        }

        #endregion Properties

        #region Methods

        /// <summary>
        /// Handles response from yate to application regarding installation/uninstallation of handlers
        /// </summary>
        /// <param name="message">Handles the incoming message</param>
        public void Manage(Message message)
        {
            int posOfSuccess;
            switch (this.SubscriptionType)
            {
                case SubscriberType.Handler:
                    posOfSuccess = 3;
                    break;

                case SubscriberType.Watcher:
                    posOfSuccess = 2;
                    break;

                default:
                    throw new NotImplementedException("Method not implemented for SubscriberType");
            }

            if (message.IncomingSplittedMessage[0].Substring(3) == Pool.SubscriberTypes.ToString(this.SubscriptionType) && message.IncomingSplittedMessage[posOfSuccess] == "true")
            {
                // find handler
                this.State = SubscriberState.Installed;

                logger.ConditionalDebug("Handler installation confirmed: " + Type.ToString());

                this.waitForInstallation.Release();
            }
            else if (message.IncomingSplittedMessage[0].Substring(3) == $"un{Pool.SubscriberTypes.ToString(SubscriptionType)}" && message.IncomingSplittedMessage[posOfSuccess] == "true")
            {
                if (this.State == SubscriberState.Deinstalled)
                {
                    logger.Debug("Handler skipped proper deinstallation");
                    return;
                }

                logger.Debug("Handler deinstallation confirmed");

                this.waitForDeinstallation.Release();
            }
        }

        /// <summary>
        /// Opens the connection and installs the handler
        /// </summary>
        /// <returns>Task to wait for until handler has started</returns>
        internal async Task StartAsync()
        {
            if (this.State == SubscriberState.DeinstallationRequested || this.State == SubscriberState.Deinstalled)
            {
                return;
            }

            this.Start();

            if (this.State == SubscriberState.ConnectingFailed)
            {
                return;
            }

            this.State = SubscriberState.Started;

            if (await this.InstallAsync())
            {
                this.State = SubscriberState.Running;
            }
        }

        /// <summary>
        /// Uninstalls the handler and closes the connection
        /// </summary>
        /// <returns>Task to wait for until handler has stopped</returns>
        internal async Task StopAsync()
        {
            await this.UninstallAsync();

            logger.Debug("Deinstallation confirmed, shutting down Connection: " + Type.ToString());

            this.Stop();

            Pool.Database.Put(this.database);

            this.State = SubscriberState.Deinstalled;

            logger.Debug("Handler stopped: " + Type.ToString());
        }

        /// <summary>
        /// Initiates installation of handler to receive yates messages
        /// </summary>
        /// <returns>Task to wait for installation to complete (true) or not (false)</returns>
        private async Task<bool> InstallAsync()
        {
            logger.Debug("Installing Handler: " + Type.ToString());

            this.State = SubscriberState.InstallationRequested;

            var message = new Message();
            if (this.Priority == 0)
            {
                message.SetOutgoing(this.Node, MessageDirection.OutgoingRequest, $"{Pool.SubscriberTypes.ToString(this.SubscriptionType)}:{this.YType}");
            }
            else
            {
                message.SetOutgoing(this.Node, MessageDirection.OutgoingRequest, $"{Pool.SubscriberTypes.ToString(this.SubscriptionType)}:{this.Priority}:{this.YType}");
            }
            this.Node.Send(message);

            // wait for 10 seconds before connection times out
            bool isInstalled = false;
            isInstalled = await this.waitForInstallation.WaitAsync(new TimeSpan(0, 0, 10));

            // Finish handler registration
            if (isInstalled)
            {
                logger.Debug("Installation confirmed, starting to read messages: " + Type.ToTechnicalName());

                return true;
            }
            else
            {
                logger.Debug("Installation failed: " + Type.ToTechnicalName());

                return false;
            }
        }

        /// <summary>
        /// Initiates uninstallation of handler, timeout is 11s (10s is yate message lifetime)
        /// </summary>
        /// <returns>Task to wait for until uninstallation has finished</returns>
        private async Task UninstallAsync()
        {
            logger.Debug("Deinstalling Handler: " + Type.ToString());

            this.State = SubscriberState.DeinstallationRequested;

            logger.Debug("Sending Deinstallation Message: " + Type.ToString());

            var message = new Message();
            message.SetOutgoing(this.Node, MessageDirection.OutgoingRequest, $"un{Pool.SubscriberTypes.ToString(this.SubscriptionType)}:{this.YType}");
            this.Node.Send(message);

            logger.Debug("Deinstallation Message Sent: " + Type.ToString());

            logger.Debug("Waiting for handler deinstallation confirmation: " + Type.ToString());
            await this.waitForDeinstallation.WaitAsync(new TimeSpan(0, 0, 10));
        }

        #endregion Methods
    }
}