namespace CarrierLink.Controller.Engine
{
    using Caching;
    using CarrierLink.Controller.Engine.REST.Model;
    using Database;
    using Jobs;
    using Microsoft.Extensions.Configuration;
    using NLog;
    using Subscribers;
    using System;
    using System.Collections.Concurrent;
    using System.Collections.Generic;
    using System.Linq;
    using System.Threading;
    using System.Threading.Tasks;
    using System.Threading.Tasks.Dataflow;
    using Utilities;
    using Workers;
    using Yate;
    using Yate.Messaging;

    /// <summary>
    /// This class is the entry point and sets up the engine
    /// </summary>
    public static class Core
    {
        #region Fields

        /// <summary>
        /// Disruptor buffer size
        /// </summary>
        private const int BufferSize = 16384;

        /// <summary>
        /// Cancellation Token for stopping the engine
        /// </summary>
        private static CancellationTokenSource cancellationToken = new CancellationTokenSource();

        /// <summary>
        /// Connects and disconnects Controller according to database settings and checks if connections are still connected
        /// </summary>
        private static System.Timers.Timer connectionManagmentTimer;

        /// <summary>
        /// Counts updates and controller partial/full updates
        /// </summary>
        private static int updateCounter;

        /// <summary>
        /// Tracks installations
        /// </summary>
        private static ConcurrentDictionary<int, Guid[]> installations = new ConcurrentDictionary<int, Guid[]>();

        /// <summary>
        /// Locks connecting to Node to prevent concurrent connection establishing
        /// </summary>
        private static ConcurrentDictionary<int, SemaphoreSlim> lockConnecting = new ConcurrentDictionary<int, SemaphoreSlim>();

        /// <summary>
        /// Locks <see cref="ShutdownAsync"/>
        /// </summary>
        private static SemaphoreSlim lockShutdown = new SemaphoreSlim(1, 1);

        /// <summary>
        /// Locks <see cref="StartupAsync"/>
        /// </summary>
        private static SemaphoreSlim lockStartup = new SemaphoreSlim(1, 1);

        /// <summary>
        /// Locks <see cref="_Uninstall(Guid)"/>
        /// </summary>
        private static SemaphoreSlim lockUninstallation = new SemaphoreSlim(1, 1);

        /// <summary>
        /// Logger instance
        /// </summary>
        private static Logger logger = LogManager.GetCurrentClassLogger();

        /// <summary>
        /// Limits access to <seealso cref="QueryParameterAsync(int, Enum)" /> method
        /// </summary>
        private static SemaphoreSlim queryParameterLock = new SemaphoreSlim(1, 1);

        /// <summary>
        /// Gets connection tracker
        /// </summary>
        private static ConcurrentDictionary<int, INode> nodeConnections = new ConcurrentDictionary<int, INode>();

        /// <summary>
        /// Gets connection tracker for corrupt connections
        /// </summary>
        private static ConcurrentDictionary<int, INode> nodeConnectionsOld = new ConcurrentDictionary<int, INode>();

        /// <summary>
        /// Gets queue buffer for all messages for processing
        /// </summary>
        private static ActionBlock<Message> messageBuffer;

        /// <summary>
        /// Required handlers for IVR
        /// </summary>
        internal static MessageType[] requiredHandlers = new MessageType[]
        {
            MessageType.ChanDtmf,
            MessageType.ChanNotify,
            MessageType.CallRoute,
            MessageType.EngineTimer,
            MessageType.CallCdr
            ////MessageType.ChanDisconnected
        };

        /// <summary>
        /// Required watchers for IVR
        /// </summary>
        internal static MessageType[] requiredWatchers = new MessageType[]
        {
            MessageType.ChanStartup,
            MessageType.CallExecute,
            MessageType.ChanHangup,
            MessageType.ChanRtp
        };

        /// <summary>
        /// The value indicating the waiting time threshold
        /// </summary>
        private static int waitingTimeWarningThreshold;

        /// <summary>
        /// The time when last waiting time threshold warning was emitted
        /// </summary>
        private static DateTime? lastWarningEmitted;

        /// <summary>
        /// The time Yate maximal waits for an answer
        /// </summary>
        private static int yateMaximumWaitingTime;

        #endregion Fields

        #region Properties

        /// <summary>
        /// Gets main cancellation token
        /// </summary>
        internal static CancellationToken CancellationToken
        {
            get
            {
                return cancellationToken.Token;
            }
        }

        /// <summary>
        /// Gets handler tracker
        /// </summary>
        internal static ConcurrentDictionary<Guid, AbstractSubscriber> Handlers { get; } = new ConcurrentDictionary<Guid, AbstractSubscriber>();

        /// <summary>
        /// Gets Controller id
        /// </summary>
        internal static int Id { get; private set; }

        /// <summary>
        /// Gets internal property representing the engine state
        /// </summary>
        internal static EngineState State { get; private set; }

        /// TODO: Implement CPU Threshold and dos-handling
        /// Database: ControllerInfo to define CPU 5m/10m threshold and
        /// Dispatcher functionality to discard queries when usage exceeds thresholds

