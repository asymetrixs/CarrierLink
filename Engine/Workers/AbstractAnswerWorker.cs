namespace CarrierLink.Controller.Engine.Workers
{
    using System;
    using Yate;
    using Yate.Messaging;

    /// <summary>
    /// This class serves as base class for receive-send workers
    /// </summary>
    public abstract class AbstractAnswerWorker
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
        /// Gets Yate time in decimal format
        /// </summary>
        internal decimal YateTime { get; private set; }

        /// <summary>
        /// Gets or sets node reference
        /// </summary>
        internal INode Node { get; set; }

        /// <summary>
        /// Gets current message that is being processed
        /// </summary>
        protected Message Message { get; private set; }

        /// <summary>
        /// Gets Yate time in DateTime format
        /// </summary>
        protected DateTime Time { get; private set; }

        /// <summary>
        /// Gets the raw Yate message
        /// </summary>
        protected string[] Messages { get; private set; }

        /// <summary>
        /// Gets a value indicating whether the service is running or not
        /// </summary>
        protected bool IsRunning { get; private set; }

        #endregion Properties

        #region Methods

        /// <summary>
        /// Initialize the instance
        /// </summary>
        /// <param name="message">Current Yate message for processing</param>
        /// <param name="running">Indicates if service is running</param>
        protected void Initialize(Message message, bool running)
        {
            this.Message = message;
            this.Node = message.Node;
            this.OriginalMessage = message.IncomingOriginalMessage;
            this.MessageID = message.IncomingSplittedMessage[1];
            this.YateTime = decimal.Parse(message.IncomingSplittedMessage[2], Formats.CultureInfo);
            this.Time = new DateTime(1970, 1, 1, 0, 0, 0, 0, System.DateTimeKind.Utc).AddSeconds((double)this.YateTime);
            this.Messages = message.IncomingSplittedMessage;
            this.IsRunning = running;
        }

        /// <summary>
        /// Prepares the final message that is send back to Yate
        /// </summary>
        protected abstract void _Acknowledge();

        #endregion Methods
    }
}