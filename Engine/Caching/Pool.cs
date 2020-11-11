namespace CarrierLink.Controller.Engine.Caching
{
    using Database;
    using Model;
    using NLog;
    using System;
    using System.Text;
    using Utilities;
    using Workers;
    using Yate;
    using Yate.Messaging;

    /// <summary>
    /// A pool that holds pools to reusable instances of objects
    /// </summary>
    public static class Pool
    {
        #region Fields

        /// <summary>
        /// Logger instance
        /// </summary>
        private static Logger logger;

        #endregion Fields

        #region Properties

        /// <summary>
        /// Gets engine parameter and technical names
        /// </summary>
        internal static TechnicalNameMapper<CarrierLinkParameter> CarrierLinkParameters { get; private set; }

        /// <summary>
        /// Gets CDR message worker pool
        /// </summary>
        internal static ObjectPool<CallCdrWorker> CdrMessageWorkers { get; private set; }

        /// <summary>
        /// Gets chan hangup watcher pool
        /// </summary>
        internal static ObjectPool<ChanHangupWatcher> ChanHangupWatchers { get; private set; }

        /// <summary>
        /// Gets chan startup watchter pool
        /// </summary>
        internal static ObjectPool<ChanStartupWatcher> ChanStartupWatchers { get; private set; }

        /// <summary>
        /// Gets external database pool
        /// </summary>
        internal static ObjectPool<IDatabase> Database { get; private set; }

        /// <summary>
        /// Gets engine parameter and technical names
        /// </summary>
        internal static TechnicalNameMapper<EngineParameter> EngineParameters { get; private set; }

        /// <summary>
        /// Gets engine timer message worker pool
        /// </summary>
        internal static ObjectPool<EngineTimerWorker> EngineTimerMessageWorkers { get; private set; }

        /// <summary>
        /// Gets fork connect behavior and technical name
        /// </summary>
        internal static TechnicalNameMapper<ForkConnectBehavior> ForkConnectBehaviors { get; private set; }

        /// <summary>
        /// Gets message type and technical name
        /// </summary>
        internal static TechnicalNameMapper<MessageType> MessageTypes { get; private set; }

        /// <summary>
        /// Gets monitor parameter and technical name
        /// </summary>
        internal static TechnicalNameMapper<MonitorParameter> MonitorParameters { get; private set; }

        /// <summary>
        /// Gets route message worker pool
        /// </summary>
        public static ObjectPool<CallRouteWorker> RouteMessageWorkers { get; private set; }

        /// <summary>
        /// Gets string builder pool
        /// </summary>
        internal static ObjectPool<StringBuilder> StringBuilders { get; private set; }

        /// <summary>
        /// Gets resolves subscriber type and technical name
        /// </summary>
        internal static TechnicalNameMapper<SubscriberType> SubscriberTypes { get; private set; }

        #endregion Properties

        #region Functions

        /// <summary>
        /// Initializes the pools
        /// </summary>
        /// <param name="database">Function to create the <see cref="Database.IDatabase"/></param>
        public static void Initialize(Func<IDatabase> database)
        {
            logger = LogManager.GetCurrentClassLogger();
            logger.Debug("Initialize Pool");

            Database = new ObjectPool<IDatabase>(database);
            RouteMessageWorkers = new ObjectPool<CallRouteWorker>(() => new CallRouteWorker());
            CdrMessageWorkers = new ObjectPool<CallCdrWorker>(() => new CallCdrWorker());
            ChanHangupWatchers = new ObjectPool<ChanHangupWatcher>(() => new ChanHangupWatcher());
            ChanStartupWatchers = new ObjectPool<ChanStartupWatcher>(() => new ChanStartupWatcher());
            EngineTimerMessageWorkers = new ObjectPool<EngineTimerWorker>(() => new EngineTimerWorker());
            StringBuilders = new ObjectPool<StringBuilder>(() => new StringBuilder());
            ForkConnectBehaviors = new TechnicalNameMapper<ForkConnectBehavior>();
            MessageTypes = new TechnicalNameMapper<MessageType>();
            EngineParameters = new TechnicalNameMapper<EngineParameter>();
            MonitorParameters = new TechnicalNameMapper<MonitorParameter>();
            SubscriberTypes = new TechnicalNameMapper<SubscriberType>();
            CarrierLinkParameters = new TechnicalNameMapper<CarrierLinkParameter>();

            logger.Debug("Initilize Pool Done");
        }

        #endregion Functions
    }
}