        #endregion Properties

        #region Functions

        /// <summary>
        /// Connects, Disconnects and Reconnects connections
        /// </summary>
        /// <param name="sender">Event sender</param>
        /// <param name="e">Event argument</param>
        private static void _ConnectionManagmentTimer_Elapsed(object sender, System.Timers.ElapsedEventArgs e)
        {
            if (Monitor.TryEnter(connectionManagmentTimer))
            {
                logger.ConditionalDebug("Job ConnectionManagement started");

                // Check connection for connectivity
                try
                {
                    // Cleanup old connections
                    KeyValuePair<int, INode> con;
                    foreach (var connection in nodeConnectionsOld.ToList())
                    {
                        con = connection;
                        _CloseAndCleanup(con.Value).Wait();
                    }
                    nodeConnectionsOld.Clear();

                    // Check current connections
                    foreach (var connection in nodeConnections.ToList())
                    {
                        con = connection;
                        if (!con.Value.IsConnected)
                        {
                            _CloseAndCleanup(con.Value).Wait();

                            nodeConnections.TryRemove(con.Key, out INode inode);
                        }
                    }
                }
                catch { }

                var database = Pool.Database.Get();
                var connections = database.ControllerConnectons(Id, CancellationToken).Result;

                // Check for nodes that need to get connected
                var nodesToConnect = from c in connections
                                     where (c.AutoConnect && c.ControlState != ControlState.Connected)
                                            || c.ControlState == ControlState.ConnectRequested
                                     select c.NodeId;

                // Check for nodes that need to get disconnected
                // by request (1) and because they are disabled and do not show up in object 'connections' anymore (2) or did not exchange messages for 1 minute
                var nodesToDisconnect = (
                                        from c in connections
                                        where !c.AutoConnect && c.ControlState == ControlState.DisconnectRequested
                                        select c.NodeId)
                                        .Union
                                        (
                                        from ec in nodeConnections
#if DEBUG
                                        where !connections.Select(c => c.NodeId).Contains(ec.Key) || ec.Value.LastMessageReceived < DateTime.UtcNow.AddMinutes(-10)
#else
                                        where !connections.Select(c => c.NodeId).Contains(ec.Key) || ec.Value.LastMessageReceived < DateTime.UtcNow.AddMinutes(-1)
#endif
                                        select ec.Key
                                        );

                if (cancellationToken.IsCancellationRequested)
                {
                    return;
                }

                // Connect Nodes
                var connectionTasks = new List<Task>();
                foreach (var nodeId in nodesToConnect)
                {
                    connectionTasks.Add(Task.Run(() => _Connect(nodeId)));
                }

                // Disconnect Nodes
                foreach (var nodeId in nodesToDisconnect)
                {
                    connectionTasks.Add(Task.Run(() => _Disconnect(nodeId)));
                }

                // Wait one minute for tasks to complete
                try
                {
                    var cancellationTokenSource = new CancellationTokenSource();
                    cancellationTokenSource.CancelAfter(60000);
                    Task.WaitAll(connectionTasks.ToArray(), cancellationTokenSource.Token);
                }
                catch (Exception ex)
                {
                    logger.Error(ex);
                }

                Pool.Database.Put(database);
                database = null;

                logger.ConditionalDebug("Job ConnectionManagement finished");

                if (!CancellationToken.IsCancellationRequested)
                {
                    Monitor.Exit(connectionManagmentTimer);
                }
            }
        }

        #region Engine Start/Stop

        /// <summary>
        /// Continues message processing of handlers
        /// </summary>
        internal static void Continue()
        {
            if (State == EngineState.Paused)
            {
                foreach (var handler in Handlers)
                {
                    handler.Value.Continue();
                }

                State = EngineState.Running;
            }
        }

        /// <summary>
        /// Pauses message processing of handlers
        /// </summary>
        internal static void Pause()
        {
            if (State == EngineState.Running)
            {
                foreach (var handler in Handlers)
                {
                    handler.Value.Pause();
                }

                State = EngineState.Paused;
            }
        }

