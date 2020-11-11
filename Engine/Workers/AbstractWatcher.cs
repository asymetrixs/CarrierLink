namespace CarrierLink.Controller.Engine.Workers
{
    using Yate;
    using Yate.Messaging;

    internal abstract class AbstractWatcher
    {
        #region Properties

        /// <summary>
        /// Gets original yate message
        /// </summary>
        internal string OriginalMessage { get; private set; }

        /// <summary>
        /// Gets Yate message id
        /// </summary>
        internal string MessageID { get; private set; }

        /// <summary>
        /// Gets or sets node reference
        /// </summary>
        internal INode Node { get; set; }

        /// <summary>
        /// Gets current message that is being processed
        /// </summary>
        protected Message Message { get; private set; }

        /// <summary>
        /// Gets the raw Yate message
        /// </summary>
        protected string[] Messages { get; private set; }
                
        #endregion Properties

        #region Methods

        /// <summary>
        /// Initialize the instance
        /// </summary>
        /// <param name="message">Current Yate message for processing</param>
        protected void Initialize(Message message)
        {
            this.Message = message;
            this.Node = message.Node;
            this.OriginalMessage = message.IncomingOriginalMessage;
            this.MessageID = message.IncomingSplittedMessage[1];
            this.Messages = message.IncomingSplittedMessage;
        }

        /// <summary>
        /// Processes the watched message
        /// </summary>
        /// <returns></returns>
        internal abstract void Handle(Message message);

        #endregion Methods
    }
}
