namespace CarrierLink.Controller.Engine.Subscribers
{
    using Yate;
    using Yate.Messaging;

    /// <summary>
    /// This class subscribes to call.execute messages
    /// </summary>
    internal class CallExecuteSubscriber : AbstractMessageSubscriber
    {
        #region Constructor

        /// <summary>
        /// Initializes a new instance of the <see cref="CallExecuteSubscriber"/> class as handler
        /// </summary>
        /// <param name="node">Yate node information</param>
        /// <param name="priority">Handler priority in yates handler queue</param>
        internal CallExecuteSubscriber(INode node, int priority)
            : base(node, MessageType.CallExecute, priority)
        {
        }

        /// <summary>
        /// Initializes a new instance of the <see cref="CallExecuteSubscriber"/> class as watcher
        /// </summary>
        /// <param name="node">Yate node information</param>
        internal CallExecuteSubscriber(INode node)
            : base(node, MessageType.CallExecute)
        {
        }

        #endregion Constructor
    }
}