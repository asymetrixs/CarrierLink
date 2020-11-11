namespace CarrierLink.Controller.Engine.Subscribers
{
    using Yate;
    using Yate.Messaging;

    /// <summary>
    /// This class subscribes to chan.hangup messages
    /// </summary>
    internal class ChanHangupSubscriber : AbstractMessageSubscriber
    {
        #region Constructor

        /// <summary>
        /// Initializes a new instance of the <see cref="ChanHangupSubscriber"/> class as handler
        /// </summary>
        /// <param name="node">Yate node information</param>
        /// <param name="priority">Handler priority in yates handler queue</param>
        internal ChanHangupSubscriber(INode node, int priority)
            : base(node, MessageType.ChanHangup, priority)
        {
        }

        /// <summary>
        /// Initializes a new instance of the <see cref="ChanHangupSubscriber"/> class as watcher
        /// </summary>
        /// <param name="node">Yate node information</param>
        internal ChanHangupSubscriber(INode node)
            : base(node, MessageType.ChanHangup)
        {
        }

        #endregion Constructor
    }
}