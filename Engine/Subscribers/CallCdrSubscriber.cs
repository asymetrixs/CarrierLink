namespace CarrierLink.Controller.Engine.Subscribers
{
    using System;
    using System.Collections.Concurrent;
    using System.Linq;
    using Workers.Model;
    using Yate;
    using Yate.Messaging;

    /// <summary>
    /// This class subscribes to call.cdr messages
    /// </summary>
    internal class CallCdrSubscriber : AbstractMessageSubscriber
    {
        #region Constructor

        /// <summary>
        /// Initializes a new instance of the <see cref="CallCdrSubscriber"/> class
        /// </summary>
        /// <param name="node">Yate node information</param>
        /// <param name="priority">Handler priority in yates handler queue</param>
        public CallCdrSubscriber(INode node, int priority)
            : base(node, MessageType.CallCdr, priority)
        {
        }

        #endregion Constructor
    }
}