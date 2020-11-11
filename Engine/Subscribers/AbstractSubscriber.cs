namespace CarrierLink.Controller.Engine.Subscribers
{
    using System;
    using System.Threading;
    using NLog;
    using Yate;
    using Yate.Messaging;

    /// <summary>
    /// This class is the base class for all subscribers
    /// </summary>
    internal abstract class AbstractSubscriber : IDisposable
    {
        #region Fields

        /// <summary>
        /// Handles cancellation of query, 10s timeout
        /// </summary>
        private CancellationTokenSource cancellationTokenSource;

        /// <summary>
        /// State of disposal
        /// </summary>
        private bool disposed;
        #endregion Fields

        #region Constructor

        /// <summary>
        /// Initializes a new instance of the <see cref="AbstractSubscriber"/> class
        /// </summary>
        /// <param name="node">Yate node information</param>
        /// <param name="type">Type of messages to subscribe</param>
        public AbstractSubscriber(INode node, MessageType type)
        {
            this.Id = Guid.NewGuid();
            this.Node = node;
            this.Type = type;

            logger = LogManager.GetLogger(GetType().FullName);

            this.disposed = false;
            this.cancellationTokenSource = new CancellationTokenSource(new TimeSpan(0,0,10));
        }

        #endregion Constructor

        #region Properties

        /// <summary>
        /// Gets or sets handler state
        /// </summary>
        public SubscriberState State { get; protected set; }

        /// <summary>
        /// Gets Yate node information
        /// </summary>
        public INode Node { get; private set; }

        /// <summary>
        /// Gets or sets handler id
        /// </summary>
        internal Guid Id { get; set; }

        /// <summary>
        /// Handler Type
        /// </summary>
        internal MessageType Type { get; private set; }

        /// <summary>
        /// Gets instance cancellation token, 10s timeout
        /// </summary>
        protected CancellationToken CancellationToken
        {
            get
            {
                return this.cancellationTokenSource.Token;
            }
        }

        /// <summary>
        /// Logger instance
        /// </summary>
        protected Logger logger { get; private set; }

        #endregion Properties

        #region Methods

        /// <summary>
        /// Continues message processing if <c>State</c> is paused, otherwise does nothing
        /// </summary>
        internal void Continue()
        {
            if (this.State == SubscriberState.Paused)
            {
                this.State = SubscriberState.Running;
            }
        }

        /// <summary>
        /// Pauses message processing if <c>State</c> is running, otherwise does nothing
        /// </summary>
        internal void Pause()
        {
            if (this.State == SubscriberState.Running)
            {
                this.State = SubscriberState.Paused;
            }
        }

        /// <summary>
        /// Starts the handler and opens a connection to yate
        /// </summary>
        internal void Start()
        {
            this.State = SubscriberState.Starting;
        }

        /// <summary>
        /// Stops subscription and closes connection to yate
        /// </summary>
        internal void Stop()
        {
            this.cancellationTokenSource.Cancel();

            this.State = SubscriberState.Stopping;
        }
        #endregion Methods

        #region Disposing

        /// <summary>
        /// Finalizes an instance of the <see cref="AbstractSubscriber"/> class
        /// </summary>
        ~AbstractSubscriber()
        {
            this.Dispose(false);
        }

        public void Dispose()
        {
            this.Dispose(true);
            GC.SuppressFinalize(this);
        }

        protected virtual void Dispose(bool disposing)
        {
            if (!this.disposed && disposing)
            {
                this.cancellationTokenSource.Dispose();
                this.cancellationTokenSource = null;
            }

            this.disposed = true;
        }

        #endregion Disposing
    }
}