namespace CarrierLink.Controller.Engine.Subscribers
{
    using System;
    using System.Linq;
    using System.Threading;
    using System.Threading.Tasks;
    using Results;
    using Workers;
    using Yate;
    using Yate.Messaging;
    using Utilities;

    /// <summary>
    /// This class queries Yate for custom carrierlink information
    /// </summary>
    internal class CarrierLinkQuerySubscriber : AbstractQuerySubscriber, IQuery, IManage
    {
        #region Constructor

        /// <summary>
        /// Initializes a new instance of the <see cref="CarrierLinkQuerySubscriber"/> class
        /// </summary>
        /// <param name="node">Yate node information</param>
        /// <param name="param">Parameter to query from Yate</param>
        internal CarrierLinkQuerySubscriber(INode node, CarrierLinkParameter parameter)
            : base(node, MessageType.CarrierLinkNode)
        {
            this.queryLock = new SemaphoreSlim(initialCount: 1, maxCount: 1);
            this.Parameter = parameter;
        }

        #endregion Constructor

        #region Properties

        /// <summary>
        /// Gets handler id
        /// </summary>
        public new Guid Id
        {
            get
            {
                return base.Id;
            }
        }

        #endregion Properties

        #region Methods

        /// <summary>
        /// Processes subscribed messages
        /// </summary>
        /// <param name="message">Message from yate</param>
        void IManage.Manage(Message message)
        {
            switch (message.IncomingSplittedMessage[0].Substring(3))
            {
                case "message":
                    var success = bool.Parse(message.IncomingSplittedMessage[2]);
                    if (success)
                    {
                        this.messageWorker.SetResult(success, string.Join(":", message.IncomingSplittedMessage.Skip(6)));
                    }
                    else
                    {
                        this.messageWorker.SetResult(success, string.Empty);
                    }
                    break;

                case "or in":
                    // this is "error in" cutted by 3 chars
                    var ex1 = new ArgumentException("Malformed message emitted", "message");
                    logger.Warn(ex1.Message, ex1);
                    this.messageWorker.SetResult(false, "ERROR: Malformed message emitted");
                    break;

                default:
                    var ex2 = new ArgumentException("Unhandeled message received", "message");
                    logger.Warn(ex2.Message, ex2);
                    this.messageWorker.SetResult(false, "ERROR: Unhandeled message received");
                    break;
            }
        }

        /// <summary>
        /// Returns with queried info - can take some time
        /// </summary>
        /// <returns>Task to wait for until query has returned from Yate</returns>
        async Task<QueryParameterResult> IQuery.QueryAsync()
        {
            await this.queryLock.WaitAsync();

            string result = string.Empty;

            this.messageWorker = new CarrierLinkWorker((CarrierLinkParameter)this.Parameter);

            var message = new Message();
            message.SetOutgoing(this.Node, MessageDirection.OutgoingRequest, this.messageWorker.Query());
            this.Node.Send(message);

            // Wait for answer
            bool success = false;
            try
            {
                await this.messageWorker.Waiter.WaitAsync(this.CancellationToken);
                result = this.messageWorker.Result;
                success = !string.IsNullOrEmpty(result);
            }
            catch (OperationCanceledException)
            {
                result = "Timeout.";
            }

            var queryResult = new QueryParameterResult(MonitorParameter.AccountId, result, success);

            this.queryLock.Release();

            return queryResult;
        }

        /// <summary>
        /// Starts the subscriber
        /// </summary>
        void IQuery.Start()
        {
            base.Start();
        }

        /// <summary>
        /// Stops the subscriber
        /// </summary>
        void IQuery.Stop()
        {
            this.messageWorker = null;
            this.queryLock.Dispose();
            this.queryLock = null;

            base.Stop();
        }
        #endregion Methods
    }
}