        /// <summary>
        /// Removes the handlers and stops the engine
        /// </summary>
        /// <returns>Returns task to wait for until shutdown has completed</returns>
        public static async Task ShutdownAsync()
        {
            await lockShutdown.WaitAsync();

            logger.Info("Shutdown...");

            if (!IsRunning())
            {
                lockShutdown.Release();
                return;
            }

            var db = Pool.Database.Get();
            await db.ControllerLog(Id, "Shutdown Initiated", CancellationToken);

            State = EngineState.Stopping;

            // Stop jobs
            AutomaticJobsManager.Stop();

            // Disconnect connections
            connectionManagmentTimer.Stop();
            var connectionsToStop = new List<Task>();
            var registeredConnections = nodeConnections.Select(nc => nc.Value).ToList();
            foreach (var node in registeredConnections)
            {
                if (node.IsConnected)
                {
                    connectionsToStop.Add(_Disconnect(node.Id));
                }
            }

            await Task.WhenAll(connectionsToStop);
            connectionsToStop = null;

            // Signal completition of message processing and wait for buffer to complete, max. 5 seconds
            messageBuffer.Complete();
            int timeout = 0;
            while (messageBuffer.InputCount > 0 && timeout < 20)
            {
                await Task.Delay(250);
                timeout++;
            }

            // Cancel parallel operations in Main
            logger.Debug("Cancelling processes, may take up to two minutes.");
            cancellationToken.Cancel();

            /// Wait 10 seconds
            await Task.Delay(10000);

            var databaseCancellationTokenSource = new CancellationTokenSource();
            databaseCancellationTokenSource.CancelAfter(30000);

            await db.ControllerLog(Id, "Remaining Connections terminated", databaseCancellationTokenSource.Token);
            await db.ControllerLog(Id, "Shutdown Completed", databaseCancellationTokenSource.Token);
            await db.ControllerShutdown(Id, databaseCancellationTokenSource.Token);
            Pool.Database.Put(db);

            databaseCancellationTokenSource.Dispose();
            databaseCancellationTokenSource = null;

            // Shutdown the Cache
            Cache.Shutdown();

            State = EngineState.Stopped;

            logger.Info("Shutdown completed");

            messageBuffer = null;

            cancellationToken.Dispose();
            cancellationToken = null;

            connectionManagmentTimer.Dispose();
            connectionManagmentTimer = null;

            lockShutdown.Release();
            lockShutdown.Dispose();
            lockShutdown = null;

            logger = null;
        }

        /// <summary>
        /// Starts the engine and updates the Cache from Database
        /// </summary>
        /// <returns>Returns task to wait for until Startup has completed (true) or failed (false)</returns>
        public static async Task<bool> StartupAsync(IConfigurationRoot configuration)
        {
            await lockStartup.WaitAsync();

            var engineConfig = configuration.GetSection("Engine");

            logger.Info("<<<<<<<<<<<<<<<<<<<< CarrierLink >>>>>>>>>>>>>>>>>>>>");
            logger.Info("Startup...");

            if (IsRunning())
            {
                logger.Error("Engine is already running");
                return false;
            }

            Pool.Initialize(() => new PgSQL(configuration.GetConnectionString("CarrierLink")));

            // Message Buffer Setup
            if (!int.TryParse(engineConfig.GetValue<string>("Workers"), out int workers) || workers < 1)
            {
                throw new InvalidOperationException("Workers needs to be a positive number");
            }

            // WaitingTimeWarningThreshold
            if (!int.TryParse(engineConfig.GetValue<string>("WaitingTimeWarningThreshold"), out waitingTimeWarningThreshold) || waitingTimeWarningThreshold < 1 || waitingTimeWarningThreshold > 10)
            {
                logger.Warn(@"Configuration Parameter ""WaitingTimeWarningThreshold"" is not an Integer or not between 1 and 10, setting value to 2 (default)");
                waitingTimeWarningThreshold = 2;
            }
            waitingTimeWarningThreshold *= 1000;


            // YateMaximumWaitingTime
            if (!int.TryParse(engineConfig.GetValue<string>("YateMaximumWaitingTime"), out yateMaximumWaitingTime) || yateMaximumWaitingTime < 1 || yateMaximumWaitingTime > 300)
            {
                logger.Warn(@"Configuration Parameter ""YateMaximumWaitingTime"" is not an Integer or not between 1 and 300, setting value to 10 (default)");
                yateMaximumWaitingTime = 2;
            }
            yateMaximumWaitingTime *= 1000;


            messageBuffer = new ActionBlock<Message>(async message => await _ProcessMessage(message),
                new ExecutionDataflowBlockOptions()
                {
                    MaxDegreeOfParallelism = workers,
                    CancellationToken = CancellationToken,
                    SingleProducerConstrained = false
                }
            );

            // Delete old registrations
            var database = Pool.Database.Get();
            try
            {
                Id = await database.ControllerStartup(engineConfig.GetValue<string>("ControlServerName"), CancellationToken);
            }
            catch
            {
                logger.Error($"Controller Name '{engineConfig.GetValue<string>("ControlServerName")}' is not registered in database. ABORTING.");

                throw new ArgumentException($"Controller Name '{engineConfig.GetValue<string>("ControlServerName")}' is not registered in database.");
            }

            await database.ControllerLog(Id, "Startup Initiated", CancellationToken);

            // Default Value
            State = EngineState.Stopped;

            Cache.Initialize();

            await database.ControllerLog(Id, "Updating Cache", CancellationToken);
            await Cache.Update(false);

            // Connection Management Timer
            connectionManagmentTimer = new System.Timers.Timer
            {
                AutoReset = true,
                Interval = 2000
            };
            connectionManagmentTimer.Elapsed += _ConnectionManagmentTimer_Elapsed;

            State = EngineState.Running;

            await database.ControllerLog(Id, "Startup Completed", CancellationToken);
            Pool.Database.Put(database);

            // Start Timers
            connectionManagmentTimer.Start();
            AutomaticJobsManager.Start();

            logger.Info("Startup completed");

            lockStartup.Release();

            return true;
        }

