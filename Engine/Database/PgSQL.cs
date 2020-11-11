namespace CarrierLink.Controller.Engine.Database
{
    using Caching.Model;
    using NLog;
    using Npgsql;
    using NpgsqlTypes;
    using System;
    using System.Collections.Concurrent;
    using System.Collections.Generic;
    using System.Data;
    using System.Linq;
    using System.Net;
    using System.Text.RegularExpressions;
    using System.Threading;
    using System.Threading.Tasks;
    using Workers.Model;
    using Yate;

    /// <summary>
    /// This class connects to an PostgreSQL database server
    /// </summary>
    public class PgSQL : IDatabase
    {
        #region Fields

        /// <summary>
        /// Logger
        /// </summary>
        private Logger _logger;

        /// <summary>
        /// Connection String
        /// </summary>
        private string _connectionString;

        #endregion Fields

        #region Constructor

        /// <summary>
        /// Constructs the object
        /// </summary>
        /// <param name="connectionString"></param>
        public PgSQL(string connectionString)
        {
            this._logger = LogManager.GetLogger(GetType().FullName);
            this._connectionString = connectionString;
        }

        #endregion Constructor

        #region Routing

        /// <summary>
        /// Updates the Node information
        /// </summary>
        async Task<ConcurrentDictionary<string, Caching.Model.Node>> IDatabase.GetNodeCache(CancellationToken cancellationToken)
        {
            var nodes = new ConcurrentDictionary<string, Caching.Model.Node>();

            using (var con = new NpgsqlConnection(this._connectionString))
            {
                using (var com = new NpgsqlCommand("controller_get_node_cache", con))
                {
                    try
                    {
                        com.CommandType = CommandType.StoredProcedure;

                        await con.OpenAsync(cancellationToken);

                        using (var reader = await com.ExecuteReaderAsync(CommandBehavior.SingleResult, cancellationToken))
                        {
                            string ip;
                            while (await reader.ReadAsync(cancellationToken))
                            {
                                ip = reader.GetValue(1).ToString();
                                nodes.TryAdd(ip,
                                    new Caching.Model.Node(
                                        id: reader.GetInt32(0),
                                        identifier: ip
                                        )
                                    );
                            }
                        }
                    }
                    catch (Exception ex)
                    {
                        if (!cancellationToken.IsCancellationRequested)
                        {
                            this._logger.Fatal(ex, ex.Message);
                        }

                        nodes = null;
#if DEBUG
                        throw;
#endif
                    }
                    finally
                    {
                        con.Close();
                    }
                }
            }

            return nodes;
        }

        /// <summary>
        /// Updates the Incorrect Callername information
        /// </summary>
        async Task<ConcurrentDictionary<string, string>> IDatabase.GetIncorrectCallernameCache(CancellationToken cancellationToken)
        {
            var ics = new ConcurrentDictionary<string, string>();

            using (var con = new NpgsqlConnection(this._connectionString))
            {
                using (var com = new NpgsqlCommand("controller_get_incorrect_callername_cache", con))
                {
                    try
                    {
                        com.CommandType = CommandType.StoredProcedure;

                        await con.OpenAsync(cancellationToken);

                        using (var reader = await com.ExecuteReaderAsync(CommandBehavior.SingleResult, cancellationToken))
                        {
                            while (await reader.ReadAsync(cancellationToken))
                            {
                                ics.TryAdd(reader.GetString(0), reader.GetString(1));
                            }
                        }
                    }
                    catch (Exception ex)
                    {
                        if (!cancellationToken.IsCancellationRequested)
                        {
                            this._logger.Fatal(ex, ex.Message);
                        }

                        ics = null;
#if DEBUG
                        throw;
#endif
                    }
                    finally
                    {
                        con.Close();
                    }
                }
            }

            return ics;
        }

        /// <summary>
        /// Updates the Customer information
        /// </summary>
        /// <returns>Key: IP#Prefix</returns>
        async Task<ConcurrentDictionary<string, Regex>> IDatabase.GetBlacklistCache(CancellationToken cancellationToken)
        {
            var blacklist = new ConcurrentDictionary<string, Regex>();

            using (var con = new NpgsqlConnection(this._connectionString))
            {
                using (var com = new NpgsqlCommand("controller_get_blacklist_cache", con))
                {
                    try
                    {
                        com.CommandType = CommandType.StoredProcedure;

                        await con.OpenAsync(cancellationToken);

                        using (var reader = await com.ExecuteReaderAsync(CommandBehavior.SingleResult, cancellationToken))
                        {
                            while (await reader.ReadAsync(cancellationToken))
                            {
                                // RegexOptions.Compiled: Compile regex for faster access
                                blacklist.TryAdd(reader.GetString(0), new Regex(pattern: reader.GetString(0), options: RegexOptions.Compiled));
                            }
                        }
                    }
                    catch (Exception ex)
                    {
                        if (!cancellationToken.IsCancellationRequested)
                        {
                            this._logger.Fatal(ex, ex.Message);
                        }

                        blacklist = null;
#if DEBUG
                        throw;
#endif
                    }
                    finally
                    {
                        con.Close();
                    }
                }
            }

            return blacklist;
        }

        /// <summary>
        /// Updates the Customer information
        /// </summary>
        /// <returns>Key: IP#Prefix</returns>
        async Task<ConcurrentDictionary<string, Customer>> IDatabase.GetCustomerCache(CancellationToken cancellationToken)
        {
            var customers = new ConcurrentDictionary<string, Customer>();

            using (var con = new NpgsqlConnection(this._connectionString))
            {
                using (var com = new NpgsqlCommand("controller_get_customer_cache", con))
                {
                    try
                    {
                        com.CommandType = CommandType.StoredProcedure;

                        await con.OpenAsync(cancellationToken);

                        using (var reader = await com.ExecuteReaderAsync(CommandBehavior.SingleResult, cancellationToken))
                        {
                            while (await reader.ReadAsync(cancellationToken))
                            {
                                customers.TryAdd(reader.GetString(0),
                                    new Customer(
                                        id: reader.GetInt32(1),
                                        identifier: reader.GetString(0),
                                        customerIPId: reader.GetInt32(2),
                                        contextId: reader.GetInt32(3),
                                        limitOK: !reader.GetBoolean(4),
                                        fakeRinging: reader.GetBoolean(5),
                                        customerIP: reader.GetString(6),
                                        prefix: reader.IsDBNull(7) ? string.Empty : reader.GetString(7),
                                        qosGroupId: reader.GetInt32(8),
                                        companyId: reader.GetInt32(9)
                                        )
                                    );
                            }
                        }
                    }
                    catch (Exception ex)
                    {
                        if (!cancellationToken.IsCancellationRequested)
                        {
                            this._logger.Fatal(ex, ex.Message);
                        }

                        customers = null;
#if DEBUG
                        throw;
#endif
                    }
                    finally
                    {
                        con.Close();
                    }
                }
            }

            return customers;
        }

        /// <summary>
        /// Updates the information about which gateway are in which route
        /// </summary>
        /// <returns>Key: Route ID</returns>
        async Task<ConcurrentDictionary<int, TargetsForRoute>> IDatabase.GetTargetsForRouteCache(CancellationToken cancellationToken)
        {
            var routeToTargets = new ConcurrentDictionary<int, TargetsForRoute>();

            using (var con = new NpgsqlConnection(this._connectionString))
            {
                using (var com = new NpgsqlCommand("controller_get_targets_for_route_cache", con))
                {
                    try
                    {
                        com.CommandType = CommandType.StoredProcedure;

                        await con.OpenAsync(cancellationToken);

                        int routeId = 0;
                        TargetsForRoute rtg = null;
                        using (var reader = await com.ExecuteReaderAsync(CommandBehavior.SingleResult, cancellationToken))
                        {
                            int? gatewayId = null;
                            int? contextId = null;
                            while (await reader.ReadAsync(cancellationToken))
                            {
                                if (reader.GetInt32(0) != routeId)
                                {
                                    rtg = new TargetsForRoute(routeId: reader.GetInt32(0), targets: new List<RouteTarget>());

                                    routeToTargets.TryAdd(rtg.RouteId, rtg);

                                    routeId = reader.GetInt32(0);
                                }

                                // either col1 (gatewayId) or the other (else) is null
                                if (!reader.IsDBNull(1))
                                {
                                    gatewayId = reader.GetInt32(1);
                                    contextId = null;
                                }
                                else
                                {
                                    contextId = reader.GetInt32(2);
                                    gatewayId = null;
                                }

                                rtg.Targets.Add(new RouteTarget(gatewayId, contextId));
                            }
                        }
                    }
                    catch (Exception ex)
                    {
                        if (!cancellationToken.IsCancellationRequested)
                        {
                            this._logger.Fatal(ex, ex.Message);
                        }

                        routeToTargets = null;
#if DEBUG
                        throw;
#endif
                    }
                    finally
                    {
                        con.Close();
                    }
                }
            }

            return routeToTargets;
        }

        /// <summary>
        /// Updates dialcode master information
        /// </summary>
        /// <param name="cancellationToken"></param>
        /// <returns></returns>
        async Task<ConcurrentDictionary<string, DialcodeMaster>> IDatabase.GetDialcodeMasterCache(CancellationToken cancellationToken)
        {
            var dialcodeMasters = new ConcurrentDictionary<string, DialcodeMaster>();

            using (var con = new NpgsqlConnection(this._connectionString))
            {
                using (var com = new NpgsqlCommand("controller_get_dialcode_master_cache", con))
                {
                    com.CommandType = CommandType.StoredProcedure;

                    try
                    {
                        await con.OpenAsync(cancellationToken);

                        using (var reader = await com.ExecuteReaderAsync(CommandBehavior.SingleResult, cancellationToken))
                        {
                            while (await reader.ReadAsync(cancellationToken))
                            {
                                dialcodeMasters.TryAdd(reader.GetString(2), new DialcodeMaster(reader.GetInt32(0), reader.GetBoolean(1), reader.GetString(2)));
                            }
                        }
                    }
                    catch (Exception ex)
                    {
                        if (!cancellationToken.IsCancellationRequested)
                        {
                            this._logger.Fatal(ex, ex.Message);
                        }

                        dialcodeMasters = null;
#if DEBUG
                        throw;
#endif
                    }
                    finally
                    {
                        con.Close();
                    }
                }
            }

            return dialcodeMasters;
        }

        /// <summary>
        /// Updates information about which gateway can be reached by which node
        /// </summary>
        /// <returns>Key: Node ID, List of Gateway IDs</returns>
        async Task<ConcurrentDictionary<int, List<int>>> IDatabase.GetGatewaysAccessibleByNodeCache(CancellationToken cancellationToken)
        {
            var gatewaysAccessibleByNode = new ConcurrentDictionary<int, List<int>>();

            using (var con = new NpgsqlConnection(this._connectionString))
            {
                using (var com = new NpgsqlCommand("controller_get_gateways_accessible_by_node_cache", con))
                {
                    try
                    {
                        com.CommandType = CommandType.StoredProcedure;

                        await con.OpenAsync(cancellationToken);

                        int nodeId = 0;

                        using (var reader = await com.ExecuteReaderAsync(CommandBehavior.SingleResult, cancellationToken))
                        {
                            while (await reader.ReadAsync(cancellationToken))
                            {
                                // create new list
                                if (reader.GetInt32(0) != nodeId)
                                {
                                    gatewaysAccessibleByNode.TryAdd(reader.GetInt32(0), new List<int>());
                                    nodeId = reader.GetInt32(0);
                                }

                                // add record
                                gatewaysAccessibleByNode.First(g => g.Key == reader.GetInt32(0)).Value.Add(reader.GetInt32(1));
                            }
                        }
                    }
                    catch (Exception ex)
                    {
                        if (!cancellationToken.IsCancellationRequested)
                        {
                            this._logger.Fatal(ex, ex.Message);
                        }

                        gatewaysAccessibleByNode = null;
#if DEBUG
                        throw;
#endif
                    }
                    finally
                    {
                        con.Close();
                    }
                }
            }

            return gatewaysAccessibleByNode;
        }

        /// <summary>
        /// Updates information about which node can be reached by which gateway
        /// </summary>
        /// <returns>Key: Gateway ID, List of Node IDs</returns>
        async Task<ConcurrentDictionary<int, List<int>>> IDatabase.GetNodesAccessibleByGatewayCache(CancellationToken cancellationToken)
        {
            var nodesAccessiblyByGateway = new ConcurrentDictionary<int, List<int>>();

            using (var con = new NpgsqlConnection(this._connectionString))
            {
                using (var com = new NpgsqlCommand("controller_get_nodes_accessible_by_gateway_cache", con))
                {
                    try
                    {
                        com.CommandType = CommandType.StoredProcedure;

                        await con.OpenAsync(cancellationToken);

                        int gatewayId = 0;

                        using (var reader = await com.ExecuteReaderAsync(CommandBehavior.SingleResult, cancellationToken))
                        {
                            while (await reader.ReadAsync(cancellationToken))
                            {
                                // create new list
                                if (reader.GetInt32(0) != gatewayId)
                                {
                                    nodesAccessiblyByGateway.TryAdd(reader.GetInt32(0), new List<int>());
                                    gatewayId = reader.GetInt32(0);
                                }

                                // add record
                                nodesAccessiblyByGateway.First(g => g.Key == reader.GetInt32(0)).Value.Add(reader.GetInt32(1));
                            }
                        }
                    }
                    catch (Exception ex)
                    {
                        if (!cancellationToken.IsCancellationRequested)
                        {
                            this._logger.Fatal(ex, ex.Message);
                        }

                        nodesAccessiblyByGateway = null;
#if DEBUG
                        throw;
#endif
                    }
                    finally
                    {
                        con.Close();
                    }
                }
            }

            return nodesAccessiblyByGateway;
        }

        /// <summary>
        /// Updates the Context information
        /// </summary>
        /// <returns>Key: ID</returns>
        async Task<ConcurrentDictionary<int, Context>> IDatabase.GetContextCache(CancellationToken cancellationToken)
        {
            var contexts = new ConcurrentDictionary<int, Context>();

            using (var con = new NpgsqlConnection(this._connectionString))
            {
                using (var com = new NpgsqlCommand("controller_get_context_cache", con))
                {
                    com.CommandType = CommandType.StoredProcedure;

                    try
                    {
                        await con.OpenAsync(cancellationToken);

                        using (var reader = await com.ExecuteReaderAsync(CommandBehavior.SingleResult, cancellationToken))
                        {
                            int? blendPercentage, blendToContextId;

                            while (await reader.ReadAsync(cancellationToken))
                            {
                                // if 'blendPercentage' (col 11) is null, the other is null too, see check constraint in table
                                if (reader.IsDBNull(6))
                                {
                                    blendPercentage = null;
                                    blendToContextId = null;
                                }
                                else
                                {
                                    blendPercentage = reader.GetInt32(6);
                                    blendToContextId = reader.GetInt32(7);
                                }

                                contexts.TryAdd(reader.GetInt32(0),
                                    new Context(
                                        id: reader.GetInt32(0),
                                        isLeastCostRouting: reader.GetBoolean(1),
                                        timeout: reader.GetInt32(2),
                                        enableLCRWithoutRate: reader.GetBoolean(3),
                                        forkConnectBehavior: (ForkConnectBehavior)reader.GetInt16(4),
                                        forkConnectBehaviorTimeout: reader.GetInt32(5),
                                        lcrBlendPercentage: blendPercentage,
                                        lcrBlendToContextId: blendToContextId
                                        )
                                    );
                            }
                        }
                    }
                    catch (Exception ex)
                    {
                        if (!cancellationToken.IsCancellationRequested)
                        {
                            this._logger.Fatal(ex, ex.Message);
                        }

                        contexts = null;
#if DEBUG
                        throw;
#endif
                    }
                    finally
                    {
                        con.Close();
                    }
                }
            }

            return contexts;
        }

        /// <summary>
        /// Updates the Gateway information
        /// </summary>
        /// <returns>Key: ID</returns>
        async Task<ConcurrentDictionary<int, Gateway>> IDatabase.GetGatewayCache(CancellationToken cancellationToken)
        {
            var gateways = new ConcurrentDictionary<int, Gateway>();

            using (var con = new NpgsqlConnection(this._connectionString))
            {
                using (var com = new NpgsqlCommand("controller_get_gateway_cache", con))
                {
                    try
                    {
                        com.CommandType = CommandType.StoredProcedure;

                        await con.OpenAsync(cancellationToken);

                        using (var reader = await com.ExecuteReaderAsync(CommandBehavior.SingleResult, cancellationToken))
                        {
                            while (await reader.ReadAsync(cancellationToken))
                            {
                                // Nullable
                                int? numberModificationGroup = null;
                                if (!reader.IsDBNull(3))
                                {
                                    numberModificationGroup = reader.GetInt32(3);
                                }
                                int? concurrentLinesLimit = null;
                                if (!reader.IsDBNull(4))
                                {
                                    concurrentLinesLimit = reader.GetInt32(4);
                                }

                                gateways.TryAdd(reader.GetInt32(1),
                                    new Gateway(
                                        type: reader.GetString(0) == "Account" ? GatewayType.Account : GatewayType.IP,
                                        id: reader.GetInt32(1),
                                        removeCountryCode: reader.GetBoolean(2),
                                        numberModificationGroup: numberModificationGroup,
                                        concurrentLinesLimit: concurrentLinesLimit,
                                        prefix: reader.IsDBNull(5) ? string.Empty : reader.GetString(5),
                                        format: reader.GetString(6),
                                        formats: reader.GetString(7),
                                        outgoingConnectionId: reader.GetString(8),
                                        qosGroupId: reader.GetInt32(9),
                                        companyId: reader.GetInt32(10)
                                        )
                                    );
                            }
                        }
                    }
                    catch (Exception ex)
                    {
                        if (!cancellationToken.IsCancellationRequested)
                        {
                            this._logger.Fatal(ex, ex.Message);
                        }

                        gateways = null;
#if DEBUG
                        throw;
#endif
                    }
                    finally
                    {
                        con.Close();
                    }
                }
            }

            return gateways;
        }

        /// <summary>
        /// Updates the Gateway Account information
        /// </summary>
        /// <returns>Gateway ID</returns>
        async Task<ConcurrentDictionary<int, List<GatewayAccount>>> IDatabase.GetGatewayAccountCache(CancellationToken cancellationToken)
        {
            var gatewayAccounts = new ConcurrentDictionary<int, List<GatewayAccount>>();

            using (var con = new NpgsqlConnection(this._connectionString))
            {
                using (var com = new NpgsqlCommand("controller_get_gateway_account_cache", con))
                {
                    try
                    {
                        com.CommandType = CommandType.StoredProcedure;

                        await con.OpenAsync(cancellationToken);

                        int gatewayId = 0;

                        using (var reader = await com.ExecuteReaderAsync(CommandBehavior.SingleResult, cancellationToken))
                        {
                            while (await reader.ReadAsync(cancellationToken))
                            {
                                if (reader.GetInt32(6) != gatewayId)
                                {
                                    gatewayAccounts.TryAdd(reader.GetInt32(6), new List<GatewayAccount>());
                                    gatewayId = reader.GetInt32(6);
                                }

                                gatewayAccounts[gatewayId].Add(
                                    new GatewayAccount(
                                        id: reader.GetInt32(0).ToString(),
                                        account: reader.IsDBNull(1) ? string.Empty : reader.GetString(1),
                                        protocol: reader.IsDBNull(2) ? string.Empty : reader.GetString(2),
                                        newCaller: reader.IsDBNull(3) ? string.Empty : reader.GetString(3),
                                        newCallername: reader.IsDBNull(4) ? string.Empty : reader.GetString(4),
                                        billTime: reader.GetInt64(5),
                                        gatewayId: reader.GetInt32(6).ToString()
                                        )
                                    );
                            }
                        }
                    }
                    catch (Exception ex)
                    {
                        if (!cancellationToken.IsCancellationRequested)
                        {
                            this._logger.Fatal(ex, ex.Message);
                        }

                        gatewayAccounts = null;
#if DEBUG
                        throw;
#endif
                    }
                    finally
                    {
                        con.Close();
                    }
                }
            }

            return gatewayAccounts;
        }

        /// <summary>
        /// Updates the Gateway IP information
        /// </summary>
        /// <returns>Gateway ID</returns>
        async Task<ConcurrentDictionary<int, List<GatewayIP>>> IDatabase.GetGatewayIPCache(CancellationToken cancellationToken)
        {
            var gatewayIPs = new ConcurrentDictionary<int, List<GatewayIP>>();

            using (var con = new NpgsqlConnection(this._connectionString))
            {
                using (var com = new NpgsqlCommand("controller_get_gateway_ip_cache", con))
                {
                    try
                    {
                        com.CommandType = CommandType.StoredProcedure;

                        await con.OpenAsync(cancellationToken);

                        int gatewayId = 0;
                        using (var reader = await com.ExecuteReaderAsync(CommandBehavior.SingleResult, cancellationToken))
                        {
                            while (await reader.ReadAsync(cancellationToken))
                            {
                                if (reader.GetInt32(9) != gatewayId)
                                {
                                    gatewayIPs.TryAdd(reader.GetInt32(9), new List<GatewayIP>());
                                    gatewayId = reader.GetInt32(9);
                                }

                                gatewayIPs[gatewayId].Add(
                                    new GatewayIP(
                                        id: reader.GetInt32(0).ToString(),
                                        address: reader.GetString(1),
                                        port: reader.GetInt32(2).ToString(),
                                        protocol: reader.GetString(3),
                                        rtpAddress: reader.IsDBNull(4) ? string.Empty : reader.GetString(4),
                                        rtpPort: reader.IsDBNull(5) ? string.Empty : reader.GetInt32(5).ToString(),
                                        rtpForward: reader.GetBoolean(6).ToString(Formats.CultureInfo).ToLowerInvariant(),
                                        sipPAssertedIdentity: reader.IsDBNull(7) ? string.Empty : reader.GetString(7),
                                        billTime: reader.GetInt64(8),
                                        gatewayId: reader.GetInt32(9).ToString()
                                        )
                                    );
                            }
                        }
                    }
                    catch (Exception ex)
                    {
                        if (!cancellationToken.IsCancellationRequested)
                        {
                            this._logger.Fatal(ex, ex.Message);
                        }

                        gatewayIPs = null;
#if DEBUG
                        throw;
#endif
                    }
                    finally
                    {
                        con.Close();
                    }
                }
            }

            return gatewayIPs;
        }

        /// <summary>
        /// Updates the information about the gateway billtime limits
        /// </summary>
        /// <returns>Key: Gateway ID, Value: Billtime Limit Exceeded</returns>
        async Task<ConcurrentDictionary<int, bool>> IDatabase.GetGatewayLimitExceededCache(CancellationToken cancellationToken)
        {
            var gatewayLimitStates = new ConcurrentDictionary<int, bool>();

            using (var con = new NpgsqlConnection(this._connectionString))
            {
                using (var com = new NpgsqlCommand("controller_get_gateway_limit_exceeded_cache", con))
                {
                    try
                    {
                        com.CommandType = CommandType.StoredProcedure;

                        await con.OpenAsync(cancellationToken);

                        using (var reader = await com.ExecuteReaderAsync(CommandBehavior.SingleResult, cancellationToken))
                        {
                            while (await reader.ReadAsync(cancellationToken))
                            {
                                gatewayLimitStates.TryAdd(reader.GetInt32(0), reader.GetBoolean(1));
                            }
                        }
                    }
                    catch (Exception ex)
                    {
                        if (!cancellationToken.IsCancellationRequested)
                        {
                            this._logger.Fatal(ex, ex.Message);
                        }

                        gatewayLimitStates = null;
#if DEBUG
                        throw;
#endif
                    }
                    finally
                    {
                        con.Close();
                    }
                }
            }

            return gatewayLimitStates;
        }

        /// <summary>
        /// Updates the information about which node has which internal IP
        /// </summary>
        /// <returns>Key: Node ID</returns>
        async Task<ConcurrentDictionary<int, NodeIP>> IDatabase.GetInternalNodeIPCache(CancellationToken cancellationToken)
        {
            var internalNodeIPs = new ConcurrentDictionary<int, NodeIP>();

            using (var con = new NpgsqlConnection(this._connectionString))
            {
                using (var com = new NpgsqlCommand("controller_get_internal_node_ip_cache", con))
                {
                    try
                    {
                        com.CommandType = CommandType.StoredProcedure;

                        await con.OpenAsync(cancellationToken);

                        using (var reader = await com.ExecuteReaderAsync(CommandBehavior.SingleResult, cancellationToken))
                        {
                            while (await reader.ReadAsync(cancellationToken))
                            {
                                internalNodeIPs.TryAdd(reader.GetInt32(0),
                                    new NodeIP(
                                        address: reader.GetString(1),
                                        port: reader.GetInt32(2).ToString()
                                        )
                                    );
                            }
                        }
                    }
                    catch (Exception ex)
                    {
                        if (!cancellationToken.IsCancellationRequested)
                        {
                            this._logger.Fatal(ex, ex.Message);
                        }

                        internalNodeIPs = null;
#if DEBUG
                        throw;
#endif
                    }
                    finally
                    {
                        con.Close();
                    }
                }
            }

            return internalNodeIPs;
        }

        /// <summary>
        /// Updates Number Modification Policies
        /// </summary>
        /// <returns>Key: Number Modification Group ID</returns>
        async Task<ConcurrentDictionary<int, List<NumberModificationPolicy>>> IDatabase.GetNumberModificationPoliciesCache(CancellationToken cancellationToken)
        {
            var numberModificationPolicies = new ConcurrentDictionary<int, List<NumberModificationPolicy>>();

            using (var con = new NpgsqlConnection(this._connectionString))
            {
                using (var com = new NpgsqlCommand("controller_get_number_modification_policies_cache", con))
                {
                    try
                    {
                        com.CommandType = CommandType.StoredProcedure;

                        await con.OpenAsync(cancellationToken);

                        using (var reader = await com.ExecuteReaderAsync(CommandBehavior.SingleResult, cancellationToken))
                        {
                            int nmgId = 0;
                            List<NumberModificationPolicy> currentList = null;
                            while (await reader.ReadAsync(cancellationToken))
                            {
                                if (nmgId != reader.GetInt32(0))
                                {
                                    nmgId = reader.GetInt32(0);
                                    currentList = new List<NumberModificationPolicy>();
                                    numberModificationPolicies.TryAdd(reader.GetInt32(0), currentList);
                                }

                                currentList.Add(
                                    new NumberModificationPolicy(
                                        pattern: new System.Text.RegularExpressions.Regex(reader.GetString(1), RegexOptions.Compiled),
                                        removePrefix: reader.IsDBNull(2) ? null : reader.GetString(2),
                                        addPrefix: reader.IsDBNull(3) ? null : reader.GetString(3),
                                        priority: reader.GetInt32(4)
                                        )
                                    );
                            }
                        }
                    }
                    catch (Exception ex)
                    {
                        if (!cancellationToken.IsCancellationRequested)
                        {
                            this._logger.Fatal(ex, ex.Message);
                        }

                        numberModificationPolicies = null;
#if DEBUG
                        throw;
#endif
                    }
                    finally
                    {
                        con.Close();
                    }
                }
            }

            return numberModificationPolicies;
        }

        /// <summary>
        /// Returns context - gateway relation
        /// </summary>
        /// <returns></returns>
        async Task<ConcurrentBag<ContextGateway>> IDatabase.GetContextGatewayCache(CancellationToken cancellationToken)
        {
            var contextGateways = new ConcurrentBag<ContextGateway>();

            using (var con = new NpgsqlConnection(this._connectionString))
            {
                using (var com = new NpgsqlCommand("controller_get_context_gateway_cache", con))
                {
                    try
                    {
                        com.CommandType = CommandType.StoredProcedure;
                        await con.OpenAsync(cancellationToken);

                        using (var result = await com.ExecuteReaderAsync(CommandBehavior.SingleResult, cancellationToken))
                        {
                            while (await result.ReadAsync(cancellationToken))
                            {
                                contextGateways.Add(
                                    new ContextGateway(
                                        contextId: result.GetInt32(0),
                                        gatewayId: result.GetInt32(1)
                                        )
                                    );
                            }
                        }
                    }
                    catch (Exception ex)
                    {
                        if (!cancellationToken.IsCancellationRequested)
                        {
                            this._logger.Fatal(ex, ex.Message);
                        }

                        contextGateways = null;
#if DEBUG
                        throw;
#endif
                    }
                    finally
                    {
                        con.Close();
                    }
                }
            }

            return contextGateways;
        }

        /// <summary>
        /// Returns routes to cache
        /// </summary>
        /// <param name="cancellationToken"></param>
        /// <returns>Route for Context</returns>
        async Task<List<Caching.Model.Route>> IDatabase.GetRouteCache(CancellationToken cancellationToken)
        {
            var routes = new List<Caching.Model.Route>();

            using (var con = new NpgsqlConnection(this._connectionString))
            {
                using (var com = new NpgsqlCommand("controller_get_route_cache", con))
                {
                    com.CommandType = CommandType.StoredProcedure;

                    try
                    {
                        await con.OpenAsync(cancellationToken);

                        using (var reader = await com.ExecuteReaderAsync(CommandBehavior.SingleResult, cancellationToken))
                        {
                            int? blendPercentage, blendToContextId;

                            while (await reader.ReadAsync(cancellationToken))
                            {
                                // if 'blendPercentage' (col 11) is null, the other is null too, see check constraint in table
                                if (reader.IsDBNull(11))
                                {
                                    blendPercentage = null;
                                    blendToContextId = null;
                                }
                                else
                                {
                                    blendPercentage = reader.GetInt32(11);
                                    blendToContextId = reader.GetInt32(12);
                                }

                                routes.Add(new Caching.Model.Route(
                                    id: reader.GetInt32(0),
                                    contextId: reader.GetInt32(1),
                                    pattern: reader.GetString(2),
                                    action: reader.GetString(3),
                                    sort: reader.GetInt32(4),
                                    isDid: reader.GetBoolean(5),
                                    newCaller: reader.GetString(6),
                                    newCallername: reader.GetString(7),
                                    ignoreMissingRate: reader.GetBoolean(8),
                                    fallbackTolcr: reader.GetBoolean(9),
                                    timeout: reader.GetInt32(10),
                                    blendPercentage: blendPercentage,
                                    blendToContextId: blendToContextId
                                    ));
                            }
                        }
                    }
                    catch (Exception ex)
                    {
                        if (!cancellationToken.IsCancellationRequested)
                        {
                            this._logger.Fatal(ex, ex.Message);
                        }
#if DEBUG
                        throw;
#endif
                    }
                    finally
                    {
                        con.Close();
                    }
                }
            }

            return routes;
        }

        #endregion Routing

        #region Controller

        /// <summary>
        /// Returns information for a node
        /// </summary>
        /// <param name="id"></param>
        /// <returns></returns>
        async Task<int> IDatabase.GetNodeInfo(int id, CancellationToken cancellationToken)
        {
            int criticalLoad = 80;

            using (var con = new NpgsqlConnection(this._connectionString))
            {
                using (var com = new NpgsqlCommand("controller_node_info", con))
                {
                    try
                    {
                        com.CommandType = CommandType.StoredProcedure;
                        com.Parameters.Add("p_node_id", NpgsqlDbType.Integer).Value = id;

                        await con.OpenAsync(cancellationToken);

                        using (var reader = await com.ExecuteReaderAsync(cancellationToken))
                        {
                            if (reader.HasRows)
                            {
                                await reader.ReadAsync(cancellationToken);

                                criticalLoad = reader.GetInt32(0);
                            }
                        }
                    }
                    catch (Exception ex)
                    {
                        if (!cancellationToken.IsCancellationRequested)
                        {
                            this._logger.Fatal(ex, ex.Message);
                        }
#if DEBUG
                        throw;
#endif
                    }
                    finally
                    {
                        con.Close();
                    }
                }
            }

            return criticalLoad;
        }

        /// <summary>
        /// Updates customer and gateway limits
        /// </summary>
        /// <param name="cancellationToken"></param>
        /// <returns></returns>
        async Task IDatabase.EndpointCreditUpdate(CancellationToken cancellationToken)
        {
            using (var con = new NpgsqlConnection(this._connectionString))
            {
                using (var com = new NpgsqlCommand("controller_endpoint_credit_update", con))
                {
                    try
                    {
                        com.CommandType = CommandType.StoredProcedure;

                        await con.OpenAsync();

                        await com.ExecuteNonQueryAsync();
                    }
                    catch (Exception ex)
                    {
                        if (!cancellationToken.IsCancellationRequested)
                        {
                            this._logger.Fatal(ex, ex.Message);
                        }
#if DEBUG
                        throw;
#endif
                    }
                    finally
                    {
                        con.Close();
                    }
                }
            }
        }

        /// <summary>
        /// Retrieves the Controller Id
        /// </summary>
        /// <param name="name"></param>
        /// <param name="cancellationToken"></param>
        /// <returns></returns>
        async Task<int> IDatabase.ControllerStartup(string name, CancellationToken cancellationToken)
        {
            int controlServerId = 0;

            using (var con = new NpgsqlConnection(this._connectionString))
            {
                using (var com = new NpgsqlCommand("controller_startup", con))
                {
                    try
                    {
                        com.CommandType = CommandType.StoredProcedure;
                        com.Parameters.Add("p_controller", NpgsqlDbType.Text).Value = name;

                        await con.OpenAsync(cancellationToken);

                        controlServerId = (int)await com.ExecuteScalarAsync(cancellationToken);
                    }
                    catch (Exception ex)
                    {
                        if (!cancellationToken.IsCancellationRequested)
                        {
                            this._logger.Fatal(ex, ex.Message);
                        }
#if DEBUG
                        throw;
#endif
                    }
                    finally
                    {
                        con.Close();
                    }
                }
            }

            return controlServerId;
        }

        /// <summary>
        /// Sets Controller 'online'-flag to false
        /// </summary>
        /// <param name="id"></param>
        /// <param name="cancellationToken"></param>
        /// <returns></returns>
        async Task IDatabase.ControllerShutdown(int id, CancellationToken cancellationToken)
        {
            using (var con = new NpgsqlConnection(this._connectionString))
            {
                using (var com = new NpgsqlCommand("controller_shutdown", con))
                {
                    try
                    {
                        com.CommandType = CommandType.StoredProcedure;
                        com.Parameters.Add("p_controller_id", NpgsqlDbType.Integer).Value = id;

                        await con.OpenAsync(cancellationToken);

                        await com.ExecuteNonQueryAsync(cancellationToken);
                    }
                    catch (Exception ex)
                    {
                        if (!cancellationToken.IsCancellationRequested)
                        {
                            this._logger.Fatal(ex, ex.Message);
                        }
#if DEBUG
                        throw;
#endif
                    }
                    finally
                    {
                        con.Close();
                    }
                }
            }
        }

        /// <summary>
        /// Updates 'last seen'-flag
        /// </summary>
        /// <param name="id"></param>
        /// <param name="cancellationToken"></param>
        /// <returns></returns>
        async Task IDatabase.ControllerIsAlive(int id, CancellationToken cancellationToken)
        {
            using (var con = new NpgsqlConnection(this._connectionString))
            {
                using (var com = new NpgsqlCommand("controller_is_alive", con))
                {
                    try
                    {
                        com.CommandType = CommandType.StoredProcedure;
                        com.Parameters.Add("p_controller_id", NpgsqlDbType.Integer).Value = id;

                        await con.OpenAsync(cancellationToken);

                        await com.ExecuteNonQueryAsync(cancellationToken);
                    }
                    catch (Exception ex)
                    {
                        if (!cancellationToken.IsCancellationRequested)
                        {
                            this._logger.Fatal(ex, ex.Message);
                        }
#if DEBUG
                        throw;
#endif
                    }
                    finally
                    {
                        con.Close();
                    }
                }
            }
        }

        /// <summary>
        /// Adds record to Controller log
        /// </summary>
        /// <param name="id"></param>
        /// <param name="action"></param>
        /// <param name="cancellationToken"></param>
        /// <returns></returns>
        async Task IDatabase.ControllerLog(int id, string action, CancellationToken cancellationToken)
        {
            using (var con = new NpgsqlConnection(this._connectionString))
            {
                using (var com = new NpgsqlCommand("controller_log", con))
                {
                    try
                    {
                        com.CommandType = CommandType.StoredProcedure;
                        com.Parameters.Add("p_controller_id", NpgsqlDbType.Integer).Value = id;
                        com.Parameters.Add("p_action", NpgsqlDbType.Text).Value = action;

                        await con.OpenAsync(cancellationToken);

                        await com.ExecuteNonQueryAsync(cancellationToken);
                    }
                    catch (Exception ex)
                    {
                        if (!cancellationToken.IsCancellationRequested)
                        {
                            this._logger.Fatal(ex, ex.Message);
                        }
#if DEBUG
                        throw;
#endif
                    }
                    finally
                    {
                        con.Close();
                    }
                }
            }
        }

        /// <summary>
        /// Retrieves Controller connections and states
        /// </summary>
        /// <param name="id"></param>
        /// <param name="cancellationToken"></param>
        /// <returns></returns>
        async Task<IEnumerable<ControllerConnection>> IDatabase.ControllerConnectons(int id, CancellationToken cancellationToken)
        {
            var connections = new List<ControllerConnection>();

            using (var con = new NpgsqlConnection(this._connectionString))
            {
                using (var com = new NpgsqlCommand("controller_connections", con))
                {
                    try
                    {
                        com.CommandType = CommandType.StoredProcedure;
                        com.Parameters.Add("p_controller_id", NpgsqlDbType.Integer).Value = id;

                        await con.OpenAsync(cancellationToken);

                        using (var reader = await com.ExecuteReaderAsync(cancellationToken))
                        {
                            while (await reader.ReadAsync(cancellationToken))
                            {
                                connections.Add(new ControllerConnection(
                                    reader.GetInt32(0),
                                    (ControlState)reader.GetInt32(1),
                                    reader.GetBoolean(2))
                                    );
                            }
                        }
                    }
                    catch (Exception ex)
                    {
                        if (!cancellationToken.IsCancellationRequested)
                        {
                            this._logger.Fatal(ex, ex.Message);
                        }
#if DEBUG
                        throw;
#endif
                    }
                    finally
                    {
                        con.Close();
                    }
                }
            }

            return connections;
        }

        /// <summary>
        /// Updates Controller connection state
        /// </summary>
        /// <param name="controlServerid"></param>
        /// <param name="nodeId"></param>
        /// <param name="status"></param>
        /// <param name="cancellationToken"></param>
        /// <returns></returns>
        async Task IDatabase.ControllerConnectionStatusUpdate(int controlServerid, int nodeId, ControlState status, CancellationToken cancellationToken)
        {
            using (var con = new NpgsqlConnection(this._connectionString))
            {
                using (var com = new NpgsqlCommand("controller_connection_status_update", con))
                {
                    try
                    {
                        com.CommandType = CommandType.StoredProcedure;
                        com.Parameters.Add("p_controller_id", NpgsqlDbType.Integer).Value = controlServerid;
                        com.Parameters.Add("p_node_id", NpgsqlDbType.Integer).Value = nodeId;
                        com.Parameters.Add("p_status", NpgsqlDbType.Integer).Value = (int)status;

                        await con.OpenAsync(cancellationToken);

                        await com.ExecuteNonQueryAsync(cancellationToken);
                    }
                    catch (Exception ex)
                    {
                        if (!cancellationToken.IsCancellationRequested)
                        {
                            this._logger.Fatal(ex, ex.Message);
                        }
#if DEBUG
                        throw;
#endif
                    }
                    finally
                    {
                        con.Close();
                    }
                }
            }
        }

        /// <summary>
        /// Returns node endpoint information for Core to connect
        /// </summary>
        /// <param name="nodeId"></param>
        /// <param name="cancellationToken"></param>
        /// <returns></returns>
        async Task<NodeInfo> IDatabase.GetNodeConnectionInfo(int nodeId, CancellationToken cancellationToken)
        {
            NodeInfo nodeInfo = null;

            using (var con = new NpgsqlConnection(this._connectionString))
            {
                using (var com = new NpgsqlCommand("controller_get_node_connection_info", con))
                {
                    try
                    {
                        com.CommandType = CommandType.StoredProcedure;

                        com.Parameters.Add("p_id", NpgsqlDbType.Integer).Value = nodeId;

                        await con.OpenAsync(cancellationToken);

                        var reader = await com.ExecuteReaderAsync(CommandBehavior.SingleResult, cancellationToken);
                        await reader.ReadAsync(cancellationToken);

                        nodeInfo = new NodeInfo(IPAddress.Parse(reader.GetString(0)), reader.GetInt32(1), nodeId, reader.GetInt32(2));
                    }
                    catch (Exception ex)
                    {
                        if (!cancellationToken.IsCancellationRequested)
                        {
                            this._logger.Fatal(ex, ex.Message);
                        }
#if DEBUG
                        throw;
#endif
                    }
                    finally
                    {
                        con.Close();
                    }
                }
            }

            this._logger.ConditionalDebug("Node retrieved");

            return nodeInfo;
        }

        /// <summary>
        /// Updates last contact for node
        /// </summary>
        /// <param name="node"></param>
        /// <param name="lastEngineTimer"></param>
        /// <param name="cancellationToken"></param>
        /// <returns>Task to wait for</returns>
        async Task IDatabase.NodeKeepAlive(INode node, DateTime lastEngineTimer, CancellationToken cancellationToken)
        {
            using (var con = new NpgsqlConnection(this._connectionString))
            {
                using (var com = new NpgsqlCommand("controller_node_keepalive", con))
                {
                    try
                    {
                        com.CommandType = CommandType.StoredProcedure;

                        com.Parameters.Add("p_id", NpgsqlDbType.Integer).Value = node.Id;
                        com.Parameters.Add("p_timestamp", NpgsqlDbType.Timestamp).Value = lastEngineTimer;

                        await con.OpenAsync(cancellationToken);

                        await com.ExecuteNonQueryAsync(cancellationToken);
                    }
                    catch (Exception ex)
                    {
                        if (!cancellationToken.IsCancellationRequested)
                        {
                            this._logger.Fatal(ex, ex.Message);
                        }
#if DEBUG
                        throw;
#endif
                    }
                    finally
                    {
                        con.Close();
                    }
                }
            }

            this._logger.ConditionalDebug("Node retrieved");
        }

        #endregion Controller

        #region Call Data Records

        /// <summary>
        /// Writes a CallDataRecord into the database
        /// </summary>
        /// <param name="callDataRecord"></param>
        /// <returns></returns>
        async Task<bool> IDatabase.WriteCDR(CallDataRecord callDataRecord)
        {
            bool success = false;

            using (var con = new NpgsqlConnection(this._connectionString))
            {
                using (var com = new NpgsqlCommand("controller_cdr_upsert", con))
                {
                    try
                    {
                        com.CommandType = CommandType.StoredProcedure;

                        com.Parameters.Add("p_nodeid", NpgsqlDbType.Integer).Value = callDataRecord.CLNodeId;
                        com.Parameters.Add("p_sqltime", NpgsqlDbType.TimestampTz).Value = callDataRecord.CLSQLTime.ToUniversalTime();
                        com.Parameters.Add("p_yatetime", NpgsqlDbType.Bigint).Value = callDataRecord.YYateTime;
                        com.Parameters.Add("p_billid", NpgsqlDbType.Text).Value = callDataRecord.YBillId;
                        com.Parameters.Add("p_chan", NpgsqlDbType.Text).Value = callDataRecord.YChan;
                        com.Parameters.Add("p_address", NpgsqlDbType.Inet).Value = callDataRecord.YAddress.Address;
                        com.Parameters.Add("p_port", NpgsqlDbType.Integer).Value = callDataRecord.YAddress.Port;
                        com.Parameters.Add("p_caller", NpgsqlDbType.Text).Value = callDataRecord.YCaller;
                        com.Parameters.Add("p_callername", NpgsqlDbType.Text).Value = callDataRecord.YCallername;
                        com.Parameters.Add("p_called", NpgsqlDbType.Text).Value = callDataRecord.YCalled;
                        com.Parameters.Add("p_ringtime", NpgsqlDbType.Bigint).Value = callDataRecord.YRingtime;
                        com.Parameters.Add("p_billtime", NpgsqlDbType.Bigint).Value = callDataRecord.YBilltime;
                        com.Parameters.Add("p_duration", NpgsqlDbType.Bigint).Value = callDataRecord.YDuration;
                        com.Parameters.Add("p_direction", NpgsqlDbType.Text).Value = callDataRecord.YDirection.ToString().ToLower();
                        com.Parameters.Add("p_status", NpgsqlDbType.Text).Value = callDataRecord.YStatus;
                        com.Parameters.Add("p_reason", NpgsqlDbType.Text).Value = callDataRecord.YReason;
                        com.Parameters.Add("p_error", NpgsqlDbType.Text).Value = callDataRecord.YError;
                        com.Parameters.Add("p_dialcodemasterid", NpgsqlDbType.Integer).Value = CoalesceDbNull(callDataRecord.CLDialcodeMasterId);
                        com.Parameters.Add("p_causeq931", NpgsqlDbType.Text).Value = CoalesceDbNull(callDataRecord.YCauseQ931);
                        com.Parameters.Add("p_causesip", NpgsqlDbType.Text).Value = CoalesceDbNull(callDataRecord.YCauseSIP);
                        com.Parameters.Add("p_gatewayid", NpgsqlDbType.Integer).Value = CoalesceDbNull(callDataRecord.CLGatewayId);
                        com.Parameters.Add("p_gatewayaccountid", NpgsqlDbType.Integer).Value = CoalesceDbNull(callDataRecord.CLGatewayAccountId);
                        com.Parameters.Add("p_gatewayipid", NpgsqlDbType.Integer).Value = CoalesceDbNull(callDataRecord.CLGatewayIPId);
                        com.Parameters.Add("p_format", NpgsqlDbType.Text).Value = CoalesceDbNull(callDataRecord.YFormat);
                        com.Parameters.Add("p_formats", NpgsqlDbType.Text).Value = CoalesceDbNull(callDataRecord.YFormats);
                        com.Parameters.Add("p_customerid", NpgsqlDbType.Integer).Value = CoalesceDbNull(callDataRecord.CLCustomerId);
                        com.Parameters.Add("p_customeripid", NpgsqlDbType.Integer).Value = CoalesceDbNull(callDataRecord.CLCustomerIPId);
                        com.Parameters.Add("p_rtpaddress", NpgsqlDbType.Inet).Value = CoalesceDbNull(callDataRecord.YRTPAddress);

                        if (callDataRecord.YRTPAddress == null)
                        {
                            com.Parameters.Add("p_rtpport", NpgsqlDbType.Integer).Value = DBNull.Value;
                        }
                        else
                        {
                            com.Parameters.Add("p_rtpport", NpgsqlDbType.Integer).Value = CoalesceDbNull(callDataRecord.YRTPAddress.Port);
                        }
                        com.Parameters.Add("p_trackingid", NpgsqlDbType.Text).Value = CoalesceDbNull(callDataRecord.CLTrackingId);
                        com.Parameters.Add("p_ended", NpgsqlDbType.Boolean).Value = callDataRecord.YEnded;
                        com.Parameters.Add("p_techcalled", NpgsqlDbType.Text).Value = CoalesceDbNull(callDataRecord.CLTechCalled);

                        com.Parameters.Add("p_gatewayrateid", NpgsqlDbType.Bigint).Value = CoalesceDbNull(callDataRecord.CLGatewayRateId);
                        com.Parameters.Add("p_gatewayratepermin", NpgsqlDbType.Numeric).Value = CoalesceDbNull(callDataRecord.CLGatewayRatePerMin);
                        com.Parameters.Add("p_gatewayratetotal", NpgsqlDbType.Numeric).Value = CoalesceDbNull(callDataRecord.CLGatewayRateTotal);
                        com.Parameters.Add("p_gatewaycurrency", NpgsqlDbType.Char, 3).Value = CoalesceDbNull(callDataRecord.CLGatewayCurrency);

                        com.Parameters.Add("p_customerrateid", NpgsqlDbType.Bigint).Value = CoalesceDbNull(callDataRecord.CLCustomerRateId);
                        com.Parameters.Add("p_customerratepermin", NpgsqlDbType.Numeric).Value = CoalesceDbNull(callDataRecord.CLCustomerRatePerMin);
                        com.Parameters.Add("p_customerratetotal", NpgsqlDbType.Numeric).Value = CoalesceDbNull(callDataRecord.CLCustomerRateTotal);
                        com.Parameters.Add("p_customercurrency", NpgsqlDbType.Char, 3).Value = CoalesceDbNull(callDataRecord.CLCustomerCurrency);


                        com.Parameters.Add("p_routingwaitingtime", NpgsqlDbType.Integer).Value = callDataRecord.CLWaitingTime;
                        com.Parameters.Add("p_routingprocessingtime", NpgsqlDbType.Integer).Value = callDataRecord.CLProcessingTime;
                        com.Parameters.Add("p_sipuseragent", NpgsqlDbType.Text).Value = CoalesceDbNull(callDataRecord.YSIPUserAgent);
                        com.Parameters.Add("p_sipxasteriskhangupcause", NpgsqlDbType.Text).Value = CoalesceDbNull(callDataRecord.YSIPXAsteriskHangupCause);
                        com.Parameters.Add("p_sipxasteriskhangupcausecode", NpgsqlDbType.Text).Value = CoalesceDbNull(callDataRecord.YSIPXAsteriskHangupCode);

                        com.Parameters.Add("p_rtpforward", NpgsqlDbType.Boolean).Value = callDataRecord.YRTPForward;

                        com.Parameters.Add("p_routingtree", NpgsqlDbType.Jsonb).Value = CoalesceDbNull(callDataRecord.RoutingTree);

                        await con.OpenAsync();
                        
                        int i = await com.ExecuteNonQueryAsync();

                        success = true;
                    }
                    catch (Exception ex)
                    {
                        this._logger.Error(ex, ex.Message);
#if DEBUG
                        throw;
#endif
                    }
                    finally
                    {
                        con.Close();
                    }
                }
            }

            return success;
        }

        async Task<CustomerRate> IDatabase.GetRateForCustomer(int id, string[] splittedNumber, DateTime callDateTime, CancellationToken cancellationToken)
        {
            var customerRate = new CustomerRate();

            using (var con = new NpgsqlConnection(this._connectionString))
            {
                using (var com = new NpgsqlCommand("controller_get_rate_for_customer", con))
                {
                    com.CommandType = CommandType.StoredProcedure;

                    com.Parameters.Add("p_number", NpgsqlDbType.Text | NpgsqlDbType.Array).Value = splittedNumber;
                    com.Parameters.Add("p_customer_id", NpgsqlDbType.Integer).Value = id;
                    com.Parameters.Add("p_timestamp", NpgsqlDbType.TimestampTz).Value = callDateTime;

                    try
                    {
                        await con.OpenAsync(cancellationToken);

                        using (var reader = await com.ExecuteReaderAsync(CommandBehavior.SingleResult, cancellationToken))
                        {
                            if (reader.HasRows)
                            {
                                await reader.ReadAsync(cancellationToken);
                                customerRate.Set(reader.GetInt64(0), reader.GetDecimal(1), reader.GetString(2), reader.GetDecimal(3));
                            }
                        }
                    }
                    catch (Exception ex)
                    {
                        if (!cancellationToken.IsCancellationRequested)
                        {
                            this._logger.Error(ex, ex.Message);
                        }
#if DEBUG && THROW
                        throw;
#endif
                    }
                    finally
                    {
                        con.Close();
                    }
                }
            }

            return customerRate;
        }

        async Task<List<GatewayRate>> IDatabase.GetRatesForGateways(int[] ids, string[] splittedNumber, DateTime callDateTime, CancellationToken cancellationToken)
        {
            var result = new List<GatewayRate>();

            using (var con = new NpgsqlConnection(this._connectionString))
            {
                using (var com = new NpgsqlCommand("controller_get_rates_for_gateways", con))
                {
                    com.CommandType = CommandType.StoredProcedure;

                    com.Parameters.Add("p_number", NpgsqlDbType.Text | NpgsqlDbType.Array).Value = splittedNumber;
                    com.Parameters.Add("p_gateway_ids", NpgsqlDbType.Integer | NpgsqlDbType.Array).Value = ids;
                    com.Parameters.Add("p_timestamp", NpgsqlDbType.TimestampTz).Value = callDateTime;

                    try
                    {
                        await con.OpenAsync(cancellationToken);

                        using (var reader = com.ExecuteReader(CommandBehavior.SingleResult))
                        {
                            while (await reader.ReadAsync(cancellationToken))
                            {
                                result.Add(new GatewayRate(reader.GetInt32(5), reader.GetInt64(0), reader.GetDecimal(1), reader.GetString(2), reader.GetDecimal(3), reader.GetString(4)));
                            }
                        }
                    }
                    catch (Exception ex)
                    {
                        if (!cancellationToken.IsCancellationRequested)
                        {
                            this._logger.Error(ex, ex.Message);
                        }

#if DEBUG
                        throw;
#endif
                    }
                    finally
                    {
                        con.Close();
                    }
                }
            }

            return result;
        }

        async Task<Dictionary<int, decimal>> IDatabase.GetNumberGatewayStatistics(string[] splittedNumber, int[] gatewayIds, CancellationToken cancellationToken)
        {
            var result = new Dictionary<int, decimal>();

            using (var con = new NpgsqlConnection(this._connectionString))
            {
                using (var com = new NpgsqlCommand("controller_get_number_gateway_statistic", con))
                {
                    com.CommandType = CommandType.StoredProcedure;

                    com.Parameters.Add("p_number", NpgsqlDbType.Text | NpgsqlDbType.Array).Value = splittedNumber;
                    com.Parameters.Add("p_gateway_ids", NpgsqlDbType.Integer | NpgsqlDbType.Array).Value = gatewayIds;

                    try
                    {
                        await con.OpenAsync(cancellationToken);

                        using (var reader = await com.ExecuteReaderAsync(CommandBehavior.SingleResult, cancellationToken))
                        {
                            while (await reader.ReadAsync())
                            {
                                result.Add(reader.GetInt32(0), reader.GetDecimal(1));
                            }
                        }
                    }
                    catch (Exception ex)
                    {
                        if (!cancellationToken.IsCancellationRequested)
                        {
                            this._logger.Error(ex, ex.Message);
                        }
#if DEBUG
                        throw;
#endif
                    }
                    finally
                    {
                        con.Close();
                    }
                }
            }

            return result;
        }

        async Task<List<IvrRecord>> IDatabase.GetIVRRecords(string caller, CancellationToken cancellationToken)
        {
            var records = new List<IvrRecord>();

            using (var con = new NpgsqlConnection(this._connectionString))
            {
                using (var com = new NpgsqlCommand("SELECT id, created FROM ivr_record WHERE caller = @caller", con))
                {
                    com.CommandType = CommandType.Text;

                    com.Parameters.Add("@caller", NpgsqlDbType.Text).Value = caller;

                    try
                    {
                        await con.OpenAsync(cancellationToken);

                        using (var reader = await com.ExecuteReaderAsync(CommandBehavior.SingleResult, cancellationToken))
                        {
                            while (await reader.ReadAsync(cancellationToken))
                            {
                                records.Add(new IvrRecord(reader.GetInt32(0), reader.GetDateTime(1)));
                            }
                        }
                    }
                    catch (Exception ex)
                    {
                        if (!cancellationToken.IsCancellationRequested)
                        {
                            this._logger.Error(ex, ex.Message);
                        }
#if DEBUG
                        throw;
#endif
                    }
                    finally
                    {
                        con.Close();
                    }
                }
            }

            return records;
        }

        #endregion Call Data Records

        #region Statistics

        /// <summary>
        /// Adds RTP statistic information
        /// </summary>
        /// <param name="rtpStats"></param>
        /// <returns></returns>
        async Task IDatabase.AddRtpStats(RtpStats rtpStats)
        {
            using (var con = new NpgsqlConnection(this._connectionString))
            {
                using (var com = new NpgsqlCommand("controller_add_rtp_stats", con))
                {
                    try
                    {
                        com.CommandType = CommandType.StoredProcedure;

                        com.Parameters.Add("p_billid", NpgsqlDbType.Text).Value = rtpStats.BillId;
                        com.Parameters.Add("p_chan", NpgsqlDbType.Text).Value = rtpStats.Chan;
                        com.Parameters.Add("p_node_id", NpgsqlDbType.Integer).Value = rtpStats.Node.Id;
                        com.Parameters.Add("p_packets_sent", NpgsqlDbType.Bigint).Value = rtpStats.PacketsSent;
                        com.Parameters.Add("p_octets_sent", NpgsqlDbType.Bigint).Value = rtpStats.OctetsSent;
                        com.Parameters.Add("p_packets_received", NpgsqlDbType.Bigint).Value = rtpStats.PacketsReceived;
                        com.Parameters.Add("p_octets_received", NpgsqlDbType.Bigint).Value = rtpStats.OctetsReceived;
                        com.Parameters.Add("p_packet_loss", NpgsqlDbType.Bigint).Value = rtpStats.PacketLoss;

                        if (rtpStats.RemoteIp == null)
                        {
                            com.Parameters.Add("p_rtp_address", NpgsqlDbType.Inet).Value = DBNull.Value;
                        }
                        else
                        {
                            com.Parameters.Add("p_rtp_address", NpgsqlDbType.Inet).Value = rtpStats.RemoteIp;
                        }

                        if (rtpStats.RemotePort.HasValue)
                        {
                            com.Parameters.Add("p_rtp_port", NpgsqlDbType.Integer).Value = rtpStats.RemotePort;
                        }
                        else
                        {
                            com.Parameters.Add("p_rtp_port", NpgsqlDbType.Integer).Value = DBNull.Value;
                        }

                        await con.OpenAsync();

                        await com.ExecuteNonQueryAsync();
                    }
                    catch (Exception ex)
                    {
                        this._logger.Error(ex, ex.Message);
#if DEBUG
                        throw;
#endif
                    }
                    finally
                    {
                        con.Close();
                    }
                }
            }
        }

        /// <summary>
        /// Updates Number Gateway Statistics Cache
        /// </summary>
        /// <returns></returns>
        async Task IDatabase.NumberGatewayStatisticsUpdate(CancellationToken cancellationToken)
        {
            using (var con = new NpgsqlConnection(this._connectionString))
            {
                using (var com = new NpgsqlCommand("REFRESH MATERIALIZED VIEW CONCURRENTLY domain.cache_number_gateway_statistics;", con))
                {
                    try
                    {
                        await con.OpenAsync(cancellationToken);

                        await com.ExecuteNonQueryAsync(cancellationToken);
                    }
                    catch (Exception ex)
                    {
                        this._logger.Error(ex, ex.Message);
#if DEBUG
                        throw;
#endif
                    }
                    finally
                    {
                        con.Close();
                    }
                }
            }
        }

        #endregion Statistics

        #region Helpers

        /// <summary>
        /// Returns the provided integer value or <seealso cref="DBNull"/>
        /// </summary>
        /// <param name="value">Integer to check for null</param>
        /// <returns>Integer value or DBNull</returns>
        private static object CoalesceDbNull(int? value)
        {
            if (value.HasValue)
            {
                return value.Value;
            }
            else
            {
                return DBNull.Value;
            }
        }

        /// <summary>
        /// Returns the provided long value or <seealso cref="DBNull"/>
        /// </summary>
        /// <param name="value">Long to check for null</param>
        /// <returns>Long value or DBNull</returns>
        private static object CoalesceDbNull(long? value)
        {
            if (value.HasValue)
            {
                return value.Value;
            }
            else
            {
                return DBNull.Value;
            }
        }

        /// <summary>
        /// Returns the provided decimal value or <seealso cref="DBNull"/>
        /// </summary>
        /// <param name="value">Decimal to check for null</param>
        /// <returns>Decimal value or DBNull</returns>
        private static object CoalesceDbNull(decimal? value)
        {
            if (value.HasValue)
            {
                return value.Value;
            }
            else
            {
                return DBNull.Value;
            }
        }

        /// <summary>
        /// Returns the provided string value or <seealso cref="DBNull"/>
        /// </summary>
        /// <param name="value">String to check for null</param>
        /// <returns>String value or DBNull</returns>
        private static object CoalesceDbNull(string value)
        {
            if (!string.IsNullOrEmpty(value))
            {
                return value;
            }
            else
            {
                return DBNull.Value;
            }
        }

        /// <summary>
        /// Returns the provided IPEndpoint value or <seealso cref="DBNull"/>
        /// </summary>
        /// <param name="value">IPEndpoint to check for null</param>
        /// <returns>IPEndpoint value or DBNull</returns>
        private static object CoalesceDbNull(IPEndPoint value)
        {
            if (value != null)
            {
                return value.Address;
            }
            else
            {
                return DBNull.Value;
            }
        }

        #endregion Helpers
    }
}