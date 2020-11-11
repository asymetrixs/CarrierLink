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
    /// This class queries Yate for configuration information
    /// </summary>
    internal class EngineConfigurationSubscriber : AbstractSubscriber, IManage
    {
        #region Fields

        /// <summary>
        /// Holds the message worker object which receives the query result from another thread
        /// </summary>
        private ConfigurationMessageWorker currentConfigMessageWorker;

        /// <summary>
        /// Keys value to retrieve
        /// </summary>
        private string key;

        /// <summary>
        /// Locker so that at the moment only one query at a time is possible
        /// </summary>
        private SemaphoreSlim queryLock;

        /// <summary>
        /// Section to query
        /// </summary>
        private string section;

        #endregion Fields

        #region Constructor

        /// <summary>
        /// Initializes a new instance of the <see cref="EngineConfigurationSubscriber"/> class as handler
        /// </summary>
        /// <param name="node">Yate node information</param>
        /// <param name="section">Section to query</param>
        /// <param name="key">Keys value to retrieve</param>
        internal EngineConfigurationSubscriber(INode node, string section, string key)
            : base(node, MessageType.Config)
        {
            this.queryLock = new SemaphoreSlim(initialCount: 1, maxCount: 1);
            this.section = section;
            this.key = key;
        }

        #endregion Constructor

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
                    this.currentConfigMessageWorker.SetResult(bool.Parse(message.IncomingSplittedMessage[3]), message.IncomingSplittedMessage[2]);
                    break;

                case "output":
                    break;

                case "or in":
                    // this is "error in" cutted by 3 chars
                    var ex1 = new ArgumentException("Malformed message emitted", "message");
                    logger.Warn(ex1.Message, ex1);
                    this.currentConfigMessageWorker.SetResult(false, "ERROR: Malformed message emitted");
                    break;

                default:
                    var ex2 = new ArgumentException("Unhandeled message received", "message");
                    logger.Warn(ex2.Message, ex2);
                    this.currentConfigMessageWorker.SetResult(false, "ERROR: Unhandeled message received");
                    break;
            }
        }

        /// <summary>
        /// Returns with queried info - can take some time
        /// </summary>
        /// <returns>Returns task to wait for until result has returned from Yate</returns>
        internal async Task<QueryConfigurationResult> QueryAsync()
        {
            await this.queryLock.WaitAsync();

            string result = string.Empty;

            this.currentConfigMessageWorker = new ConfigurationMessageWorker(this.section, this.key);

            var message = new Message();
            message.SetOutgoing(this.Node, MessageDirection.OutgoingRequest, this.currentConfigMessageWorker.Query());
            this.Node.Send(message);

            // Wait for answer
            await this.currentConfigMessageWorker.Waiter.WaitAsync(this.CancellationToken);

            result = this.currentConfigMessageWorker.Result;

            var queryResult = new QueryConfigurationResult(this.section, this.key, result, !string.IsNullOrEmpty(result));

            // remove reference
            this.currentConfigMessageWorker = null;

            this.queryLock.Release();

            return queryResult;
        }

        #endregion Methods
    }
}