namespace CarrierLink.Controller.Engine.Database
{
    using Caching.Model;
    using Model;
    using System;
    using System.Collections.Concurrent;
    using System.Collections.Generic;
    using System.Text.RegularExpressions;
    using System.Threading;
    using System.Threading.Tasks;
    using Workers.Model;
    using Yate;

    /// <summary>
    /// This interface provides database connectivity
    /// </summary>
    public interface IDatabase
    {
        #region Routing

        /// <summary>
        /// Updates the Node information
        /// </summary>
        Task<ConcurrentDictionary<string, Caching.Model.Node>> GetNodeCache(CancellationToken cancellationToken);

        /// <summary>
        /// Updates the Incorrect Callername information
        /// </summary>
        Task<ConcurrentDictionary<string, string>> GetIncorrectCallernameCache(CancellationToken cancellationToken);

        /// <summary>
        /// Updates the Customer information
        /// </summary>
        /// <returns>Key: IP#Prefix</returns>
        Task<ConcurrentDictionary<string, Customer>> GetCustomerCache(CancellationToken cancellationToken);

        /// <summary>
        /// Updates the Customer information
        /// </summary>
        /// <returns>Key: IP#Prefix</returns>
        Task<ConcurrentDictionary<string, Regex>> GetBlacklistCache(CancellationToken cancellationToken);

        /// <summary>
        /// Updates the information about which gateway are in which route
        /// </summary>
        /// <returns>Key: Route ID</returns>
        Task<ConcurrentDictionary<int, TargetsForRoute>> GetTargetsForRouteCache(CancellationToken cancellationToken);

        /// <summary>
        /// Updates the Context information
        /// </summary>
        /// <returns>Key: ID</returns>
        Task<ConcurrentDictionary<int, Context>> GetContextCache(CancellationToken cancellationToken);

        /// <summary>
        /// Updates information about which gateway can be reached by which node
        /// </summary>
        /// <returns>Key: Node ID, List of Gateway IDs</returns>
        Task<ConcurrentDictionary<int, List<int>>> GetGatewaysAccessibleByNodeCache(CancellationToken cancellationToken);

        /// <summary>
        /// Updates information about which node can be reached by which gateway
        /// </summary>
        /// <returns>Key: Gateway ID, List of Node IDs</returns>
        Task<ConcurrentDictionary<int, List<int>>> GetNodesAccessibleByGatewayCache(CancellationToken cancellationToken);

        /// <summary>
        /// Updates the Gateway information
        /// </summary>
        /// <returns>Key: ID</returns>
        Task<ConcurrentDictionary<int, Gateway>> GetGatewayCache(CancellationToken cancellationToken);

        /// <summary>
        /// Updates the Gateway Account information
        /// </summary>
        /// <returns>Gateway ID</returns>
        Task<ConcurrentDictionary<int, List<GatewayAccount>>> GetGatewayAccountCache(CancellationToken cancellationToken);

        /// <summary>
        /// Updates the Gateway IP information
        /// </summary>
        /// <returns>Gateway ID</returns>
        Task<ConcurrentDictionary<int, List<GatewayIP>>> GetGatewayIPCache(CancellationToken cancellationToken);

        /// <summary>
        /// Updates the information about the gateway billtime limits
        /// </summary>
        /// <returns>Key: Gateway ID, Value: Billtime Limit Exceeded</returns>
        Task<ConcurrentDictionary<int, bool>> GetGatewayLimitExceededCache(CancellationToken cancellationToken);

        /// <summary>
        /// Updates the information about which node has which internal IP
        /// </summary>
        /// <returns>Key: Node ID</returns>
        Task<ConcurrentDictionary<int, NodeIP>> GetInternalNodeIPCache(CancellationToken cancellationToken);

        /// <summary>
        /// Updates Number Modification Policies
        /// </summary>
        /// <returns>Key: Number Modification Group ID</returns>
        Task<ConcurrentDictionary<int, List<NumberModificationPolicy>>> GetNumberModificationPoliciesCache(CancellationToken cancellationToken);

        /// <summary>
        /// Returns context - gateway relation
        /// </summary>
        /// <returns></returns>
        Task<ConcurrentBag<ContextGateway>> GetContextGatewayCache(CancellationToken cancellationToken);

        /// <summary>
        /// Returns Customer rates
        /// </summary>
        /// <param name="id"></param>
        /// <param name="splittedNumber"></param>
        /// <param name="callDateTime"></param>
        /// <param name="cancellationToken"></param>
        /// <returns></returns>
        Task<CustomerRate> GetRateForCustomer(int id, string[] splittedNumber, DateTime callDateTime, CancellationToken cancellationToken);

        /// <summary>
        /// Returns routes to cache
        /// </summary>
        /// <param name="cancellationToken"></param>
        /// <returns></returns>
        Task<List<Caching.Model.Route>> GetRouteCache(CancellationToken cancellationToken);

