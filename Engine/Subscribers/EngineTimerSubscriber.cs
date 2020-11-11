namespace CarrierLink.Controller.Engine.Subscribers
{
    using Yate;
    using Yate.Messaging;

    /// <summary>
    /// This class subscribes engine.timer messages
    /// </summary>
    internal class EngineTimerSubscriber : AbstractMessageSubscriber
    {
        #region Constructor

        /// <summary>
        /// Initializes a new instance of the <see cref="EngineTimerSubscriber"/> class
        /// </summary>
        /// <param name="node">Yate node information</param>
        /// <param name="priority">Handler priority in yates handler queue</param>
        public EngineTimerSubscriber(INode node, int priority)
            : base(node, MessageType.EngineTimer, priority)
        {
        }

        #endregion Constructor
    }
}