namespace CarrierLink.Controller.Engine.Workers
{
    using Caching;
    using CarrierLink.Controller.Yate;
    using System.Threading.Tasks;
    using Yate.Messaging;

    /// <summary>
    /// This class handles engine.timer messages
    /// </summary>
    internal class EngineTimerWorker : AbstractAnswerWorker, IWorker
    {
        #region Constructor

        /// <summary>
        /// Initializes a new instance of the <see cref="EngineTimerWorker"/> class
        /// </summary>
        internal EngineTimerWorker()
            : base()
        {
            this.Type = MessageType.EngineTimer;
        }

        #endregion Constructor

        #region Properties

        /// <summary>
        /// Gets Yate id
        /// </summary>
        internal int NodeId { get; private set; }

        /// <summary>
        /// Gets Yate name
        /// </summary>
        internal string Nodename { get; private set; }

        /// <summary>
        /// Gets Handler Type
        /// </summary>
        internal MessageType Type { get; private set; }

        #endregion Properties

        #region Methods

        /// <summary>
        /// Starts the processing of the Yate-Message
        /// </summary>
        /// <param name="message">Current Yate message for processing</param>
        /// <param name="isRunning">Indicates if service is running or not</param>
        /// <returns>Returns message as awaitable task</returns>
        async Task<Message> IWorker.ProcessAsync(Message message, bool isRunning)
        {
            this.Initialize(message, isRunning);
            this.NodeId = message.Node.Id;

            var database = Pool.Database.Get();

            await database.NodeKeepAlive(message.Node, this.Time, Core.CancellationToken);
            message.Node.SetLatestEngineTime(this.Time);

            Pool.Database.Put(database);
            database = null;

            this._Acknowledge();

            return this.Message;
        }

        /// <summary>
        /// Overrides default .ToString() behavior
        /// </summary>
        /// <returns>Returns message information in human readable form</returns>
        public override string ToString()
        {
            return string.Format(Formats.CultureInfo, MessageTemplates.ENGINE_TIMER_TO_STRING, this.Type, this.MessageID, this.Nodename, this.Time);
        }

        /// <summary>
        /// Acknowledges processing of message
        /// </summary>
        /// <param name="handled">Indicates if message was handled (processed)</param>
        protected override void _Acknowledge()
        {
            // answer message with 'false' to let it flow further
            this.Message.SetOutgoing(this.Node, MessageDirection.OutgoingAnswer, string.Format(Formats.CultureInfo, MessageTemplates.ENGINE_TIMER_ACKNOWLEDGE, this.MessageID, "false", this.Message.GetValue("time")));
        }

        #endregion Methods
    }
}