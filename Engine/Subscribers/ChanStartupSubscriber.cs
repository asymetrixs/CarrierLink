namespace CarrierLink.Controller.Engine.Subscribers
{
    using Yate;
    using Yate.Messaging;

    /// <summary>
    /// This class subscribes to chan.startup messages
    /// </summary>
    internal class ChanStartupSubscriber : AbstractMessageSubscriber
    {
        #region Constructor

        /// <summary>
        /// Initializes a new instance of the <see cref="ChanStartupSubscriber"/> class as handler
        /// </summary>
        /// <param name="node">Yate node information</param>
        /// <param name="priority">Handler priority in yates handler queue</param>
        internal ChanStartupSubscriber(INode node, int priority)
            : base(node, MessageType.ChanStartup, priority)
        {
        }

        /// <summary>
        /// Initializes a new instance of the <see cref="ChanStartupSubscriber"/> class as handler
        /// </summary>
        /// <param name="node">Yate node information</param>
        internal ChanStartupSubscriber(INode node)
            : base(node, MessageType.ChanStartup)
        {
        }

        #endregion Constructor
    }
}