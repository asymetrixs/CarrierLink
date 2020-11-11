namespace CarrierLink.Controller.Engine.Workers
{
    using Caching;
    using Caching.Model;
    using Caching.Routing;
    using Model;
    using System;
    using System.Collections.Generic;
    using System.Linq;
    using System.Text.RegularExpressions;
    using System.Threading.Tasks;
    using Yate;
    using Yate.Messaging;

    /// <summary>
    /// This class handles call.route messages
    /// </summary>
    public class CallRouteWorker : AbstractAnswerWorker, IWorker
    {
        #region Fields

        /// <summary>
        /// Regex matching a proper phone number
        /// </summary>
        private const string PHONE_NUMBER_REGEX = @"[\d]+";

        /// <summary>
        /// Default timeout for a call
        /// </summary>
        private const string DEFAULT_TIMEOUT = "7200000";

        /// <summary>
        /// Holds the time in ms before the call is cancelled with 'no answer'
        /// </summary>
        private const string MAXCALL = "65000";

        /// <summary>
        /// Counts the amount of blending destinations
        /// </summary>
        private int blended = 0;

        /// <summary>
        /// Holds the called number splitted to use in database lookups for performance in the worker
        /// </summary>
        private string[] calledSplitted;

        /// <summary>
        /// Holds the REGEXP to clean the called numer
        /// </summary>
        private Regex cleanupNumber;

        /// <summary>
        /// Indicates whether message was handled or not
        /// </summary>
        private bool isHandled;

        /// <summary>
        /// Holds information about the called number
        /// </summary>
        private DialcodeMaster numberInfo;

        /// <summary>
        /// Random number generator
        /// </summary>
        private Random random;

        /// <summary>
        /// Contains all routed contexts and is used to exit if a loop occurs
        /// </summary>
        private List<Context> routedContexts = new List<Context>(2);

        /// <summary>
        /// Describes the routing tree
        /// </summary>
        private Utilities.RoutingTree.Root routingTree;

        #endregion Fields

        #region Yate Fields

        #region Default Yate Fields

        /// <summary>
        /// Default Yate Field: address
        /// </summary>
        private string yAddress;

        /// <summary>
        /// Default Yate Field: billid
        /// </summary>
        private string yBillId;

        /// <summary>
        /// Default Yate Field: called
        /// </summary>
        private string yCalled;

        /// <summary>
        /// Default Yate Field: caller
        /// </summary>
        private string yCaller;

        /// <summary>
        /// Default Yate Field: callername
        /// </summary>
        private string yCallername;

        /// <summary>
        /// Default Yate Field: error
        /// </summary>
        private string yError;

        /// <summary>
        /// Default Yate Field: fork.automessage
        /// </summary>
        private string yForkAutoMessage;

        /// <summary>
        /// Default Yate Field: fork.autoring
        /// </summary>
        private string yForkAutoRing;

        /// <summary>
        /// Default Yate Field: fork.calltype
        /// </summary>
        private string yForkCallType;

        /// <summary>
        /// Default Yate Field: fork.ringer
        /// </summary>
        private string yForkRinger;

        /// <summary>
        /// Default Yate Field: location
        /// </summary>
        private string yLocation;

        /// <summary>
        /// Default Yate Field: reason
        /// </summary>
        private string yReason;

        #endregion Default Yate Fields

        #region CarrierLink Yate Properties

        /// <summary>
        /// CarrierLink Yate Field: clcustomercurrency
        /// </summary>
        private string clCustomerRateCurrency;

        /// <summary>
        /// CarrierLink Yate Field: clcustomerrateid
        /// </summary>
        private long? clCustomerRateId;

        /// <summary>
        /// CarrierLink Yate Field: clcustomerratepermin
        /// </summary>
        private decimal? clCustomerRatePerMin;

        /// <summary>
        /// CarrierLink Yate Field: clgatewayid
        /// </summary>
        private string clGatewayId;

        /// <summary>
        /// CarrierLink Yate Field: clprocessingtime
        /// </summary>
        private string clProcessingTime;

        /// <summary>
        /// CarrierLink Yate Field: clsender
        /// </summary>
        private string clSender;

        /// <summary>
        /// CarrierLink Yate Field: cltrackingid
        /// </summary>
        private string clTrackingId;

        /// <summary>
        /// CarrierLink Yate Field: clwaitingtime
        /// </summary>
        private string clWaitingTime;

        #endregion CarrierLink Yate Properties

        #region Routing Properties

        /// <summary>
        /// The customer who calles
        /// </summary>
        private Customer rfCustomer;

        /// <summary>
        /// Called without Prefix
        /// </summary>
        private string rfCustomerCalled;

        /// <summary>
        /// Sender IP
        /// </summary>
        private string rfSenderIP;

        #endregion Routing Properties

        /// <summary>
        /// List of possible routes to finally route the call
        /// </summary>
        private List<Model.Route> routes;

        #endregion Yate Fields

        #region Constructor

        /// <summary>
        /// Initializes a new instance of the <see cref="CallRouteWorker"/> class
        /// </summary>
        internal CallRouteWorker()
        {
            // See also:
            // http://blogs.msdn.com/b/bclteam/archive/2004/11/12/256783.aspx
            // http://msdn.microsoft.com/en-us/library/gg578045(v=vs.110).aspx
            this.cleanupNumber = new Regex(PHONE_NUMBER_REGEX,
                RegexOptions.CultureInvariant
                | RegexOptions.Compiled
                | RegexOptions.IgnoreCase, new TimeSpan(0, 0, 1));

            this.random = new Random((int)DateTime.Now.Ticks);
        }

        #endregion Constructor

        #region Methods

        /// <summary>
        /// Starts the processing of the Yate-Message
        /// </summary>
        /// <param name="message">The Message coming from Yate</param>
        /// <param name="isRunning">Indicating if service is running</param>
        /// <returns>Processes message</returns>
        async Task<Message> IWorker.ProcessAsync(Message message, bool isRunning)
        {
            this.Initialize(message, isRunning);

            this.yLocation = "fork"; // default
            this.routes = new List<Model.Route>(6); // default size, expecting 6 records

            this._Parse();

            this.routingTree = new Utilities.RoutingTree.Root();

            if (this.IsRunning)
            {
                if (!this.Message.CancellationToken.IsCancellationRequested)
                {
                    this._Preroute();
                }

                if (!this.isHandled && !this.Message.CancellationToken.IsCancellationRequested)
                {
                    await this._RouteAsync();
                }
                else
                {
                    this.routingTree.Context.AddRoutingAction(Utilities.RoutingTree.ContextAction.Cancelled);
                }

                if (!this.Message.CancellationToken.IsCancellationRequested)
                {
                    this._Acknowledge();
                }
            }
            else
            {
                if (!this.Message.CancellationToken.IsCancellationRequested)
                {
                    this.isHandled = false;
                    this._Acknowledge();
                }
            }

            this.Reset();

            return this.Message;
        }

        /// <summary>
        /// Returns the original message that caused an error
        /// </summary>
        /// <returns>Returns original yate message</returns>
        public override string ToString() => this.OriginalMessage;

        /// <summary>
        /// Resets all fields of this instance
        /// </summary>
        internal void Reset()
        {
            this.yBillId = string.Empty;
            this.yError = string.Empty;
            this.yReason = string.Empty;
            this.yAddress = string.Empty;
            this.yLocation = string.Empty;
            this.yForkCallType = string.Empty;
            this.yForkAutoRing = string.Empty;
            this.yForkAutoMessage = string.Empty;
            this.yForkRinger = string.Empty;
            this.yCalled = string.Empty;
            this.yCaller = string.Empty;
            this.yCallername = string.Empty;

            this.clCustomerRateCurrency = string.Empty;
            this.clCustomerRateId = null;
            this.clCustomerRatePerMin = null;
            this.clSender = string.Empty;
            this.clTrackingId = string.Empty;
            this.clGatewayId = string.Empty;
            this.clProcessingTime = string.Empty;

            this.clSender = string.Empty;

            this.rfCustomerCalled = string.Empty;
            this.rfSenderIP = string.Empty;
            this.rfCustomer = null;

            this.calledSplitted = null;

            this.numberInfo = null;

            this.routedContexts.Clear();

            this.routes.Clear();

            this.routingTree = null;

            this.blended = 0;
        }

        /// <summary>
        /// Acknowledges the call by sending valid prerouting information
        /// </summary>
        protected override void _Acknowledge()
        {
            // Check if only one route with TARGET ringing and remove
            if (this.routes.Count == 1 && this.routes.ElementAt(0).YTARGET == "tone/ring")
            {
                this.routes.Clear();
            }

            // Final routing string for yate
            string result = string.Empty;

            // Final Check: if no routes and error is not set, send 480: Temporarily Unavailable
            if (this.routes.Count == 0 && string.IsNullOrEmpty(this.yError))
            {
                this._CancelCall(ErrorCode.TemporarilyUnavailable, this.routingTree.Context);
            }

            // remove last RouteControl
            if (this.routes.Any() && this.routes.Last() is RouteControl)
            {
                this.routes.RemoveAt(this.routes.Count - 1);
            }

            this.clWaitingTime = this.Message.WaitingTime.ElapsedMilliseconds.ToString(Formats.CultureInfo);
            this.Message.ProcessingTime.Stop();
            this.clProcessingTime = this.Message.ProcessingTime.ElapsedMilliseconds.ToString(Formats.CultureInfo);

            // Clear to populate in correct order again
            this.routingTree.GatewayOrder.Clear();

            if (this.routes.Count <= 1)
            {
                result = string.Format(Formats.CultureInfo,
                    MessageTemplates.ROUTE_ACKNOWLEDGE_NO_FORK,
                    this.MessageID,
                    this.isHandled.ToString(Formats.CultureInfo).ToLowerInvariant(),
                    this.yError,
                    this.yReason,
                    this.Message.Node.Id.ToString(Formats.CultureInfo),
                    this.rfCustomer?.Id,
                    this.rfCustomer?.CustomerIPId.ToString(Formats.CultureInfo),
                    this.clTrackingId,
                    this.clProcessingTime,
                    this.clCustomerRateId?.ToString(Formats.CultureInfo),
                    this.clCustomerRatePerMin?.ToString(Formats.DecimalToString, Formats.CultureInfo),
                    this.clCustomerRateCurrency,
                    this.numberInfo?.DialcodeMasterId.ToString(Formats.CultureInfo),
                    this.clWaitingTime
                    );

                if (this.routes.Count == 1)
                {
                    var routeCall = this.routes[0] as RouteCall;

                    if (routeCall == null)
                    {
                        return;
                    }

                    // Add Gateway to get the final order and prevent multiple calls flowing to this gateway
                    this.routingTree.AddGatewayId(int.Parse(string.IsNullOrEmpty(routeCall.CLGatewayID) ? routeCall.OSIPGatewayID : routeCall.CLGatewayID));

                    // Append route information
                    result = string.Concat(result,
                        string.Format(Formats.CultureInfo,
                        MessageTemplates.ROUTE_ACKNOWLEDGE_NO_FORK_ROUTE,
                        CharacterCoding.Encode(this.routes[0].YTARGET),
                        routeCall.YCalled,
                        routeCall.YCaller,
                        routeCall.YCallername,
                        routeCall.YFormat,
                        routeCall.YFormats,
                        routeCall.YLine,
                        routeCall.YMaxCall,
                        routeCall.OSIPPAssertedIdentity,
                        routeCall.OSIPGatewayID,
                        routeCall.OSIPTrackingID,
                        routeCall.YRTPAddr,
                        routeCall.YRTPForward,
                        routeCall.YRTPPort,
                        routeCall.YOConnectionID,
                        routeCall.CLGatewayID,
                        routeCall.CLGatewayAccountID,
                        routeCall.CLGatewayIPID,
                        CharacterCoding.Encode(routeCall.CLTechCalled),
                        routeCall.CLGatewayRateId,
                        routeCall.CLGatewayRatePerMin,
                        routeCall.CLGatewayCurrency,
                        routeCall.YTimeout
                        ));
                }
            }
            else
            {
                result = string.Format(Formats.CultureInfo,
                    MessageTemplates.ROUTE_ACKNOWLEDGE_FORK,
                    this.MessageID,
                    this.isHandled.ToString(Formats.CultureInfo).ToLowerInvariant(),
                    this.yError,
                    this.yReason,
                    this.yLocation,
                    this.yForkCallType,
                    this.yForkAutoRing,
                    this.yForkAutoMessage,
                    this.yForkRinger,
                    this.Message.Node.Id.ToString(Formats.CultureInfo),
                    this.rfCustomer.Id,
                    this.rfCustomer.CustomerIPId.ToString(Formats.CultureInfo),
                    this.clTrackingId,
                    this.clProcessingTime,
                    this.clCustomerRateId?.ToString(Formats.CultureInfo),
                    this.clCustomerRatePerMin?.ToString(Formats.DecimalToString, Formats.CultureInfo),
                    this.clCustomerRateCurrency,
                    this.numberInfo?.DialcodeMasterId.ToString(Formats.CultureInfo),
                    this.clWaitingTime
                    );

                var routesSb = Pool.StringBuilders.Get();
                int callToNo = 1;
                foreach (var route in this.routes)
                {
                    if (route is RouteControl)
                    {
                        routesSb.Append(string.Format(Formats.CultureInfo,
                            MessageTemplates.ROUTE_ACKNOWLEDGE_LOCATION,
                            callToNo,
                            route.YTARGET
                            ));
                    }
                    else
                    {
                        var routeCall = route as RouteCall;

                        // Add Gateway to get the final order and prevent multiple calls flowing to this gateway
                        this.routingTree.AddGatewayId(int.Parse(string.IsNullOrEmpty(routeCall.CLGatewayID) ? routeCall.OSIPGatewayID : routeCall.CLGatewayID));

                        routesSb.Append(string.Format(Formats.CultureInfo,
                            MessageTemplates.ROUTE_ACKNOWLEDGE_CALL_TO,
                            callToNo,
                            CharacterCoding.Encode(route.YTARGET),
                            routeCall.YCalled,
                            routeCall.YCaller,
                            routeCall.YCallername,
                            routeCall.YFormat,
                            routeCall.YFormats,
                            routeCall.YLine,
                            routeCall.YMaxCall,
                            routeCall.OSIPPAssertedIdentity,
                            routeCall.OSIPGatewayID,
                            routeCall.OSIPTrackingID,
                            routeCall.YRTPAddr,
                            routeCall.YRTPForward,
                            routeCall.YRTPPort,
                            routeCall.YOConnectionID,
                            routeCall.CLGatewayID,
                            routeCall.CLGatewayAccountID,
                            routeCall.CLGatewayIPID,
                            CharacterCoding.Encode(routeCall.CLTechCalled),
                            routeCall.CLGatewayRateId,
                            routeCall.CLGatewayRatePerMin,
                            routeCall.CLGatewayCurrency,
                            routeCall.CLDecision,
                            routeCall.YTimeout
                            ));
                    }

                    callToNo++;
                }

                result = string.Concat(result, routesSb.ToString());
                routesSb.Clear();
                Pool.StringBuilders.Put(routesSb);
            }

            /// Cache routing tree information for usage in <see cref="CallCdrWorker"/> 
            LiveCache.AddOrReplace($"routingTree-{this.Node.Id}-{this.yBillId}", this.routingTree);

            this.Message.SetOutgoing(this.Node, MessageDirection.OutgoingAnswer, result);
        }

        /// <summary>
        /// Cancels the call by sending an error message
        /// </summary>
        /// <param name="code">SIP Error Code</param>
        /// <param name="rtContext">Routing Tree Context</param>
        private void _CancelCall(ErrorCode code, Utilities.RoutingTree.Context rtContext)
        {
            rtContext.AddRoutingAction(Utilities.RoutingTree.ContextAction.Cancelled);
            this.yError = ((int)code).ToString(Formats.CultureInfo);
            this.yLocation = string.Empty;
            this.isHandled = true;
        }

        /// <summary>
        /// Fixes callername issues like unknown characters, invalid characters
        /// </summary>
        /// <param name="caller">Caller number</param>
        /// <returns>Returns corrected caller</returns>
        private string _CorrectCallerAndCallername(string caller)
        {
            if (caller.Contains('[') || caller.Contains(']'))
            {
                caller = "anonymous";
            }
            else
            {
                caller = caller.Replace(" ", string.Empty);

                if (string.IsNullOrEmpty(caller))
                {
                    caller = "anonymous";
                }
                else
                {
                    caller = Cache.ReplaceIncorrectCallername(caller);
                }
            }

            return caller;
        }

        /// <summary>
        /// Routes the call to a specific Gateway or a Node if the gateway is not accessible
        /// </summary>
        /// <param name="gateway">The Gateway</param>
        /// <param name="gatewayRateId">The Gateway Rate Id</param>
        /// <param name="gatewayRatePerMin">The Gateway Rate Per Min</param>
        /// <param name="gatewayRateCurrency">The Gateway Rate Currency</param>
        /// <param name="action">Least Cost Routing or Fixed Route Routing</param
        /// <param name="timeout">Call timeout</param>
        /// <param name="called">Modified called number</param>
        /// <param name="rtGateway">Routing Tree Gateway</param>
        /// <param name="blending">Indicates if blending is active or not</param>
        /// <returns>Returns if routing was successful</returns>
        private bool _InternalRouteNodeToGateway(Gateway gateway, long? gatewayRateId, decimal? gatewayRatePerMin, string gatewayRateCurrency,
            Caching.Routing.Action action, string timeout, string called, Utilities.RoutingTree.Gateway rtGateway, bool blending)
        {

            if (!Cache.GetGatewayListForNodeId(this.Message.Node, out List<int> gateways))
            {
                rtGateway.AddReason(Utilities.RoutingTree.Reason.CacheMiss);
                return false;
            }

            // Check Limits
            if (Cache.IsGatewayLimitExceeded(gateway))
            {
                rtGateway.AddReason(Utilities.RoutingTree.Reason.LimitExceeded);
                return false;
            }

            // If node can access gateway
            bool hasAccess = false;
            if (gateways.Contains(gateway.Id))
            {
                rtGateway.SetEndpoint(Utilities.RoutingTree.TargetType.Gateway);
                hasAccess = this._RouteToGateway(gateway, gatewayRateId, gatewayRatePerMin, gatewayRateCurrency, action, timeout, called, rtGateway as Utilities.RoutingTree.Gateway, blending);
            }
            else
            {
                var rtNode = new Utilities.RoutingTree.Node();
                rtGateway.ViaNode(rtNode);
                hasAccess = this._RouteToNode(gateway, action, timeout, rtNode, rtGateway, blending);
            }

            return hasAccess;
        }

        /// <summary>
        /// Makes Yate wait between call attempts to gateways
        /// </summary>
        /// <param name="context">Routing Context</param>
        /// <param name="blending">Indicates if blending is active or not</param>
        private void _InternalRouteNodeToGatewayWaiter(Context context, bool blending)
        {
            var tn = context.ForkConnectBehavior.ToTechnicalName();

            if (!string.IsNullOrEmpty(tn))
            {
                var rc = new RouteControl()
                {
                    YTARGET = $"{tn}{(tn.Length > 1 ? context.ForkConnectBehaviorTimeout.ToString() : default(string))}"
                };

                if (!blending)
                {
                    this.routes.Add(rc);
                }
                else if (blending && this.blended > 0)
                {
                    this.routes.Insert(this.blended, rc);
                    this.blended++;
                }
            }
        }

        /// <summary>
        /// Checks the routing rules and decides if the call is routed by LeastCostRouting, Fixed Route Routing or rejected
        /// </summary>
        /// <param name="context">Routing Context</param>
        /// <param name="rtContext">Routing Tree Context</param>
        /// <returns>Returns Routing Rules Result Set</returns>
        private async Task<Result> _InternalRoutingRulesAsync(Context context, Utilities.RoutingTree.Context rtContext)
        {
            var routingRulesResult = new Result();
            routingRulesResult.SetCustomerInformation(this.rfCustomer, await Cache.GetRateForCustomer(this.rfCustomer.Id, this.calledSplitted, this.Time,
                this.Message.CancellationToken).ConfigureAwait(false));

            // Check if has route
            routingRulesResult.SetRoute(Cache.GetRouteForContext(context, this.yCalled));

            if (routingRulesResult.HasRoute)
            {
                if (!Cache.GetTargetsForRoute(routingRulesResult.Route, out List<RouteTarget> routeTargets))
                {
                    this._CancelCall(ErrorCode.TemporarilyUnavailable, rtContext);
                    routingRulesResult.Decision = Caching.Routing.Action.Forbidden;
                    return routingRulesResult;
                }

                routingRulesResult.Route.AddTargets(routeTargets);
            }

            routingRulesResult.SetContext(context);

            routingRulesResult.Decision = Decision.Decide(routingRulesResult, context);

            return routingRulesResult;
        }

        /// <summary>
        /// Routes the call per Least Cost Routing, uses cheapest routes
        /// </summary>
        /// <param name="context">Routing Context</param>
        /// <param name="routingRulesResult">Routing Rules Result</param>
        /// <param name="rtContext">Routing Tree Context</param>
        /// <param name="blending">Indicates if blending is active or not</param>
        /// <returns>True if routing was successful</returns>
        private async Task<bool> _LeastCostRoutingAsync(Context context, Result routingRulesResult, Utilities.RoutingTree.Context rtContext, bool blending)
        {
            bool isHandled = false;

            // check if blending is active and if call is within the blending percentage
            if (context.LCRBlendPercentage.HasValue && context.LCRBlendPercentage >= random.Next(0, 101))
            {
                await this._RouteToContext(context.LCRBlendToContextId.Value, rtContext, true);
            }

            // get gateways for the specific context that haven't exceeded their limit
            var gatewaysAvailable = Cache.GetAvailableGateways(context);

            // get gateway routing rates and only take the ones where the rate is lower then the customer rate
            var gatewayRoutingRates = (await Cache.GetRatesForGateways(gatewaysAvailable, this.calledSplitted, this.Time, this.Message.CancellationToken).ConfigureAwait(false)).ToList();
            if (routingRulesResult.CustomerHasRate)
            {
                gatewayRoutingRates = gatewayRoutingRates.Where(g => g.RateNormalized < routingRulesResult.CustomerRateNormalized).ToList();
            }
            else if (!routingRulesResult.CustomerHasRate && !context.EnableLCRWithoutRate)
            {
                rtContext.AddReason(Utilities.RoutingTree.Reason.CustomerNoRate);

                return isHandled;
            }

            // Cleanup
            gatewaysAvailable = null;

            // get gateway statistics for dialed number
            var numberGatewayStatistics = await Cache.GetNumberGatewayStatistics(this.calledSplitted, gatewayRoutingRates.Select(grp => grp.GatewayId).ToArray(), this.Message.CancellationToken).ConfigureAwait(false);

            // calculate priority list according to statistic
            var gateways = (from grp in gatewayRoutingRates
                            join ngs in numberGatewayStatistics on grp.GatewayId equals ngs.Key
                            select new TargetGateway()
                            {
                                GatewayId = grp.GatewayId,
                                Priority = ngs.Value,
                                RateId = grp.GatewayRateId,
                                RatePerMinute = grp.RatePerMinute,
                                Currency = grp.Currency
                            }).OrderByDescending(g => g.Priority).ToList();

            // route call

            Utilities.RoutingTree.Gateway rtTarget;

            int waiterLimit = gateways.Count() - 1;
            for (int i = 0; i < gateways.Count(); i++)
            {
                rtTarget = new Utilities.RoutingTree.Gateway();
                if (blending)
                {
                    rtTarget.AddReason(Utilities.RoutingTree.Reason.Blending);
                }

                rtContext.LCRGateways.Add(rtTarget);

                if (!Cache.GetGatewayById(gateways[i].GatewayId, out Gateway gateway))
                {
                    rtTarget.AddReason(Utilities.RoutingTree.Reason.CacheMiss);

                    continue;
                }

                rtTarget.SetId(gateway.Id);

                // If gateway is already a target or has same company as customer, skip
                if (this.routingTree.Contains(rtTarget))
                {
                    rtTarget.AddReason(Utilities.RoutingTree.Reason.AlreadyTargeted);

                    continue;
                }

                if (gateway.CompanyId == rfCustomer.CompanyId)
                {
                    rtTarget.AddReason(Utilities.RoutingTree.Reason.SameCompany);

                    continue;
                }

                if (this._InternalRouteNodeToGateway(gateway, gateways[i].RateId, gateways[i].RatePerMinute, gateways[i].Currency, Caching.Routing.Action.LeastCostRouting, context.Timeout.ToString(), this.yCalled, rtTarget, blending))
                {
                    isHandled = true;
                    this._InternalRouteNodeToGatewayWaiter(context, blending);
                }
            }

            return isHandled;
        }

        /// <summary>
        /// Parses the statements from yate into C# object
        /// </summary>
        private void _Parse()
        {
            var values = Messages.Skip(4).ToArray();

            int pos = 0;
            string yateParameter = string.Empty;
            string yateValue = string.Empty;

            foreach (var value in values)
            {
                pos = value.IndexOf('=');

                // ignore everything without =
                if (pos == -1)
                {
                    continue;
                }

                yateParameter = value.Substring(0, pos);

                // Check if has value
                if (pos <= value.Length - 1)
                {
                    yateValue = CharacterCoding.Decode(value.Substring(pos + 1));
                }
                else
                {
                    continue;
                }

                switch (yateParameter)
                {
                    case "address":
                        this.yAddress = yateValue;
                        break;

                    case "error":
                        this.yError = yateValue;
                        break;

                    case "reason":
                        this.yReason = yateValue;
                        break;

                    case "caller":
                        this.yCaller = yateValue;
                        break;

                    case "callername":
                        this.yCallername = yateValue;
                        break;

                    case "called":
                        this.yCalled = yateValue;
                        break;

                    case "sip_Tracking-ID":
                        this.clTrackingId = yateValue;
                        break;

                    case "sip_Gateway-ID":
                        this.clGatewayId = yateValue;
                        break;

                    case "billid":
                        this.yBillId = yateValue;
                        break;

                    default:
                        break;
                }
            }

            // Set CLTrackingId in case it has no value (call coming from external source)
            if (string.IsNullOrEmpty(this.clTrackingId))
            {
                this.clTrackingId = this.yBillId;
            }
        }

        /// <summary>
        /// Does prerouting
        /// </summary>
        /// <returns>True if prerouting was successful</returns>
        private void _Preroute()
        {
            // Get Sender IP
            if (string.IsNullOrEmpty(this.yAddress))
            {
                this.routingTree.Context.AddReason(Utilities.RoutingTree.Reason.AddressIsEmpty);

                this._CancelCall(ErrorCode.Forbidden, this.routingTree.Context);
                return;
            }
            this.rfSenderIP = this.yAddress.Substring(0, this.yAddress.IndexOf(':'));

            // Check if is Customer or Node
            if (!Cache.GetCustomerByIdentifier(this.rfSenderIP, this.yCalled, out this.rfCustomer, out this.rfCustomerCalled))
            {
                if (!Cache.GetNodeByIP(this.rfSenderIP, out Caching.Model.Node node))
                {
                    this.routingTree.Context.AddReason(Utilities.RoutingTree.Reason.UnknownSender);

                    this._CancelCall(ErrorCode.Forbidden, this.routingTree.Context);
                    return;
                }
                else
                {
                    this.clSender = "node";
                }
            }
            else
            {
                // Check Called Length
                if (this.rfCustomerCalled.Length < 6)
                {
                    this.routingTree.Context.AddReason(Utilities.RoutingTree.Reason.CalledIsIncomplete);

                    this._CancelCall(ErrorCode.AddressIncomplete, this.routingTree.Context);
                    return;
                }

                // use number without prefix as 'Called' number so that route has the correct number to work with
                this.yCalled = this.rfCustomerCalled;
                this.clSender = "customer";

                // Check if customer LIMIT is OK
                if (!this.rfCustomer.LimitOK)
                {
                    this.routingTree.Context.AddReason(Utilities.RoutingTree.Reason.LimitExceeded);

                    this._CancelCall(ErrorCode.TemporarilyUnavailable, this.routingTree.Context);
                    return;
                }
            }

            this.isHandled = false;
        }

        /// <summary>
        /// Cleans the called number
        /// </summary>
        /// <param name="phoneNumber">Called number</param>
        /// <returns>Cleaned called number or an empty string</returns>
        public string NormalizePhoneNumber(string phoneNumber)
        {
            // Normalize called, delete prefix, trim leading 0, trim leading +, remove crap at the end
            var prefixPos = phoneNumber.IndexOf('#');
            if (prefixPos > -1)
            {
                phoneNumber = phoneNumber.Substring(prefixPos + 1);
            }

            phoneNumber = phoneNumber.TrimStart(new char[] { '0', '+' });

            try
            {
                phoneNumber = this.cleanupNumber.Match(phoneNumber).Value;
            }
            catch (RegexMatchTimeoutException)
            {
                phoneNumber = string.Empty;
            }

            return phoneNumber;
        }

        /// <summary>
        /// Does Routing
        /// </summary>
        /// <returns>True if routing was successful</returns>
        private async Task _RouteAsync()
        {
            if (!string.IsNullOrEmpty(this.yError))
            {
                this.routingTree.Context.AddReason(Utilities.RoutingTree.Reason.PrerouteFailed);
                this.routingTree.Context.AddRoutingAction(Utilities.RoutingTree.ContextAction.Cancelled);
                this.isHandled = true;
                return;
            }

            this.yCalled = this.NormalizePhoneNumber(this.yCalled);

            // Blacklist Check
            if (Cache.IsBlacklisted(this.yCalled))
            {
                this.routingTree.Context.AddReason(Utilities.RoutingTree.Reason.Blacklisted);
                this._CancelCall(ErrorCode.Forbidden, this.routingTree.Context);
                return;
            }

            // Get Number Information
            this.calledSplitted = Cache.SplitNumber(this.yCalled);
            this.numberInfo = Cache.GetDialcodeMaster(this.calledSplitted);

            if (this.numberInfo == null)
            {
                this.routingTree.Context.AddReason(Utilities.RoutingTree.Reason.DialcodeMasterMissing);
                this._CancelCall(ErrorCode.ServiceUnavailable, this.routingTree.Context);
                return;
            }

            // Check if call is routed internally
            int gatewayId = 0;
            if (this.clSender == "node")
            {
                this.routingTree.Context.AddRoutingAction(Utilities.RoutingTree.ContextAction.Internal);

                var rtTarget = new Utilities.RoutingTree.Gateway();
                this.routingTree.Context.SetInternalRoutedGateway(rtTarget as Utilities.RoutingTree.Gateway);

                if (int.TryParse(this.clGatewayId, out gatewayId))
                {

                    rtTarget.SetId(gatewayId);

                    if (!Cache.GetGatewayById(gatewayId, out Gateway gateway))
                    {
                        rtTarget.AddReason(Utilities.RoutingTree.Reason.CacheMiss);

                        this._CancelCall(ErrorCode.TemporarilyUnavailable, this.routingTree.Context);
                        return;
                    }
                    else
                    {
                        if (!this._InternalRouteNodeToGateway(gateway, null, null, string.Empty, Caching.Routing.Action.InternalRouting, DEFAULT_TIMEOUT, this.yCalled, rtTarget, false))
                        {
                            rtTarget.AddReason(Utilities.RoutingTree.Reason.RoutingFailed);

                            this._CancelCall(ErrorCode.InternalServerError, this.routingTree.Context);
                            return;
                        }
                    }

                    this.isHandled = true;
                    return;
                }

                rtTarget.AddReason(Utilities.RoutingTree.Reason.GatewayIdNotTransmitted);

                this._CancelCall(ErrorCode.ServiceUnavailable, this.routingTree.Context);
                return;
            }
            else
            {
                if (!Cache.GetContextById(this.rfCustomer.ContextId, out Context context))
                {
                    this.routingTree.Context.AddReason(Utilities.RoutingTree.Reason.CacheMiss);

                    this._CancelCall(ErrorCode.ServiceUnavailable, this.routingTree.Context);
                    return;
                }

                this.routingTree.Context.SetId(context.Id);

                await _ContextRouting(context, this.routingTree.Context, false);
            }
        }

        /// <summary>
        /// Routes a call within a context
        /// </summary>
        /// <param name="context">Routing Context</param>
        /// <param name="rtContext">Routing Tree Context</param>
        /// <param name="blending">Indicates if blending is active or not</param>
        /// <returns></returns>
        private async Task _ContextRouting(Context context, Utilities.RoutingTree.Context rtContext, bool blending)
        {
            // Loop detection
            if (this.routedContexts.Contains(context))
            {
                rtContext.AddReason(Utilities.RoutingTree.Reason.AlreadyTargeted);
                return;
            }

            this.routedContexts.Add(context);

            var firstRun = this.routedContexts.Count == 1;

            // Check routing rules
            var routingRulesResult = await this._InternalRoutingRulesAsync(context, rtContext);

            this.clCustomerRateCurrency = routingRulesResult.CustomerRateCurrency;
            this.clCustomerRateId = routingRulesResult.CustomerRateId;
            this.clCustomerRatePerMin = routingRulesResult.CustomerRatePerMin;

            if (routingRulesResult.Decision == Caching.Routing.Action.Forbidden && firstRun)
            {
                this._CancelCall(ErrorCode.Forbidden, rtContext);
                return;
            }

            // Cancel call
            if (routingRulesResult.HasRoute && routingRulesResult.Route.Action == "error" && firstRun)
            {
                this._CancelCall(ErrorCode.TemporarilyUnavailable, rtContext);
                return;
            }

            if (routingRulesResult.FakeRinging && firstRun)
            {
                // TODO: remove unneeded parameters
                this.routes.Add(new RouteControl()
                {
                    YTARGET = "tone/ring"
                });

                this.yForkAutoMessage = "call.progress";
                this.yForkAutoRing = "true";
                this.yForkCallType = "persistent";
                this.yForkRinger = "true";

                // increase blended, so that the actual blending will not push fake-ringing from position 1 in list
                this.blended++;
            }

            this.isHandled = false;

            // Make routing decision
            bool isHandled = false;
            if (routingRulesResult.Decision.HasFlag(Caching.Routing.Action.FixedRouteRouting))
            {
                rtContext.AddRoutingAction(Utilities.RoutingTree.ContextAction.Fixed);

                isHandled = await this._FixedRouteRouting(context, routingRulesResult, rtContext, blending);
                if (!this.isHandled)
                {
                    this.isHandled = isHandled;
                }
            }

            if (routingRulesResult.Decision.HasFlag(Caching.Routing.Action.LeastCostRouting))
            {
                rtContext.AddRoutingAction(Utilities.RoutingTree.ContextAction.LCR);

                isHandled = await this._LeastCostRoutingAsync(context, routingRulesResult, rtContext, blending);
                if (!this.isHandled)
                {
                    this.isHandled = isHandled;
                }
            }

            if (routingRulesResult.Decision.HasFlag(Caching.Routing.Action.Forbidden) && firstRun)
            {
                this._CancelCall(ErrorCode.Forbidden, rtContext);
            }

            if (!this.isHandled && firstRun)
            {
                this._CancelCall(ErrorCode.TemporarilyUnavailable, rtContext);
            }

            return;
        }

        /// <summary>
        /// Routes the call to a specific Gateway
        /// </summary>
        /// <param name="gateway">The Gateway</param>
        /// <param name="gatewayRateId">Rate Id or null if gateway has no rate</param>
        /// <param name="gatewayRatePerMin">Rate per minute or null if gateway has no rate</param>
        /// <param name="gatewayCurrency">Rate currency or null if gateway has no rate</param>
        /// <param name="action">Least Cost Routing or Fixed Route Routing</param>
        /// <param name="timeout">Call timeout</param>
        /// <param name="called">Called number</param>
        /// <param name="rtGateway">Routing Tree Gateway</param>
        /// <param name="blending">Indicates if blending is active or not</param>
        /// <returns>True if routing was successful</returns>
        private bool _RouteToGateway(Gateway gateway, long? gatewayRateId, decimal? gatewayRatePerMin, string gatewayCurrency, Caching.Routing.Action action,
            string timeout, string called, Utilities.RoutingTree.Gateway rtGateway, bool blending)
        {
            // Perform Number Modification
            string modifiedCalled = called;
            if (gateway.NumberModificationGroup.HasValue)
            {
                if (!Cache.GetNumberModificationGroupPolicies(gateway.NumberModificationGroup.Value, out List<NumberModificationPolicy> policies))
                {
                    rtGateway.AddReason(Utilities.RoutingTree.Reason.CacheMissForNumberModification);

                    return false;
                }

                // Find first matching policy
                foreach (var policy in policies)
                {
                    if (policy.Pattern.IsMatch(modifiedCalled))
                    {
                        if (policy.RemovePrefix != null && modifiedCalled.Substring(0, policy.RemovePrefix.Length) == policy.RemovePrefix)
                        {
                            modifiedCalled = modifiedCalled.Substring(policy.RemovePrefix.Length);
                        }

                        if (policy.AddPrefix != null)
                        {
                            modifiedCalled = string.Concat(policy.AddPrefix, modifiedCalled);
                        }

                        // Only apply first matching policy
                        break;
                    }
                }
            }

            RouteCall rc;
            if (gateway.Type == GatewayType.Account)
            {
                if (!Cache.GetGatewayAccountsForGatewayId(gateway, out List<GatewayAccount> gatewayAccounts))
                {
                    rtGateway.AddReason(Utilities.RoutingTree.Reason.CacheMissGatewayAccount);

                    return false;
                }

                GatewayAccount gatewayAccount = null;
                if (gatewayAccounts.Count == 1)
                {
                    gatewayAccount = gatewayAccounts.ElementAt(0);
                }
                else
                {
                    gatewayAccount = gatewayAccounts.OrderBy(ga => ga.BillTime).ElementAt(0);
                }

                rc = new RouteCall()
                {
                    YMaxCall = MAXCALL,
                    CLGatewayID = gateway.IdAsString,
                    YOConnectionID = gateway.OutgoingConnectionId,
                    YFormat = gateway.Format,
                    YFormats = gateway.Formats,
                    YCallername = string.IsNullOrEmpty(gatewayAccount.NewCallername) ? this._CorrectCallerAndCallername(this.yCallername) : gatewayAccount.NewCallername,
                    YCaller = string.IsNullOrEmpty(gatewayAccount.NewCaller) ? this._CorrectCallerAndCallername(this.yCaller) : gatewayAccount.NewCaller,
                    YLine = gatewayAccount.Account,
                    YRTPForward = "false",
                    YTARGET = string.Concat(gatewayAccount.Protocol, "/", gatewayAccount.Protocol, ":", gateway.Prefix, modifiedCalled),
                    CLGatewayAccountID = gatewayAccount.Id,
                    YCalled = modifiedCalled,
                    CLGatewayCurrency = gatewayCurrency,
                    CLGatewayRateId = gatewayRateId.ToString(),
                    CLGatewayRatePerMin = gatewayRatePerMin?.ToString(Formats.DecimalToString, Formats.CultureInfo),
                    CLDecision = ((int)action).ToString(),
                    YTimeout = timeout
                };
            }
            else
            {
                if (!Cache.GetGatewayIPsForGateway(gateway, out List<GatewayIP> gatewayIPs))
                {
                    rtGateway.AddReason(Utilities.RoutingTree.Reason.CacheMissGatewayIP);

                    return false;
                }

                GatewayIP gatewayIp = null;
                if (gatewayIPs.Count == 1)
                {
                    gatewayIp = gatewayIPs.ElementAt(0);
                }
                else
                {
                    gatewayIp = gatewayIPs.OrderBy(ga => ga.BillTime).ElementAt(0);
                }

                rc = new RouteCall()
                {
                    YMaxCall = MAXCALL,
                    CLGatewayID = gateway.IdAsString,
                    YOConnectionID = gateway.OutgoingConnectionId,
                    YFormat = gateway.Format,
                    YFormats = gateway.Formats,
                    YTARGET = string.Concat(gatewayIp.Protocol, "/", gatewayIp.Protocol, ":", gateway.Prefix, modifiedCalled, "@", gatewayIp.Address, ":", gatewayIp.Port),
                    YRTPAddr = gatewayIp.RTPAddress,
                    YRTPPort = gatewayIp.RTPPort,
                    YRTPForward = gatewayIp.RTPForward,
                    CLGatewayIPID = gatewayIp.Id,
                    OSIPPAssertedIdentity = gatewayIp.SIPPAssertedIdentity,
                    YCalled = modifiedCalled,
                    YCaller = this._CorrectCallerAndCallername(this.yCaller),
                    YCallername = this._CorrectCallerAndCallername(this.yCallername),
                    CLGatewayCurrency = gatewayCurrency,
                    CLGatewayRateId = gatewayRateId.ToString(),
                    CLGatewayRatePerMin = gatewayRatePerMin?.ToString(Formats.DecimalToString, Formats.CultureInfo),
                    CLDecision = ((int)action).ToString(),
                    YTimeout = timeout
                };
            }

            if (!blending)
            {
                this.routes.Add(rc);
            }
            else
            {
                this.routes.Insert(this.blended, rc);
                this.blended++;
            }

            this.routingTree.AddGatewayId(gateway.Id);

            return true;
        }

        /// <summary>
        /// Routes the call to a specific Node (in case the Gateway was not reachable from this Node)
        /// </summary>
        /// <param name="gateway">Targeted Gateway</param>
        /// <param name="action">Least Cost Routing or Fixed Route Routing</param>
        /// <param name="timeout">Timeout</param>
        /// <param name="rtNode">Routing Tree Node</param>
        /// <param name="rtGateway">Routing Tree Gateway</param>
        /// <param name="blending">Indicates if blending is active or not</param>
        /// <returns>True if routing was successful</returns>
        private bool _RouteToNode(Gateway gateway, Caching.Routing.Action action, string timeout, Utilities.RoutingTree.Node rtNode,
            Utilities.RoutingTree.Gateway rtGateway, bool blending)
        {
            // Get node that can access the gateway
            var nodes = new List<int>();
            if (!Cache.GetNodesAccessibleByGateway(gateway, out nodes))
            {
                rtNode.AddReason(Utilities.RoutingTree.Reason.CacheMiss);

                return false;
            }

            int nodeId = nodes.OrderBy(x => random.Next()).ElementAt(0);
            rtNode.SetId(nodeId);

            if (!Cache.GetInternalNodeIPByNodeId(nodeId, out NodeIP nodeIp))
            {
                rtNode.AddReason(Utilities.RoutingTree.Reason.CacheMiss);

                return false;
            }

            var rc = new RouteCall()
            {
                YFormat = "g729",
                YFormats = "g729",
                YRTPForward = "false",
                YMaxCall = string.Empty,
                OSIPTrackingID = this.clTrackingId,
                YOConnectionID = "intern",
                YTARGET = string.Concat("sip/sip:", this.yCalled, "@", nodeIp.Address, ":", nodeIp.Port),
                OSIPGatewayID = gateway.IdAsString,
                CLDecision = ((int)action).ToString(),
                YTimeout = timeout
            };

            if (!blending)
            {
                this.routes.Add(rc);
            }
            else
            {
                this.routes.Insert(this.blended, rc);
                this.blended++;
            }

            this.routingTree.AddGatewayId(gateway.Id);

            return true;
        }

        /// <summary>
        /// Routes the call per fixed routes
        /// </summary>
        /// <param name="context">Routing Context</param>
        /// <param name="routingRulesResult">Routing Rules Result</param>
        /// <param name="rtContext">Routing Tree Context</param>
        /// <param name="blending">Indicates if blending is active or not</param>
        /// <returns>True if routing was successful</returns>
        private async Task<bool> _FixedRouteRouting(Context context, Result routingRulesResult, Utilities.RoutingTree.Context rtContext, bool blending)
        {
            bool isHandled = false;

            var rtRoute = new Utilities.RoutingTree.Route(routingRulesResult.Route.Id)
            {
                IsFallbackToLCR = routingRulesResult.Route.FallbackToLCR
            };
            rtContext.SetRoute(rtRoute);

            // check if blending is active and if call is within the blending percentage
            if (routingRulesResult.Route.BlendPercentage.HasValue && routingRulesResult.Route.BlendPercentage >= random.Next(0, 101))
            {
                await this._RouteToContext(routingRulesResult.Route.BlendToContextId.Value, rtRoute, true);
            }

            string called = this.yCalled;

            if (routingRulesResult.Route.IsDid)
            {
                called = routingRulesResult.Route.Action;
            }
            else
            {
                called = routingRulesResult.Route.Action.Replace(@"\1", called);
            }

            // get gateway routing rates
            var gatewayRoutingRates = await Cache.GetRatesForGateways(
                routingRulesResult.Route.Targets.Where(t => t.GatewayId.HasValue).Select(t => t.GatewayId.Value),
                this.calledSplitted,
                this.Time,
                this.Message.CancellationToken).ConfigureAwait(false);

            Utilities.RoutingTree.Target rtTarget;
            foreach (var target in routingRulesResult.Route.Targets)
            {
                // Send call to Gateway (or Context..see below)
                if (target.GatewayId.HasValue)
                {
                    var rtGateway = new Utilities.RoutingTree.Gateway();
                    rtTarget = rtGateway;
                    rtTarget.SetId(target.GatewayId.Value);

                    if (blending)
                    {
                        rtTarget.AddReason(Utilities.RoutingTree.Reason.Blending);
                    }

                    rtRoute.Targets.Add(rtTarget);

                    if (!Cache.GetGatewayById(target.GatewayId.Value, out Gateway gateway))
                    {
                        rtTarget.AddReason(Utilities.RoutingTree.Reason.CacheMiss);
                        continue;
                    }

                    // If gateway is already a target, skip
                    if (this.routingTree.Contains(rtGateway))
                    {
                        rtTarget.AddReason(Utilities.RoutingTree.Reason.AlreadyTargeted);
                        continue;
                    }

                    // If gateway and customer are of same company
                    if (gateway.CompanyId == rfCustomer.CompanyId)
                    {
                        rtTarget.AddReason(Utilities.RoutingTree.Reason.SameCompany);
                        continue;
                    }

                    // check if gateway has rate, if not and customer may not send to it, skip gateway
                    var gatewayRate = gatewayRoutingRates.SingleOrDefault(p => p.GatewayId == target.GatewayId.Value);
                    if (gatewayRate == null)
                    {
                        rtTarget.AddReason(Utilities.RoutingTree.Reason.GatewayNoRate);
                        continue;
                    }
                    else
                    {
                        if ((routingRulesResult.CustomerHasRate && routingRulesResult.CustomerRateNormalized.Value > gatewayRate.RateNormalized)
                            || (!routingRulesResult.CustomerHasRate && routingRulesResult.Route.IgnoreMissingRate))
                        {
                            if (this._InternalRouteNodeToGateway(gateway, gatewayRate.GatewayRateId, gatewayRate.RatePerMinute, gatewayRate.Currency, Caching.Routing.Action.FixedRouteRouting, routingRulesResult.Route.Timeout.ToString(), called, rtTarget as Utilities.RoutingTree.Gateway, blending))
                            {
                                isHandled = true;
                                this._InternalRouteNodeToGatewayWaiter(context, blending);
                            }
                        }
                        else
                        {
                            continue;
                        }
                    }
                }
                else
                {
                    await this._RouteToContext(target.ContextId.Value, rtRoute, false);
                }
            }

            return isHandled;
        }

        /// <summary>
        /// Routes to a context
        /// </summary>
        /// <param name="contextId">Context Id</param>
        /// <param name="rtRoute">The routing tree to add routing information to</param>
        /// <param name="blending">Indicates if blending is active or not</param>
        /// <returns></returns>
        private async Task _RouteToContext(int contextId, Utilities.RoutingTree.Route rtRoute, bool blending)
        {
            var rtTarget = new Utilities.RoutingTree.Context();
            rtTarget.SetId(contextId);
            if (rtRoute != null)
            {
                if (blending)
                {
                    rtRoute.AddBlendingContext(rtTarget);
                }
                else
                {
                    rtRoute.Targets.Add(rtTarget);
                }
            }

            if (Cache.GetContextById(contextId, out Context subContext))
            {
                await _ContextRouting(subContext, rtTarget as Utilities.RoutingTree.Context, blending);
            }
            else
            {
                rtTarget.AddReason(Utilities.RoutingTree.Reason.CacheMiss);
            }
        }

        /// <summary>
        /// Routes to a context
        /// </summary>
        /// <param name="contextId">Context Id</param>
        /// <param name="rtContext">The routing tree to add routing information to</param>
        /// <param name="blending">Indicates if blending is active or not</param>
        /// <returns></returns>
        private async Task _RouteToContext(int contextId, Utilities.RoutingTree.Context rtContext, bool blending)
        {
            var rtTarget = new Utilities.RoutingTree.Context();
            rtTarget.SetId(contextId);

            rtContext.SetBlendingContext(rtTarget);

            if (Cache.GetContextById(contextId, out Context subContext))
            {
                await _ContextRouting(subContext, rtTarget, blending);
            }
            else
            {
                rtTarget.AddReason(Utilities.RoutingTree.Reason.CacheMiss);
            }
        }

        #endregion Methods
    }
}