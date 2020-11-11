namespace CarrierLink.Controller.Engine.Workers
{
    using Caching;
    using NLog;
    using Subscribers;
    using System;
    using System.Linq;
    using System.Threading.Tasks;
    using Yate.Messaging;

    /// <summary>
    /// Receives incoming messages and dispatches them to the appropriate handler/watcher/worker
    /// </summary>
    public static class Dispatcher
    {
        #region Fields

        /// <summary>
        /// Current Logger
        /// </summary>
        private static Logger logger;

        #endregion Fields

        #region Constructor

        /// <summary>
        /// Initializes the static class
        /// </summary>
        static Dispatcher()
        {
            logger = LogManager.GetCurrentClassLogger();
        }

        #endregion

        #region Functions

        /// <summary>
        /// Performs message processing
        /// </summary>
        /// <param name="message">Yate message</param>
        /// <returns>Task to await while processing</returns>
        public static async Task Process(Message message)
        {
            // Stop waiting, start processing stopwatch            
            message.WaitingTime.Stop();

            IWorker worker;

            if (message.MessageDirection == MessageDirection.IncomingRequest || message.MessageDirection == MessageDirection.IncomingAnswer)
            {
                var messageClass = message.IncomingSplittedMessage[0].Substring(3);

                if (messageClass == "message")
                {
                    // Categorize message
                    MessageType type;
                    try
                    {
                        type = Pool.MessageTypes.ToType(message.IncomingSplittedMessage[3]);
                    }
                    catch (Exception ex)
                    {
                        logger.ConditionalDebug("Message Type not found: " + message.IncomingSplittedMessage[3] + " " + ex.Message);
                        return;
                    }

                    message.SetMessageType(type);

                    // Stop message processing, only needed for CallRoute messages
                    if (type == MessageType.CallRoute)
                    {
                        message.ProcessingTime.Start();
                    }

                    // Get worker from Cache
                    switch (message.MessageType)
                    {
                        case MessageType.CallCdr:
                            worker = Pool.CdrMessageWorkers.Get();
                            break;

                        case MessageType.CallRoute:
                            worker = Pool.RouteMessageWorkers.Get();
                            break;

                        case MessageType.EngineTimer:
                            worker = Pool.EngineTimerMessageWorkers.Get();
                            break;

                        case MessageType.MonitorQuery:
                            // Find handler and set value
                            foreach (var handler in Core.Handlers.ToList())
                            {
                                if (handler.Value is MonitorQuerySubscriber)
                                {
                                    ((IManage)handler.Value).Manage(message);
                                    break;
                                }
                            }

                            // return immediately
                            return;

                        case MessageType.CarrierLinkNode:
                            // Find handler and set value
                            foreach (var handler in Core.Handlers.ToList())
                            {
                                if (handler.Value is CarrierLinkQuerySubscriber)
                                {
                                    ((IManage)handler.Value).Manage(message);
                                    break;
                                }
                            }

                            // return immediately
                            return;

                        default:
                            // Do not answer unhandled messages if they are for watchers
                            if (Core.IsWatcher(message.MessageType))
                            {
                                return;
                            }

                            // Answer unhandled messages
                            if (message.MessageDirection == MessageDirection.IncomingRequest)
                            {
                                message.SetOutgoing(message.Node, MessageDirection.OutgoingAnswer, $"message:{message.MessageId}:{false.ToString(Formats.CultureInfo).ToLowerInvariant()}:{Pool.MessageTypes.ToString(message.MessageType)}::");

                                message.Node.Send(message);
                            }

                            return;
                    }

                    // Setup and processing
                    var outgoingMessage = await worker.ProcessAsync(message, Core.State == EngineState.Running);

                    // Answer if timeout is not hit
                    if (!message.CancellationToken.IsCancellationRequested)
                    {
                        outgoingMessage.Node.Send(outgoingMessage);
                    }

                    // Put worker back to Cache
                    switch (message.MessageType)
                    {
                        case MessageType.CallCdr:
                            Pool.CdrMessageWorkers.Put(worker as CallCdrWorker);
                            break;

                        case MessageType.CallRoute:
                            Pool.RouteMessageWorkers.Put(worker as CallRouteWorker);
                            break;

                        case MessageType.EngineTimer:
                            Pool.EngineTimerMessageWorkers.Put(worker as EngineTimerWorker);
                            break;

                        default:
                            return;
                    }
                }
                else if (messageClass == "install" ||
                    messageClass == "uninstall" ||
                    messageClass == "watch" ||
                    messageClass == "unwatch")
                {
                    // Categorize message
                    int posOfSuccess = 0;
                    switch (messageClass)
                    {
                        case "install":
                        case "uninstall":
                            posOfSuccess = 2;
                            break;

                        case "watch":
                        case "unwatch":
                            posOfSuccess = 1;
                            break;

                        default:
                            throw new ArgumentException("Subscriber Type unknown.");
                    }

                    message.SetMessageType(Pool.MessageTypes.ToType(message.IncomingSplittedMessage[posOfSuccess]));

                    var targetHandler = Core.Handlers.Values.ToList().Where(handler => handler.Node.Id == message.Node.Id && handler.Type == message.MessageType).FirstOrDefault();

                    if (targetHandler != null)
                    {
                        if (targetHandler is IManage)
                        {
                            ((IManage)targetHandler).Manage(message);
                        }
                    }
                }
                else if (messageClass == "setlocal")
                {
                    if (message.IncomingSplittedMessage[1].StartsWith("config."))
                    {
                        // There can only be one ConfigurationMessageHandler at a time
                        foreach (var handler in Core.Handlers.ToList())
                        {
                            if (handler.Value is EngineConfigurationSubscriber)
                            {
                                ((IManage)handler.Value).Manage(message);
                                break;
                            }
                        }
                    }
                    else
                    {
                        // There can only be one EngineMessageHandler at a time
                        foreach (var handler in Core.Handlers.ToList())
                        {
                            if (handler.Value is EngineParameterSubscriber)
                            {
                                ((IManage)handler.Value).Manage(message);
                                break;
                            }
                        }
                    }
                }
            }
            else
            {
                // Send message to yate
                message.Node.Send(message);
            }
        }

        #endregion Functions
    }
}