        /// <summary>
        /// Checks engine state
        /// </summary>
        /// <returns>True, if engine is running</returns>
        private static bool IsRunning()
        {
            return State == EngineState.Running;
        }

        #endregion Engine Start/Stop

        #region Engine Query

        /// <summary>
        /// Queries the yate server for information
        /// </summary>
        /// <param name="nodeId">Yate node Id</param>
        /// <param name="section">Section from yate config</param>
        /// <param name="key">Keys value to retrieve</param>
        /// <returns>Returns task to wait for until query configuration result has returned from Yate</returns>
        public static async Task<Results.QueryConfigurationResult> QueryEngineConfigurationAsync(int nodeId, string section, string key)
        {
            if (!IsRunning())
            {
                return new Results.QueryConfigurationResult(section, key, "Engine is on hold.", false);
            }

            await queryParameterLock.WaitAsync();

            Results.QueryConfigurationResult result;
            var node = await _GetConnectedAndRegisteredNode(nodeId);

            if (node == null)
            {
                queryParameterLock.Release();
                return new Results.QueryConfigurationResult(section, key, "Connecting failed.", false);
            }

            if (string.IsNullOrEmpty(section) || string.IsNullOrEmpty(key))
            {
                await node.Disconnect();
                queryParameterLock.Release();
                return new Results.QueryConfigurationResult(section, key, "Parameter is empty.", false);
            }

            var queryHandler = new EngineConfigurationSubscriber(node, section, key);

            Handlers.TryAdd(queryHandler.Id, queryHandler);

            queryHandler.Start();
            result = await queryHandler.QueryAsync();
            queryHandler.Stop();

            Handlers.TryRemove(queryHandler.Id, out AbstractSubscriber qs);


            queryParameterLock.Release();

            return result;
        }

        /// <summary>
        /// Queries the yate server for information
        /// </summary>
        /// <param name="nodeId">Yate node Id</param>
        /// <param name="param">The Parameter whose value is requested from yate</param>
        /// <returns>Returns task to wait for until query parameter result has returned from Yate</returns>
        public static async Task<Results.QueryParameterResult> QueryParameterAsync(int nodeId, Enum param)
        {
            if (!IsRunning())
            {
                return new Results.QueryParameterResult(param, "Engine is on hold.", false);
            }

            await queryParameterLock.WaitAsync();

            Results.QueryParameterResult result;
            var node = await _GetConnectedAndRegisteredNode(nodeId);

            if (node == null)
            {
                queryParameterLock.Release();
                return new Results.QueryParameterResult(param, "Connecting failed.", false);
            }

            IQuery queryMessageHandler = null;

            // Start connection
            if (param is EngineParameter)
            {
                queryMessageHandler = new EngineParameterSubscriber(node, (EngineParameter)param);
            }
            else if (param is MonitorParameter)
            {
                queryMessageHandler = new MonitorQuerySubscriber(node, (MonitorParameter)param);
            }
            else if (param is CarrierLinkParameter)
            {
                queryMessageHandler = new CarrierLinkQuerySubscriber(node, (CarrierLinkParameter)param);
            }

            if (queryMessageHandler != null)
            {
                Handlers.TryAdd(queryMessageHandler.Id, queryMessageHandler as AbstractSubscriber);

                queryMessageHandler.Start();

                result = await queryMessageHandler.QueryAsync();

                queryMessageHandler.Stop();

                Handlers.TryRemove(queryMessageHandler.Id, out AbstractSubscriber qs);
            }
            else
            {
                result = new Results.QueryParameterResult(param, "Cannot determine parameter.", false);
            }

            queryParameterLock.Release();

            return result;
        }

        #endregion Engine Query

        #region Installation / Deinstallation

