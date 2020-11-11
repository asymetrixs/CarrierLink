namespace CarrierLink.Controller.Engine.Subscribers
{
    using Yate;
    using Yate.Messaging;

    /// <summary>
    /// This class subscribes to chan.dtmf messages
    /// </summary>
    internal class ChanDtmfSubscriber : AbstractMessageSubscriber
    {
        #region Constructor

        /// <summary>
        /// Initializes a new instance of the <see cref="ChanDtmfSubscriber"/> class as handler
        /// </summary>
        /// <param name="node">Yate node information</param>
        /// <param name="priority">Handler priority in yates handler queue</param>
        internal ChanDtmfSubscriber(INode node, int priority)
            : base(node, MessageType.ChanDtmf, priority)
        {
        }

        #endregion Constructor
    }
}