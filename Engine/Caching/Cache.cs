namespace CarrierLink.Controller.Engine.Caching
{
    using Database;
    using Model;
    using NLog;
    using System;
    using System.Collections.Concurrent;
    using System.Collections.Generic;
    using System.Linq;
    using System.Text.RegularExpressions;
    using System.Threading;
    using System.Threading.Tasks;
    using Yate;

    /// <summary>
    /// This class provides cached data
    /// </summary>
    public static class Cache
    {
        #region Fields

        /// <summary>
        /// Regular Expressions
        /// </summary>
        private static ConcurrentDictionary<string, Regex> blacklist;

        /// <summary>
        /// Holds the relation between contexts and gateways
        /// </summary>
        private static ConcurrentBag<ContextGateway> contextGateway;

        /// <summary>
        /// Holds Context information, Key: ID
        /// </summary>
        private static ConcurrentDictionary<int, Context> contexts;

        /// <summary>
        /// Holds Customer information, Key: IP#Prefix
        /// </summary>
        private static ConcurrentDictionary<string, Customer> customers;

        /// <summary>
        /// Holds number information for a dialcode
        /// </summary>
        private static ConcurrentDictionary<string, DialcodeMaster> dialcodeMasters;

        /// <summary>
        /// PostgreSQL Database providing data for Cache
        /// </summary>
        private static IDatabase database;

        /// <summary>
        /// Holds Gateway Account information, Key: Gateway ID
        /// </summary>
        private static ConcurrentDictionary<int, List<GatewayAccount>> gatewayAccounts;

        /// <summary>
        /// Holds Gateway IP information, Key: Gateway ID
        /// </summary>
        private static ConcurrentDictionary<int, List<GatewayIP>> gatewayIPs;

        /// <summary>
        /// Holds information about the gateway limit, Key: Gateway ID, Value: Limit Exceeded
        /// </summary>
        private static ConcurrentDictionary<int, bool> gatewayLimitExceeded;

        /// <summary>
        /// holds Gateway information, Key: ID
        /// </summary>
        private static ConcurrentDictionary<int, Gateway> gateways;

        /// <summary>
        /// Holds information on which Gateway can send to which Node, Key: Node ID
        /// </summary>
        private static ConcurrentDictionary<int, List<int>> gatewaysAccessibleByNode;

        /// <summary>
        /// Holds information on which Gateway is in which Route, Key: Route ID
        /// </summary>
        private static ConcurrentDictionary<int, TargetsForRoute> targetsForRoute;

        /// <summary>
        /// Holds Incorrect Callernames, Key: incorrect callername
        /// </summary>
        private static ConcurrentDictionary<string, string> incorrectCallernames;

        /// <summary>
        /// Holds information about which node has which internal IP, Key: Node ID
        /// </summary>
        private static ConcurrentDictionary<int, NodeIP> internalNodeIPs;

        /// <summary>
        /// Logger instance
        /// </summary>
        private static Logger logger = LogManager.GetCurrentClassLogger();

        /// <summary>
        /// Holds Node information, Key: IP
        /// </summary>
        private static ConcurrentDictionary<string, Model.Node> nodes;

        /// <summary>
        /// Holds information on which Node can send to which Gateway, Key: Gateway ID
        /// </summary>
        private static ConcurrentDictionary<int, List<int>> nodesAccessibleByGateway;

        /// <summary>
        /// Holds information about the Number Modification Groups and their policies, Key: Number Modification Group ID
        /// </summary>
        private static ConcurrentDictionary<int, List<NumberModificationPolicy>> numberModificationGroups;

        /// <summary>
        /// Holds information about routes
        /// </summary>
        private static List<Route> routes;

        /// <summary>
        /// Interups the <c>Update</c> process
        /// </summary>
        private static CancellationTokenSource updateCTS;

        #endregion Fields

        #region Properties

        /// <summary>
        /// Gets a value indicating whether update is in progress or not
        /// </summary>
        internal static bool Updating { get; private set; }

        #endregion Properties

        #region Functions

        /// <summary>
        /// Returns Gateways for specified Context
        /// </summary>
        /// <param name="context">Context to get Gateways for</param>
        /// <returns>List of gateway ids for the context</returns>
        internal static IEnumerable<int> GetAvailableGateways(Context context)
        {
            var currentContextGateway = contextGateway;

            return from cg in currentContextGateway
                   where cg.ContextId == context.Id
                   select cg.GatewayId;
        }

        /// <summary>
        /// Returns Context for specified Id
        /// </summary>
        /// <param name="contextId">Context Id</param>
        /// <param name="context">Context instance to use</param>
        /// <returns>True if found</returns>
        internal static bool GetContextById(int contextId, out Context context)
        {
            var currentContexts = contexts;

            return currentContexts.TryGetValue(contextId, out context);
        }

        /// <summary>
        /// Returns Customer for specified Identifier
        /// </summary>
        /// <param name="customerIp">IP # Prefix</param>
        /// <param name="called">Called number</param>
        /// <param name="customer">Calling customer</param>
        /// <param name="calledWithoutPrefix">Number without leading prefix information</param>
        /// <returns>True if found</returns>
        internal static bool GetCustomerByIdentifier(string customerIp, string called, out Customer customer, out string calledWithoutPrefix)
        {
            customer = null;
            var currentCustomers = customers;

            foreach (var c in currentCustomers.Where(c => c.Value.CustomerIP == customerIp).OrderByDescending(c => c.Value.Prefix))
            {
                if (!string.IsNullOrEmpty(c.Value.Prefix))
                {
                    if (called.StartsWith(c.Value.Prefix, StringComparison.OrdinalIgnoreCase))
                    {
                        customer = c.Value;
                        calledWithoutPrefix = called.Substring(c.Value.Prefix.Length);
                        return true;
                    }
                }
                else
                {
                    customer = c.Value;
                    calledWithoutPrefix = called;
                    return true;
                }
            }

            calledWithoutPrefix = called;

            return false;
        }

        /// <summary>
        /// Returns Gateway Accounts for specified Gateway
        /// </summary>
        /// <param name="gateway">Gateway to get Gateway Accounts for</param>
        /// <param name="gatewayAccounts">Assigned gateway accounts</param>
        /// <returns>True if found</returns>
        internal static bool GetGatewayAccountsForGatewayId(Gateway gateway, out List<GatewayAccount> gatewayAccounts)
        {
            var currentGatewayAccounts = Cache.gatewayAccounts;

            return currentGatewayAccounts.TryGetValue(gateway.Id, out gatewayAccounts);
        }

        /// <summary>
        /// Returns Gateway for specified Id
        /// </summary>
        /// <param name="gatewayId">Gateway Id</param>
        /// <param name="gateway">Gateway instance to use</param>
        /// <returns>True if found</returns>
        internal static bool GetGatewayById(int gatewayId, out Gateway gateway)
        {
            var currentGateways = gateways;

            return currentGateways.TryGetValue(gatewayId, out gateway);
        }

        /// <summary>
        /// Returns Gateway IPs for specified Gateway
        /// </summary>
        /// <param name="gateway">Gateway to get Gateway IPs for</param>
        /// <param name="gatewayIPs">Assigned gateway ips</param>
        /// <returns>True if found</returns>
        internal static bool GetGatewayIPsForGateway(Gateway gateway, out List<GatewayIP> gatewayIPs)
        {
            var currentGatewayIps = Cache.gatewayIPs;

            return currentGatewayIps.TryGetValue(gateway.Id, out gatewayIPs);
        }

        /// <summary>
        /// Returns the accessible Gateways for a specified Node
        /// </summary>
        /// <param name="node">Node to get accessible Gateways for</param>
        /// <param name="gateways">Accessible gateways</param>
        /// <returns>True if found</returns>
        internal static bool GetGatewayListForNodeId(INode node, out List<int> gateways)
        {
            var currentGatewayAccessibleByNode = gatewaysAccessibleByNode;

            // Check if node can access any gateway
            if (currentGatewayAccessibleByNode.ContainsKey(node.Id))
            {
                // Retrieve list of accessible gateways
                if (!currentGatewayAccessibleByNode.TryGetValue(node.Id, out gateways))
                {
                    return false;
                }
            }
            else
            {
                gateways = new List<int>();
            }

            return true;
        }

        /// <summary>
        /// Looks for rates of gateways for the called number
        /// </summary>
        /// <param name="gatewayIds">Possible gateways to query for rates</param>
        /// <param name="splittedNumber">Use <see cref="SplitNumber"/> first and pass result here</param>
        /// <param name="callDateTime">Date and time of call</param>
        /// <returns>Task to wait for until gateway rates return</returns>
        /// <param name="cancellationToken">Messages cancellation token</param>
        internal static async Task<IEnumerable<GatewayRate>> GetRatesForGateways(IEnumerable<int> gatewayIds, string[] splittedNumber, DateTime callDateTime, CancellationToken cancellationToken)
        {
            logger.ConditionalDebug("Get GatewayRoutingRates called");

            var database = Pool.Database.Get();

            var gatewayRoutingRates = await database.GetRatesForGateways(gatewayIds.ToArray(), splittedNumber, callDateTime, cancellationToken);

            Pool.Database.Put(database);

            return gatewayRoutingRates;
        }

        /// <summary>
        /// Returns Targets for specified Route
        /// </summary>
        /// <param name="route">Route to get Gateways for</param>
        /// <param name="targets">Ordered list (Queue) of assigned gateways</param>
        /// <returns>True if found</returns>
        internal static bool GetTargetsForRoute(Route route, out List<RouteTarget> targets)
        {
            var currentTargetsForRoute = targetsForRoute;

            targets = null;
            if (currentTargetsForRoute.TryGetValue(route.Id, out TargetsForRoute gfr))
            {
                targets = gfr.Targets;
                return true;
            }

            return false;
        }

        /// <summary>
        /// Returns the internal Node IP for specified Node
        /// </summary>
        /// <param name="nodeId">Node id</param>
        /// <param name="nodeIp">Node IP</param>
        /// <returns>True if found</returns>
        internal static bool GetInternalNodeIPByNodeId(int nodeId, out NodeIP nodeIp)
        {
            var currentInternalNodeIPs = internalNodeIPs;

            return currentInternalNodeIPs.TryGetValue(nodeId, out nodeIp);
        }

        /// <summary>
        /// Returns Node by external IP
        /// </summary>
        /// <param name="ip">External Node IP</param>
        /// <param name="node">Assigned Node</param>
        /// <returns>True if found</returns>
        internal static bool GetNodeByIP(string ip, out Model.Node node)
        {
            var currentNodes = nodes;

            return currentNodes.TryGetValue(ip, out node);
        }

        /// <summary>
        /// Returns Nodes that are accessible by specified Gateway
        /// </summary>
        /// <param name="gateway">The Gateway to get accessible Nodes for</param>
        /// <param name="nodes">Accessible nodes</param>
        /// <returns>True if found</returns>
        internal static bool GetNodesAccessibleByGateway(Gateway gateway, out List<int> nodes)
        {
            var currentNodesAccessibleByGateway = nodesAccessibleByGateway;

            return currentNodesAccessibleByGateway.TryGetValue(gateway.Id, out nodes);
        }

        /// <summary>
        /// Returns the ASR for the mentioned country and gateways
        /// </summary>
        /// <param name="splittedNumber">Use <c>SplitNumber</c> first and pass result here</param>
        /// <param name="gatewayIds">The relevant gateways</param>
        /// <param name="cancellationToken">Messages cancellation token</param>
        /// <returns>ASR per gateway</returns>
        internal static async Task<Dictionary<int, decimal>> GetNumberGatewayStatistics(string[] splittedNumber, int[] gatewayIds, CancellationToken cancellationToken)
        {
            logger.ConditionalDebug("Get GatewayCountryStatistics called");

            var database = Pool.Database.Get();

            var result = await database.GetNumberGatewayStatistics(splittedNumber, gatewayIds, cancellationToken);

            Pool.Database.Put(database);

            return result;
        }

        /// <summary>
        /// Returns Country Id and Dialcode Id for given number
        /// </summary>
        /// <param name="splittedNumber">Use <see cref="SplitNumber"/> first and pass result here</param>
        /// <returns>Task to wait for until number info returns</returns>
        internal static DialcodeMaster GetDialcodeMaster(string[] splittedNumber)
        {
            logger.ConditionalDebug("Get NumberInfo called");

            DialcodeMaster dialcodeMaster = null;

            var currentDialcodeMasters = dialcodeMasters;
            for (int i = 0; i < splittedNumber.Length; i++)
            {
                if (currentDialcodeMasters.TryGetValue(splittedNumber[i], out dialcodeMaster))
                {
                    break;
                }
            }

            return dialcodeMaster;
        }

        /// <summary>
        /// Returns Number Modification Group Policies for specified Id
        /// </summary>
        /// <param name="policyId">Policy id</param>
        /// <param name="policies">Assigned policies</param>
        /// <returns>True if found</returns>
        internal static bool GetNumberModificationGroupPolicies(int policyId, out List<NumberModificationPolicy> policies)
        {
            var currentNumberModificationGroups = Cache.numberModificationGroups;

            return currentNumberModificationGroups.TryGetValue(policyId, out policies);
        }

        /// <summary>
        /// Returns rate for a number a customer calls or empty string
        /// </summary>
        /// <param name="id">Customer ID</param>
        /// <param name="splittedNumber">Use <c>SplitNumber</c> as parameter value</param>
        /// <param name="callDateTime">Time of call</param>
        /// <param name="cancellationToken">Messages cancellation token</param>
        /// <returns>Task to wait for until customer rate returns</returns>
        internal static async Task<CustomerRate> GetRateForCustomer(int id, string[] splittedNumber, DateTime callDateTime, CancellationToken cancellationToken)
        {
            logger.ConditionalDebug("Get Rate For Customer called");

            var database = Pool.Database.Get();

            var customerRate = await database.GetRateForCustomer(id, splittedNumber, callDateTime, cancellationToken);

            Pool.Database.Put(database);

            return customerRate;
        }

        /// <summary>
        /// Returns route information
        /// </summary>
        /// <param name="context">The Context to get Route for</param>
        /// <param name="called">Called Number</param>
        /// <returns>Route information</returns>
        internal static Route GetRouteForContext(Context context, string called)
        {
            logger.ConditionalDebug("Get Route For Context called");

            var route = (from r in routes
                         where r.ContextId == context.Id && r.RexexMatch.IsMatch(called)
                         orderby r.Sort descending
                         select r).FirstOrDefault();

            return route;
        }

        /// <summary>
        /// Initilalizes fields and properties, use .Shutdown when finished using
        /// </summary>
        public static void Initialize()
        {
            updateCTS = new CancellationTokenSource();

            logger.ConditionalDebug("Initialize Cache");

            database = Pool.Database.Get();

            blacklist = new ConcurrentDictionary<string, Regex>();
            contextGateway = new ConcurrentBag<ContextGateway>();
            contexts = new ConcurrentDictionary<int, Context>();
            customers = new ConcurrentDictionary<string, Customer>();
            dialcodeMasters = new ConcurrentDictionary<string, DialcodeMaster>();
            gatewayAccounts = new ConcurrentDictionary<int, List<GatewayAccount>>();
            gateways = new ConcurrentDictionary<int, Gateway>();
            gatewayIPs = new ConcurrentDictionary<int, List<GatewayIP>>();
            gatewayLimitExceeded = new ConcurrentDictionary<int, bool>();
            gatewaysAccessibleByNode = new ConcurrentDictionary<int, List<int>>();
            targetsForRoute = new ConcurrentDictionary<int, TargetsForRoute>();
            incorrectCallernames = new ConcurrentDictionary<string, string>();
            internalNodeIPs = new ConcurrentDictionary<int, NodeIP>();
            nodes = new ConcurrentDictionary<string, Model.Node>();
            nodesAccessibleByGateway = new ConcurrentDictionary<int, List<int>>();
            numberModificationGroups = new ConcurrentDictionary<int, List<NumberModificationPolicy>>();
            routes = new List<Route>();

            Updating = false;

            logger.ConditionalDebug("Initialize Cache Done");
        }

        /// <summary>
        /// Evaluates if a number is blacklisted
        /// </summary>
        /// <param name="number">Number to check</param>
        /// <returns>True if blacklisted</returns>
        internal static bool IsBlacklisted(string number)
        {
            var currentBlacklist = blacklist;

            foreach (var r in currentBlacklist)
            {
                if (r.Value.Match(number).Success)
                {
                    return true;
                }
            }

            return false;
        }

        /// <summary>
        /// Evaluates if a Gateway has exceeded it's billtime limit or concurrentLineslimit
        /// </summary>
        /// <param name="gateway">Gateway object</param>
        /// <returns>True if limit is exceeded</returns>
        internal static bool IsGatewayLimitExceeded(Gateway gateway)
        {
            var currentGatewayLimitExceed = gatewayLimitExceeded;

            currentGatewayLimitExceed.TryGetValue(gateway.Id, out bool limitExceeded);

            return limitExceeded;
        }

        /// <summary>
        /// Replaces the caller/callername if necessary
        /// </summary>
        /// <param name="caller">Caller / Callername to check</param>
        /// <returns>Returns corrected caller / callername</returns>
        internal static string ReplaceIncorrectCallername(string caller)
        {
            var currentIncorrectCallernames = Cache.incorrectCallernames;
            if (currentIncorrectCallernames.TryGetValue(caller, out string replacement))
            {
                caller = replacement;
            }

            return caller;
        }

        /// <summary>
        /// Shuts down the cache
        /// </summary>
        public static void Shutdown()
        {
            logger.ConditionalDebug("Shutdown Cache");

            updateCTS.Cancel();

            logger.ConditionalDebug("Shutdown Cache Done");
        }

        /// <summary>
        /// Split number into datatable for use in SQL
        /// </summary>
        /// <param name="number">Number to split</param>
        /// <returns>Returns number splitted into data table</returns>
        public static string[] SplitNumber(string number)
        {
            var splittedNumber = new string[number.Length];

            int pos = 0;
            // Split number from full number over AC to CC
            for (int i = number.Length; i > 0; i--)
            {
                splittedNumber[pos++] = number.Substring(0, i);
            }

            return splittedNumber;
        }

        /// <summary>
        /// Updates the cache
        /// </summary>
        /// <returns>Task to wait for completion</returns>
        public static async Task Update(bool limitsOnly)
        {
            if (Updating)
            {
                return;
            }

            Updating = true;

            if (null == nodes)
            {
                throw new InvalidOperationException("Need to run Initialize first!");
            }

            logger.Debug("Updating Cache");

            var cts = new CancellationTokenSource(new TimeSpan(0, 2, 0));

            var tasks = new List<Task>();

            // Update limits
            tasks.Add(Task.Run(() => _UpdateCustomersAsync(cts.Token), updateCTS.Token));
            tasks.Add(Task.Run(() => _UpdateGatewayLimitExceededAsync(cts.Token), updateCTS.Token));

            // and master data
            if (!limitsOnly)
            {
                logger.Info("Updating Cache (full)");

                tasks.Add(Task.Run(() => _UpdateDialcodeMastersAsync(cts.Token), updateCTS.Token));
                tasks.Add(Task.Run(() => _UpdateNodesAsync(cts.Token), updateCTS.Token));
                tasks.Add(Task.Run(() => _UpdateBlacklistAsync(cts.Token), updateCTS.Token));
                tasks.Add(Task.Run(() => _UpdateGatewaysForRouteAsync(cts.Token), updateCTS.Token));
                tasks.Add(Task.Run(() => _UpdateIncorrectCallernamesAsync(cts.Token), updateCTS.Token));
                tasks.Add(Task.Run(() => _UpdateGatewaysAccessibleByNodeAsync(cts.Token), updateCTS.Token));
                tasks.Add(Task.Run(() => _UpdateNodesAccessibleByGatewayAsync(cts.Token), updateCTS.Token));
                tasks.Add(Task.Run(() => _UpdateContextsAsync(cts.Token), updateCTS.Token));
                tasks.Add(Task.Run(() => _UpdateGatewaysAsync(cts.Token), updateCTS.Token));
                tasks.Add(Task.Run(() => _UpdateGatewayAccountsAsync(cts.Token), updateCTS.Token));
                tasks.Add(Task.Run(() => _UpdateGatewayIPsAsync(cts.Token), updateCTS.Token));
                tasks.Add(Task.Run(() => _UpdateInternalNodeIPsAsync(cts.Token), updateCTS.Token));
                tasks.Add(Task.Run(() => _UpdateNumberModificationGroupsAsync(cts.Token), updateCTS.Token));
                tasks.Add(Task.Run(() => _UpdateContextGatewayAsync(cts.Token), updateCTS.Token));
                tasks.Add(Task.Run(() => _UpdateRoutesAsync(cts.Token), updateCTS.Token));
            }
            await Task.WhenAll(tasks);

            if (cts.IsCancellationRequested)
            {
                logger.Debug("Cancellation requested before Update completed");
            }

            Updating = false;

            logger.Debug("Updating Cache done");
        }

        #region Reload Cache

        /// <summary>
        /// Updates the Blacklist information
        /// </summary>
        /// <param name="cancellationToken">Cancellation Token</param>
        /// <returns>Task to wait for completion</returns>
        private static async Task _UpdateBlacklistAsync(CancellationToken cancellationToken)
        {
            logger.ConditionalDebug("Updating Blacklist");

            var result = await database.GetBlacklistCache(cancellationToken).ConfigureAwait(false);

            if (result != null)
            {
                blacklist = result;
            }

            logger.ConditionalDebug("Updating Blacklist Done");
        }

        /// <summary>
        /// Updates the information about Context and Gateway relation
        /// </summary>
        /// <param name="cancellationToken">Cancellation Token</param>
        /// <returns>Task to wait for completion</returns>
        private static async Task _UpdateContextGatewayAsync(CancellationToken cancellationToken)
        {
            logger.ConditionalDebug("Updating Context Gateway");

            var result = await database.GetContextGatewayCache(cancellationToken).ConfigureAwait(false);

            if (result != null)
            {
                contextGateway = result;
            }

            logger.ConditionalDebug("Updating Context Gateway Done");
        }

        /// <summary>
        /// Updates the Context information
        /// </summary>
        /// <param name="cancellationToken">Cancellation Token</param>
        /// <returns>Task to wait for completion</returns>
        private static async Task _UpdateContextsAsync(CancellationToken cancellationToken)
        {
            logger.ConditionalDebug("Updating Contexts");

            var result = await database.GetContextCache(cancellationToken).ConfigureAwait(false);

            if (result != null)
            {
                contexts = result;
            }

            logger.ConditionalDebug("Updating Contexts Done");
        }

        /// <summary>
        /// Updates the Customer information
        /// </summary>
        /// <param name="cancellationToken">Cancellation Token</param>
        /// <returns>Task to wait for completion</returns>
        private static async Task _UpdateCustomersAsync(CancellationToken cancellationToken)
        {
            logger.ConditionalDebug("Updating Customers");

            var result = await database.GetCustomerCache(cancellationToken).ConfigureAwait(false);

            if (result != null)
            {
                customers = result;
            }

            logger.ConditionalDebug("Updating Customers Done");
        }

        /// <summary>
        /// Updates the Dialcode Master information
        /// </summary>
        /// <param name="cancellactionToken">Cancellation Token</param>
        /// <returns></returns>
        private static async Task _UpdateDialcodeMastersAsync(CancellationToken cancellationToken)
        {
            logger.ConditionalDebug("Updating Dialcode Master");

            var result = await database.GetDialcodeMasterCache(cancellationToken).ConfigureAwait(false);

            if (result != null)
            {
                dialcodeMasters = result;
            }

            logger.ConditionalDebug("Updating Dialcode Master Done");
        }

        /// <summary>
        /// Updates the Gateway Account information
        /// </summary>
        /// <param name="cancellationToken">Cancellation Token</param>
        /// <returns>Task to wait for completion</returns>
        private static async Task _UpdateGatewayAccountsAsync(CancellationToken cancellationToken)
        {
            logger.ConditionalDebug("Updating Gateway Accounts");

            var result = await database.GetGatewayAccountCache(cancellationToken).ConfigureAwait(false);

            if (result != null)
            {
                gatewayAccounts = result;
            }

            logger.ConditionalDebug("Updating Gateway Accounts Done");
        }

        /// <summary>
        /// Updates the Gateway IP information
        /// </summary>
        /// <param name="cancellationToken">Cancellation Token</param>
        /// <returns>Task to wait for completion</returns>
        private static async Task _UpdateGatewayIPsAsync(CancellationToken cancellationToken)
        {
            logger.ConditionalDebug("Updating Gateway IPs");

            var result = await database.GetGatewayIPCache(cancellationToken).ConfigureAwait(false);

            if (result != null)
            {
                gatewayIPs = result;
            }

            logger.ConditionalDebug("Updating Gateway IPs Done");
        }

        /// <summary>
        /// Updates the information about the gateway limits
        /// </summary>
        /// <param name="cancellationToken">Cancellation Token</param>
        /// <returns>Task to wait for completion</returns>
        private static async Task _UpdateGatewayLimitExceededAsync(CancellationToken cancellationToken)
        {
            logger.ConditionalDebug("Updating Gateway Limit Exceeded");

            var result = await database.GetGatewayLimitExceededCache(cancellationToken).ConfigureAwait(false);

            if (result != null)
            {
                gatewayLimitExceeded = result;
            }

            logger.ConditionalDebug("Updating Gateway Limit Exceeded Done");
        }

        /// <summary>
        /// Updates information about which gateway can be reached by which node
        /// </summary>
        /// <param name="cancellationToken">Cancellation Token</param>
        /// <returns>Task to wait for completion</returns>
        private static async Task _UpdateGatewaysAccessibleByNodeAsync(CancellationToken cancellationToken)
        {
            logger.ConditionalDebug("Updating Gateways Accessible by Node");

            var result = await database.GetGatewaysAccessibleByNodeCache(cancellationToken).ConfigureAwait(false);

            if (result != null)
            {
                gatewaysAccessibleByNode = result;
            }

            logger.ConditionalDebug("Updating Gateways Accessible by Node Done");
        }

        /// <summary>
        /// Updates the Gateway information
        /// </summary>
        /// <param name="cancellationToken">Cancellation Token</param>
        /// <returns>Task to wait for completion</returns>
        private static async Task _UpdateGatewaysAsync(CancellationToken cancellationToken)
        {
            logger.ConditionalDebug("Updating Gateways");

            var result = await database.GetGatewayCache(cancellationToken).ConfigureAwait(false);

            if (result != null)
            {
                gateways = result;
            }

            logger.ConditionalDebug("Updating Gateways Done");
        }

        /// <summary>
        /// Updates the information about which gateways are in which route
        /// </summary>
        /// <param name="cancellationToken">Cancellation Token</param>
        /// <returns>Task to wait for completion</returns>
        private static async Task _UpdateGatewaysForRouteAsync(CancellationToken cancellationToken)
        {
            logger.ConditionalDebug("Updating Gateways For Route");

            var result = await database.GetTargetsForRouteCache(cancellationToken).ConfigureAwait(false);

            if (result != null)
            {
                targetsForRoute = result;
            }

            logger.ConditionalDebug("Updating Gateways For Route Done");
        }

        /// <summary>
        /// Updates the Incorrect Callername information
        /// </summary>
        /// <param name="cancellationToken">Cancellation Token</param>
        /// <returns>Task to wait for completion</returns>
        private static async Task _UpdateIncorrectCallernamesAsync(CancellationToken cancellationToken)
        {
            logger.ConditionalDebug("Updating Incorrect Callernames");

            var result = await database.GetIncorrectCallernameCache(cancellationToken).ConfigureAwait(false);

            if (result != null)
            {
                incorrectCallernames = result;
            }

            logger.ConditionalDebug("Updating Incorrect Callernames Done");
        }

        /// <summary>
        /// Updates the information about which node has which internal IP
        /// </summary>
        /// <param name="cancellationToken">Cancellation Token</param>
        /// <returns>Task to wait for completion</returns>
        private static async Task _UpdateInternalNodeIPsAsync(CancellationToken cancellationToken)
        {
            logger.ConditionalDebug("Updating Internal Node IPs");

            var result = await database.GetInternalNodeIPCache(cancellationToken).ConfigureAwait(false);

            if (result != null)
            {
                internalNodeIPs = result;
            }

            logger.ConditionalDebug("Updating Internal Node IP Done");
        }

        /// <summary>
        /// Updates information about which node can be reached by which gateway
        /// </summary>
        /// <param name="cancellationToken">Cancellation Token</param>
        /// <returns>Task to wait for completion</returns>
        private static async Task _UpdateNodesAccessibleByGatewayAsync(CancellationToken cancellationToken)
        {
            logger.ConditionalDebug("Updating Nodes Accessible By Gateway");

            var result = await database.GetNodesAccessibleByGatewayCache(cancellationToken).ConfigureAwait(false);

            if (result != null)
            {
                nodesAccessibleByGateway = result;
            }

            logger.ConditionalDebug("Updating Nodes Accessible By Gateway Done");
        }

        /// <summary>
        /// Updates the Node information
        /// </summary>
        /// <param name="cancellationToken">Cancellation Token</param>
        /// <returns>Task to wait for completion</returns>
        private static async Task _UpdateNodesAsync(CancellationToken cancellationToken)
        {
            logger.ConditionalDebug("Updating Nodes");

            var result = await database.GetNodeCache(cancellationToken).ConfigureAwait(false);

            if (result != null)
            {
                nodes = result;
            }

            logger.ConditionalDebug("Updating Nodes Done");
        }

        /// <summary>
        /// Updates the information about the Number Modification Groups
        /// </summary>
        /// <param name="cancellationToken">Cancellation Token</param>
        /// <returns>Task to wait for completion</returns>
        private static async Task _UpdateNumberModificationGroupsAsync(CancellationToken cancellationToken)
        {
            logger.ConditionalDebug("Updating Number Modification Groups");

            var result = await database.GetNumberModificationPoliciesCache(cancellationToken).ConfigureAwait(false);

            if (result != null)
            {
                numberModificationGroups = result;
            }

            logger.ConditionalDebug("Updating Number Modification Groups Done");
        }

        /// <summary>
        /// Updates the information about the Routes
        /// </summary>
        /// <param name="cancellationToken">Cancellation Token</param>
        /// <returns>Task to wait for completion</returns>
        private static async Task _UpdateRoutesAsync(CancellationToken cancellationToken)
        {
            logger.ConditionalDebug("Updating Routes");

            var result = await database.GetRouteCache(cancellationToken).ConfigureAwait(false);

            if (result != null)
            {
                routes = result;
            }

            logger.ConditionalDebug("Updating Routes Done");
        }

        #endregion Reload Cache

        #endregion Functions        
    }
}