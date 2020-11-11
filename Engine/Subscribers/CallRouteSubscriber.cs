namespace CarrierLink.Controller.Engine.Subscribers
{
    using Yate;
    using Yate.Messaging;

    /// <summary>
    /// This class subscribes to call.route messages
    /// </summary>
    internal class CallRouteSubscriber : AbstractMessageSubscriber
    {
        #region Constructor

        /// <summary>
        /// Initializes a new instance of the <see cref="CallRouteSubscriber"/> class as handler
        /// </summary>
        /// <param name="node">Yate node information</param>
        /// <param name="priority">Handler priority in yates handler queue</param>
        internal CallRouteSubscriber(INode node, int priority)
            : base(node, MessageType.CallRoute, priority)
        {
        }

        #endregion Constructor
    }
}