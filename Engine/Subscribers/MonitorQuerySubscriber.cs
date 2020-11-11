namespace CarrierLink.Controller.Engine.Subscribers
{
    using System;
    using System.Threading;
    using System.Threading.Tasks;
    using Results;
    using Workers;
    using Yate;
    using Yate.Messaging;

    /// <summary>
    /// This class queries Yate for monitoring information
    /// </summary>
    internal class MonitorQuerySubscriber : AbstractQuerySubscriber, IQuery, IManage
    {
        #region Constructor

        /// <summary>
        /// Initializes a new instance of the <see cref="MonitorQuerySubscriber"/> class
        /// </summary>
        /// <param name="node">Yate node information</param>
        /// <param name="param">Parameter to query from Yate</param>
        internal MonitorQuerySubscriber(INode node, MonitorParameter param)
            : base(node, MessageType.MonitorQuery)
        {
            this.queryLock = new SemaphoreSlim(initialCount: 1, maxCount: 1);
            this.Parameter = param;
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
                        this.messageWorker.SetResult(success, message.IncomingSplittedMessage[7].Replace("value=", string.Empty));
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

            this.messageWorker = new MonitorQueryWorker((MonitorParameter)this.Parameter);

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

            var queryResult = new QueryParameterResult((MonitorParameter)this.Parameter, result, success);

            // remove reference
            this.messageWorker = null;

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
            base.Stop();
        }
        #endregion Methods
    }
}