        /// <summary>
        /// Connects to Yate
        /// </summary>
        /// <param name="nodeId">Yate Node Id</param>
        /// <returns>Returns task to wait for until connection has been established</returns>
        private static async Task<bool> _Connect(int nodeId)
        {
            if (!IsRunning())
            {
                return false;
            }

            bool success = true;

            var database = Pool.Database.Get();
            if (installations.ContainsKey(nodeId))
            {
                logger.Info($"Controller is already installed on node {nodeId}");
                await database.ControllerConnectionStatusUpdate(Id, nodeId, ControlState.Connected, CancellationToken);
                Pool.Database.Put(database);
                return false;
            }

            var node = await _GetConnectedAndRegisteredNode(nodeId);
            if (node == null)
            {
                await database.ControllerConnectionStatusUpdate(Id, nodeId, ControlState.ConnectionFailed, CancellationToken);
                await database.ControllerLog(Id, "Connecting failed: " + nodeId, CancellationToken);
                Pool.Database.Put(database);
                return false;
            }

            logger.Debug($"Subscribing to {node.IPAddress}");

            await database.ControllerLog(Id, $"Subscribing to {node.IPAddress}", CancellationToken);

            int basePriority = 80;
            int currentPosition = basePriority;
            installations.TryAdd(nodeId, new Guid[requiredHandlers.Length + requiredWatchers.Length]);

            bool errorOccured = false;
            for (; currentPosition < basePriority + requiredHandlers.Length; currentPosition++)
            {
                installations[nodeId][currentPosition - basePriority] = await _InstallHandler(node, requiredHandlers[currentPosition - basePriority], basePriority);
                if (installations[nodeId][currentPosition - basePriority].ToString("N") == Guid.ParseExact("00000000000000000000000000000000", "N").ToString("N"))
                {
                    errorOccured = true;
                    break;
                }
            }

            if (!errorOccured)
            {
                foreach (var subscriberType in requiredWatchers)
                {
                    int pos = currentPosition - basePriority - requiredHandlers.Length;
                    installations[nodeId][currentPosition - basePriority] = await _InstallWatcher(node, requiredWatchers[pos]);
                    if (installations[nodeId][currentPosition - basePriority].ToString("N") == Guid.ParseExact("00000000000000000000000000000000", "N").ToString("N"))
                    {
                        errorOccured = true;
                        break;
                    }

                    currentPosition++;
                }
            }

            // in case an error occured, the currentPriority is not at its possible maximum value
            if (errorOccured)
            {
                // Rollback
                foreach (var subscriberId in installations[nodeId])
                {
                    if (subscriberId.ToString("N") != Guid.ParseExact("00000000000000000000000000000000", "N").ToString("N"))
                    {
                        if (!await _Uninstall(subscriberId))
                        {
                            logger.Error("Could not deinstall subscriber");
                        }
                    }
                }

                success = false;

                // Disconnect
                await node.Disconnect();
                installations.TryRemove(nodeId, out Guid[] oldGuids);
                nodeConnections.TryRemove(nodeId, out node);
                Pool.Database.Put(database);

                return false;
            }

            if (success)
            {
                logger.Info($"Connected to {node.IPAddress}");
                await database.ControllerLog(Id, $"Connection to {node.IPAddress} established.", CancellationToken);
                await database.ControllerConnectionStatusUpdate(Id, node.Id, ControlState.Connected, CancellationToken);
            }
            else
            {
                logger.Error("Connection failed to {0}", node.IPAddress);
                await database.ControllerLog(Id, $"Connection to {node.IPAddress} failed.", CancellationToken);
            }

            Pool.Database.Put(database);

            return success;
        }

        #region Installation

        /// <summary>
        /// Installs the subscriber
        /// </summary>
        /// <param name="subscriber">Subscriber of messages</param>
        /// <returns>Returns Guid if subscriber is installed or zero-based Guid if not</returns>
        private static async Task<Guid> _Install(AbstractMessageSubscriber subscriber)
        {
            Handlers.TryAdd(subscriber.Id, subscriber);
            await subscriber.StartAsync();

            var subscriberId = Guid.ParseExact("00000000000000000000000000000000", "N");

            if (subscriber.State != SubscriberState.Running)
            {
                logger.Debug($"Handler not installed: {subscriber.Type.ToTechnicalName()}");
                Handlers.TryRemove(subscriber.Id, out AbstractSubscriber qs);
                subscriber.Dispose();
            }
            else
            {
                subscriberId = subscriber.Id;
            }

            return subscriberId;
        }

        /// <summary>
        /// Installs a handler
        /// </summary>
        /// <param name="node">Yate node id to install handler to</param>
        /// <param name="type">Type of handler</param>
        /// <param name="priority">Priority to install handler</param>
        /// <returns>Returns Guid if handler is installed or zero-based Guid if not</returns>
        private static async Task<Guid> _InstallHandler(INode node, MessageType type, int priority)
        {
            if (Handlers.Any(h => h.Value.Type == type && h.Value.Node.Equals(node)))
            {
                logger.Warn("Handler already installed.");

                return Guid.ParseExact("00000000000000000000000000000000", "N");
            }

            AbstractMessageSubscriber handler;

            switch (type)
            {
                case MessageType.EngineTimer:
                    handler = new EngineTimerSubscriber(node, priority);
                    break;

                case MessageType.CallRoute:
                    handler = new CallRouteSubscriber(node, priority);
                    break;

                case MessageType.CallCdr:
                    handler = new CallCdrSubscriber(node, priority);
                    break;

                case MessageType.CallExecute:
                    handler = new CallExecuteSubscriber(node, priority);
                    break;

                case MessageType.ChanDisconnected:
                    handler = new ChanDisconnectedSubscriber(node, priority);
                    break;

                case MessageType.ChanDtmf:
                    handler = new ChanDtmfSubscriber(node, priority);
                    break;

                case MessageType.ChanHangup:
                    handler = new ChanHangupSubscriber(node, priority);
                    break;

                case MessageType.ChanStartup:
                    handler = new ChanStartupSubscriber(node, priority);
                    break;

                case MessageType.ChanNotify:
                    handler = new ChanNotifySubscriber(node, priority);
                    break;

                default:
                    throw new NotImplementedException();
            }

            return await _Install(handler);
        }

