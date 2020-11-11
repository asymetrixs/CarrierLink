namespace CarrierLink.Controller.Engine.Subscribers
{
    using Yate;
    using Yate.Messaging;

    /// <summary>
    /// This class subscribes to chan.notify messages
    /// </summary>
    internal class ChanNotifySubscriber : AbstractMessageSubscriber
    {
        #region Constructor

        /// <summary>
        /// Initializes a new instance of the <see cref="ChanNotifySubscriber"/> class as handler
        /// </summary>
        /// <param name="node">Yate node information</param>
        /// <param name="priority">Handler priority in yates handler queue</param>
        internal ChanNotifySubscriber(INode node, int priority)
            : base(node, MessageType.ChanNotify, priority)
        {
        }

        #endregion Constructor
    }
}