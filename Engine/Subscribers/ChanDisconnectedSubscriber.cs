namespace CarrierLink.Controller.Engine.Subscribers
{
    using Yate;
    using Yate.Messaging;

    /// <summary>
    /// This class subscribes to chan.disconnected messages
    /// </summary>
    internal class ChanDisconnectedSubscriber : AbstractMessageSubscriber
    {
        #region Constructor

        /// <summary>
        /// Initializes a new instance of the <see cref="ChanDisconnectedSubscriber"/> class as handler
        /// </summary>
        /// <param name="node">Yate node information</param>
        /// <param name="priority">Handler priority in yates handler queue</param>
        public ChanDisconnectedSubscriber(INode node, int priority)
            : base(node, MessageType.CallCdr, priority)
        {
        }

        #endregion Constructor
    }
}