        /// <summary>
        /// Installs a watcher
        /// </summary>
        /// <param name="node">Yate endpoint to work on</param>
        /// <param name="type">Message type to subscribe to</param>
        /// <returns>Returns Guid if watcher is installed or zero-based Guid if not</returns>
        private static async Task<Guid> _InstallWatcher(INode node, MessageType type)
        {
            if (Handlers.Any(h => h.Value.Type == type && h.Value.Node.Equals(node)))
            {
                logger.Warn("Handler already installed.");

                return Guid.ParseExact("00000000000000000000000000000000", "N");
            }

            AbstractMessageSubscriber handler;

            switch (type)
            {
                case MessageType.CallExecute:
                    handler = new CallExecuteSubscriber(node);
                    break;

                case MessageType.ChanStartup:
                    handler = new ChanStartupSubscriber(node);
                    break;

                case MessageType.ChanHangup:
                    handler = new ChanHangupSubscriber(node);
                    break;

                case MessageType.ChanRtp:
                    handler = new ChanRtpSubscriber(node);
                    break;

                default:
                    throw new NotImplementedException();
            }

            return await _Install(handler);
        }

        #endregion Installation

        /// <summary>
        /// Disconnects from Yate
        /// </summary>
        /// <param name="nodeId">Yate Id to disconnect from</param>
        /// <returns>Task to wait for until connection is disconnected</returns>
        private static async Task<bool> _Disconnect(int nodeId)
        {
            if (!IsRunning() && State != EngineState.Stopping)
            {
                return false;
            }

            var database = Pool.Database.Get();
            if (!installations.ContainsKey(nodeId))
            {
                logger.Error($"Controller is not installed on node {nodeId}");

                await database.ControllerConnectionStatusUpdate(Id, nodeId, ControlState.Disconnected, CancellationToken);
                Pool.Database.Put(database);
                return false;
            }

            var nodeInfo = await database.GetNodeConnectionInfo(nodeId, CancellationToken);
            logger.Info($"Unsubscribing from {nodeInfo.IPAddress}");
            await database.ControllerLog(Id, $"Unsubscribing from {nodeInfo.IPAddress}", CancellationToken);

            if (installations.ContainsKey(nodeId))
            {
                foreach (var subscriberId in installations[nodeId])
                {
                    if (!await _Uninstall(subscriberId))
                    {
                        logger.Error("Could not deinstall subscriber");
                    }
                }

                installations.TryRemove(nodeId, out Guid[] oldGuids);
            }

            nodeConnections.TryRemove(nodeId, out INode node);

            if (node.IsConnected)
            {
                await node.Disconnect();
            }

            logger.Info($"Disconnected from {nodeInfo.IPAddress}");

            await database.ControllerLog(Id, $"Disconnected from {nodeInfo.IPAddress}", CancellationToken);
            await database.ControllerConnectionStatusUpdate(Id, nodeInfo.Id, ControlState.Disconnected, CancellationToken);
            Pool.Database.Put(database);

            return true;
        }

        /// <summary>
        /// Stops a message handler
        /// </summary>
        /// <param name="id">Handler ID</param>
        /// <returns>Task to wait for until uninstallation ended successfully or not</returns>
        private static async Task<bool> _Uninstall(Guid id)
        {
            if (!Handlers.ContainsKey(id) || !(Handlers[id] is AbstractMessageSubscriber))
            {
                logger.Warn("Handler not installed");
                return false;
            }

            if (!Handlers.ContainsKey(id))
            {
                return true;
            }

            await lockUninstallation.WaitAsync();

            var handler = Handlers[id] as AbstractMessageSubscriber;

            if (handler.State > SubscriberState.Paused)
            {
                lockUninstallation.Release();
                return true;
            }

            logger.Debug($"Uninstalling handler {handler.Type.ToTechnicalName()}");

            await handler.StopAsync();
            Handlers.TryRemove(id, out AbstractSubscriber qs);

            // Check if other handlers of this type are installed, if not, remove the cached worker objects
            if (Handlers.Count(h => h.Value.Type == handler.Type) == 0)
            {
                switch (handler.Type)
                {
                    case MessageType.CallRoute:
                        Pool.RouteMessageWorkers.ClearUnused();
                        break;

                    case MessageType.CallCdr:
                        Pool.CdrMessageWorkers.ClearUnused();
                        break;

                    case MessageType.EngineTimer:
                        Pool.EngineTimerMessageWorkers.ClearUnused();
                        break;

                    default:
                        break;
                }
            }

            handler.Dispose();

            logger.Debug($"Uninstalling handler done {handler.Type.ToTechnicalName()}");

            lockUninstallation.Release();

            return true;
        }

        #endregion Installation / Deinstallation

        #region Connection to Yate