        /// <summary>
        /// Returnsgateway rates
        /// </summary>
        /// <param name="gatewayIds"></param>
        /// <param name="splittedNumber"></param>
        /// <param name="callDateTime"></param>
        /// <param name="cancellationToken"></param>
        /// <returns></returns>
        Task<List<GatewayRate>> GetRatesForGateways(int[] ids, string[] splittedNumber, DateTime callDateTime, CancellationToken cancellationToken);

        /// <summary>
        /// Updates dialcode master information
        /// </summary>
        /// <param name="cancellationToken"></param>
        /// <returns></returns>
        Task<ConcurrentDictionary<string, DialcodeMaster>> GetDialcodeMasterCache(CancellationToken cancellationToken);

        /// <summary>
        /// Returnsnumber gateway statistics
        /// </summary>
        /// <param name="splittedNumber"></param>
        /// <param name="gatewayIds"></param>
        /// <param name="cancellationToken"></param>
        /// <returns></returns>
        Task<Dictionary<int, decimal>> GetNumberGatewayStatistics(string[] splittedNumber, int[] gatewayIds, CancellationToken cancellationToken);

        #endregion Routing

        #region Call Data Records

        /// <summary>
        /// Writes a CallDataRecord into the database
        /// </summary>
        /// <param name="callDataRecord"></param>
        /// <returns></returns>
        Task<bool> WriteCDR(CallDataRecord callDataRecord);

        #endregion Call Data Records

        #region Statistics

        /// <summary>
        /// Adds RTP statistic information
        /// </summary>
        /// <param name="rtpStats"></param>
        /// <returns></returns>
        Task AddRtpStats(RtpStats rtpStats);

        /// <summary>
        /// Updates Number Gateway Statistics Cache
        /// </summary>
        /// <returns></returns>
        Task NumberGatewayStatisticsUpdate(CancellationToken cancellationToken);

        #endregion Statistics

        #region Controller

        /// <summary>
        /// Returns information for a node
        /// </summary>
        /// <param name="id"></param>
        /// <returns></returns>
        Task<int> GetNodeInfo(int id, CancellationToken cancellationToken);

        /// <summary>
        /// Updates customer and gateway limits
        /// </summary>
        /// <param name="cancellationToken"></param>
        /// <returns></returns>
        Task EndpointCreditUpdate(CancellationToken cancellationToken);

        /// <summary>
        /// Returnsnode enpoint information
        /// </summary>
        /// <param name="nodeId"></param>
        /// <param name="cancellationToken"></param>
        /// <returns></returns>
        Task<NodeInfo> GetNodeConnectionInfo(int nodeId, CancellationToken cancellationToken);

        /// <summary>
        /// Announce Startup and do cleanup work
        /// </summary>
        /// <param name="name"></param>
        /// <param name="cancellationToken"></param>
        /// <returns></returns>
        Task<int> ControllerStartup(string name, CancellationToken cancellationToken);

        /// <summary>
        /// Announce Shutdown and do cleanup work
        /// </summary>
        /// <param name="id"></param>
        /// <param name="cancellationToken"></param>
        /// <returns></returns>
        Task ControllerShutdown(int id, CancellationToken cancellationToken);

        /// <summary>
        /// Announce sign of living
        /// </summary>
        /// <param name="id"></param>
        /// <param name="cancellationToken"></param>
        /// <returns></returns>
        Task ControllerIsAlive(int id, CancellationToken cancellationToken);

        /// <summary>
        /// Write into Log
        /// </summary>
        /// <param name="id"></param>
        /// <param name="action"></param>
        /// <param name="cancellationToken"></param>
        /// <returns></returns>
        Task ControllerLog(int id, string action, CancellationToken cancellationToken);

        /// <summary>
        /// Retrieve manageable connections
        /// </summary>
        /// <param name="id"></param>
        /// <param name="cancellationToken"></param>
        /// <returns></returns>
        Task<IEnumerable<ControllerConnection>> ControllerConnectons(int id, CancellationToken cancellationToken);

        /// <summary>
        /// Update status of a managable connection
        /// </summary>
        /// <param name="controlServerid"></param>
        /// <param name="nodeId"></param>
        /// <param name="status"></param>
        /// <param name="cancellationToken"></param>
        /// <returns></returns>
        Task ControllerConnectionStatusUpdate(int controlServerid, int nodeId, ControlState status, CancellationToken cancellationToken);

        /// <summary>
        /// Updates last contact for node
        /// </summary>
        /// <param name="node"></param>
        /// <param name="lastEngineTimer"></param>
        /// <param name="cancellationToken"></param>
        /// <returns>Task to wait for</returns>
        Task NodeKeepAlive(INode node, DateTime lastEngineTimer, CancellationToken cancellationToken);

        #endregion Controller

        #region IVR

        /// <summary>
        /// Returns IVR records
        /// </summary>
        /// <param name="caller"></param>
        /// <param name="cancellationToken"></param>
        /// <returns></returns>
        Task<List<IvrRecord>> GetIVRRecords(string caller, CancellationToken cancellationToken);
        
        #endregion IVR        
    }
}