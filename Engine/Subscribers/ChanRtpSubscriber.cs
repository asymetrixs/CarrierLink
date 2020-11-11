namespace CarrierLink.Controller.Engine.Subscribers
{
    using Yate;
    using Yate.Messaging;

    /// <summary>
    /// This class subscribes to chan.rtp messages
    /// </summary>
    internal class ChanRtpSubscriber : AbstractMessageSubscriber
    {
        #region Constructor

        /// <summary>
        /// Initializes a new instance of the <see cref="ChanRtpSubscriber"/> class as handler
        /// </summary>
        /// <param name="node">Yate node information</param>
        internal ChanRtpSubscriber(INode node)
            : base(node, MessageType.ChanRtp)
        {
        }

        #endregion Constructor
    }
}
