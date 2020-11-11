namespace CarrierLink.Controller.Engine.Subscribers
{
    using Workers;
    using Yate;
    using Yate.Messaging;
    using System.Threading;
    using System;

    internal abstract class AbstractQuerySubscriber : AbstractSubscriber
    {
        #region Fields

        /// <summary>
        /// Holds the message worker object which receives the query result from another thread
        /// </summary>
        protected AbstractQueryWorker messageWorker;

        /// <summary>
        /// Locker so that at the moment only one query at a time is possible
        /// </summary>
        protected SemaphoreSlim queryLock;
        
        #endregion
        
        #region Constructor

        /// <summary>
        /// Initializes a new instance of the <see cref="AbstractSubscriber"/> class
        /// </summary>
        /// <param name="node">Yate node information</param>
        /// <param name="type">Type of messages to subscribe</param>
        public AbstractQuerySubscriber(INode node, MessageType type)
            : base(node, type)
        { }

        #endregion

        #region Properties

        /// <summary>
        /// Parameter to query from node
        /// </summary>
        public Enum Parameter { get; protected set; }

        #endregion
    }
}