        /// <summary>
        /// Checks if node exists and establishes a connection
        /// </summary>
        /// <param name="nodeId">Id of Yate node</param>
        /// <returns>Task to wait for until Node is connected and connection is registered</returns>
        private static async Task<INode> _GetConnectedAndRegisteredNode(int nodeId)
        {
            logger.Debug("Checking if Node exists.");

            INode node;

            SemaphoreSlim waiter;
            lock (lockConnecting)
            {
                lockConnecting.TryGetValue(nodeId, out waiter);

                if (waiter == null)
                {
                    waiter = new SemaphoreSlim(1, 1);

                    lockConnecting.TryAdd(nodeId, waiter);
                }
            }

            await waiter.WaitAsync();

            if (!nodeConnections.ContainsKey(nodeId) || !nodeConnections[nodeId].IsConnected)
            {
                // Move connection to old connections for close and cleanup
                if (nodeConnections.ContainsKey(nodeId) && !nodeConnections[nodeId].IsConnected)
                {
                    nodeConnectionsOld.TryAdd(nodeId, nodeConnections[nodeId]);

                    nodeConnections.TryRemove(nodeId, out node);
                    node = null;
                }

                node = await _GetConnectedNode(nodeId);

                if (node != null && !nodeConnections.TryAdd(nodeId, node))
                {
                    logger.Error("Could not add Yate connection to connection pool.");

                    if (nodeConnections.ContainsKey(node.Id))
                    {
                        try
                        {
                            TaskHelper.RunInBackground(async () => { var n = node; await n.Disconnect(); n.Dispose(); });
                        }
                        catch { }

                        if (!nodeConnections.TryGetValue(nodeId, out node))
                        {
                            node = null;
                        }
                    }
                }
            }
            else
            {
                if (!nodeConnections.TryGetValue(nodeId, out node))
                {
                    logger.Error("Could not get Yate connection from connection pool.");
                    node = null;
                }
            }

            waiter.Release();

            lock (lockConnecting)
            {
                if (waiter.CurrentCount == 1)
                {
                    lockConnecting.TryRemove(nodeId, out waiter);
                    waiter.Dispose();
                }
            }

            return node;
        }

        /// <summary>
        /// Returns an connected node
        /// </summary>
        /// <param name="nodeId">Id of Yate node</param>
        /// <returns>Task to wait for until Node is connected</returns>
        private static async Task<Node> _GetConnectedNode(int nodeId)
        {
            var database = Pool.Database.Get();
            var nodeInfo = await database.GetNodeConnectionInfo(nodeId, CancellationToken);
            Pool.Database.Put(database);

            if (nodeInfo == null)
            {
                logger.Debug($"Node (Id: {nodeId}) does not exist in Database.");
                return null;
            }

            logger.Debug($"Node (Id: {nodeId}) exists.");

            var node = new Node(nodeInfo.IPAddress, nodeInfo.Port, nodeInfo.Id, nodeInfo.CriticalLoadThreshold);

            logger.Info($"Connecting to {node.IPAddress}");

            if (!await node.Connect(messageBuffer))
            {
                logger.Error($"Cannot connect to Node {nodeInfo.IPAddress}.");
                return null;
            }

            return node;
        }

        #endregion Connection to Yate

        #region Miscellaneous

        /// <summary>
        /// Returns true if message type is registered as watcher
        /// </summary>
        /// <param name="messageType">Message type to check</param>
        /// <returns>True if is watcher, else false</returns>
        internal static bool IsWatcher(MessageType messageType) => requiredWatchers.Contains(messageType);

        /// <summary>
        /// Returns node performance information
        /// </summary>
        /// <returns></returns>
        internal static IEnumerable<NodePerformance> GetNodePerformance()
        {
            var list = new List<NodePerformance>();

            foreach (var node in nodeConnections.ToList())
            {
                var latest = node.Value.PerformanceInformation.OrderByDescending(pi => pi.RecordedOn).FirstOrDefault();

                if (null == latest)
                {
                    latest = Yate.Model.PerformanceInformation.Parse("-1", node.Value.ProcessingPercentage);
                }

                var nodePerformance = new NodePerformance()
                {
                    NodeId = node.Key,
                    LastEngineTime = node.Value.LatestEngineTime,
                    CpuCount = latest.CpuCount,
                    CpuUser = latest.CpuUser,
                    CpuNice = latest.CpuNice,
                    CpuSystem = latest.CpuSystem,
                    CpuIdle = latest.CpuIdle,
                    CpuIoWait = latest.CpuIoWait,
                    CpuHardIrq = latest.CpuHardIrq,
                    CpuSoftIrq = latest.CpuSoftIrq,
                    MemoryFree = latest.MemoryFree,
                    MemoryUsed = latest.MemoryUsed,
                    MemoryTotal = latest.MemoryTotal,
                    SwapFree = latest.SwapFree,
                    SwapUsed = latest.SwapUsed,
                    SwapTotal = latest.SwapTotal,
                    ProcessingPercentage = latest.ProcessingPercentage,
                    RecordedOn = latest.RecordedOn
                };

                list.Add(nodePerformance);
            }

            return list;
        }

        /// <summary>
        /// Closes and cleans up node connection
        /// </summary>
        /// <param name="node"></param>
        /// <returns></returns>
        private static async Task _CloseAndCleanup(INode node)
        {
            // remove, then shut down
            nodeConnections.TryRemove(node.Id, out INode con);

            // Request connect in database
            var database = Pool.Database.Get();
            await database.ControllerConnectionStatusUpdate(Id, node.Id, ControlState.ConnectRequested, CancellationToken).ConfigureAwait(false);
            Pool.Database.Put(database);

            // Remove and terminate old connection
            installations.TryRemove(node.Id, out Guid[] oldGuids);

            foreach (var oldGuid in oldGuids)
            {

                Handlers.TryRemove(oldGuid, out AbstractSubscriber subscriber);

                subscriber.Stop();
                subscriber = null;
            }

            var address = con.IPAddress;
            try
            {
                await con.Disconnect().ConfigureAwait(false);
                con.Dispose();
            }
            catch
            {
                logger.Error($"Connection to {address} broke and was removed.");
            }

            con = null;
        }

