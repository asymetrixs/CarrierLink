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
    /// This class queries Yate for engine parameter information
    /// </summary>
    internal class EngineParameterSubscriber : AbstractQuerySubscriber, IQuery, IManage
    {
        #region Constructor

        /// <summary>
        /// Initializes a new instance of the <see cref="EngineParameterSubscriber"/> class
        /// </summary>
        /// <param name="node">Yate node information</param>
        /// <param name="parameter">Engine parameter to query from Yate</param>
        internal EngineParameterSubscriber(INode node, EngineParameter parameter)
            : base(node, MessageType.EngineTimer)
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
                case "watch":
                case "unwatch":
                case "setlocal":
                    this.messageWorker.SetResult(bool.Parse(message.IncomingSplittedMessage[3]), message.IncomingSplittedMessage[2]);
                    break;

                case "output":
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
        /// <returns>Returns task to wait for until query result has returned from Yate</returns>
        async Task<QueryParameterResult> IQuery.QueryAsync()
        {
            await this.queryLock.WaitAsync();

            string result = string.Empty;

            this.messageWorker = new EngineParameterWorker((EngineParameter)this.Parameter);

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

            var queryResult = new QueryParameterResult((EngineParameter)this.Parameter, result, success);

            // remove reference
            this.messageWorker = null;

            this.queryLock.Release();

            return queryResult;
        }

        /// <summary>
        /// Parameter to query for
        /// </summary>
        /// <returns>Returns parameter</returns>
        public Enum GetParameter()
        {
            return this.Parameter;
        }

        /// <summary>
        /// Startup of subscriber
        /// </summary>
        void IQuery.Start()
        {
            base.Start();
        }

        /// <summary>
        /// Stop of subscriber
        /// </summary>
        void IQuery.Stop()
        {
            base.Stop();
        }

        #endregion Methods
    }
}