        #endregion

        #region Message Buffer Action

        /// <summary>
        /// Function to be used to process a message in the <see cref="messageBuffer"/>
        /// </summary>
        /// <param name="message">See <see cref="Message"/></param>
        /// <returns></returns>
        private static async Task _ProcessMessage(Message message)
        {
            // check time message waited and warn if necessary
            if (message.WaitingTime.ElapsedMilliseconds > waitingTimeWarningThreshold && (!lastWarningEmitted.HasValue || lastWarningEmitted.Value < DateTime.UtcNow.AddMinutes(-1)))
            {
                TaskHelper.RunInBackground(async () =>
                {
                    var db = Pool.Database.Get();
                    await db.ControllerLog(Core.Id, $"Waiting Time Threshold hit, current message delayed for {Math.Round(message.WaitingTime.Elapsed.TotalSeconds, 1)}s", Core.CancellationToken);
                    Pool.Database.Put(db);
                });

                lastWarningEmitted = DateTime.UtcNow;
            }

            // check if message has to be skipped due to load
            if (message.CanBeCancelled && PerformanceInformation.LoadIsCritical)
            {
                message.CancelCallRouteMessage();
                message.Node.Send(message);
                return;
            }

            message.SetupCancellationToken(yateMaximumWaitingTime);
            await Dispatcher.Process(message).ConfigureAwait(false);
        }

        #endregion

        #endregion Functions

        #region Jobs

        /// <summary>
        /// Signals that the controller is working
        /// </summary>
        [AutomaticJob(2000)]
        private static async Task SignalAlive(IDatabase database)
        {
            var cancellationTokenSource = new CancellationTokenSource();
#if !DEBUG
            cancellationTokenSource.CancelAfter(5000);
#endif

            await database.ControllerIsAlive(Core.Id, cancellationTokenSource.Token);
        }

        /// <summary>
        /// Updates the cache
        /// </summary>        
        [AutomaticJob(5000)]
        private static async Task CacheUpdate()
        {
            if (!Cache.Updating)
            {
                // every 5th run update complete cache (approx. every 30 seconds, timer elapses every 5 seconds)
                bool limitsOnly = (++updateCounter % 5 != 0);

                await Cache.Update(limitsOnly);
            }
        }

        /// <summary>
        /// Updates the customer limits
        /// </summary>
        [AutomaticJob(2000)]
        private static async Task LimitUpdate(IDatabase database)
        {
            var cancellationTokenSource = new CancellationTokenSource();
#if !DEBUG
            cancellationTokenSource.CancelAfter(5000);
#endif

            await database.EndpointCreditUpdate(cancellationTokenSource.Token);
        }

        /// <summary>
        /// Monitors the controller and node performance
        /// </summary>
        [AutomaticJob(2000)]
        private static async Task PerformanceMonitoring(IDatabase database)
        {
            foreach (var node in Core.nodeConnections.Where(n => n.Value.IsConnected).ToList())
            {
                var tmpNode = node;

                var cancellationTokenSource = new CancellationTokenSource();
#if !DEBUG
                cancellationTokenSource.CancelAfter(5000);
#endif

                var criticalLoad = await database.GetNodeInfo(tmpNode.Key, cancellationTokenSource.Token);
                tmpNode.Value.SetCriticalLoad(criticalLoad);

                int processingPercentage = -1;
                try
                {
                    processingPercentage = tmpNode.Value.ProcessingPercentage;
                }
                catch { }

                var performance = await QueryParameterAsync(tmpNode.Key, CarrierLinkParameter.Performance);

                Yate.Model.PerformanceInformation pi;
                if (performance.Success)
                {
                    pi = Yate.Model.PerformanceInformation.Parse(performance.Result, processingPercentage);
                }
                else
                {
                    pi = Yate.Model.PerformanceInformation.Parse("-1", processingPercentage);
                }

                try
                {
                    if (Core.nodeConnections.TryGetValue(tmpNode.Key, out INode inode))
                    {
                        inode.AddPerformance(pi);
                    }
                }
                catch
                { }
            }
        }

        /// <summary>
        /// Updates Cache Number Gateway Statistics
        /// </summary>
        /// <param name="database"></param>
        /// <returns></returns>
        [AutomaticJob(30000)]
        private static async Task UpdateCacheNumberGatewayStatistics(IDatabase database)
        {
            var cancellationTokenSource = new CancellationTokenSource();
#if !DEBUG
            cancellationTokenSource.CancelAfter(25000);
#endif

            await database.NumberGatewayStatisticsUpdate(cancellationTokenSource.Token);
        }

        #endregion
    }
}