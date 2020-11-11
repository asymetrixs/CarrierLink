namespace CarrierLink.Controller.Engine.Caching.Model
{
    /// <summary>
    /// This class holds the actual target (Gateway/Context) of a route
    /// </summary>
    internal class RouteTarget
    {
        #region Constructor

        /// <summary>
        /// Initializes a new instance of the <see cref="RouteTarget"/> class
        /// </summary>
        /// <param name="gatewayId">See <see cref="GatewayId"/></param>
        /// <param name="contextId">See <see cref="ContextId"/></param>
        internal RouteTarget(int? gatewayId, int? contextId)
        {
            this.GatewayId = gatewayId;
            this.ContextId = contextId;
        }

        #endregion

        #region Properties
        
        /// <summary>
        /// Gets Gateway Id or null if routing to Context
        /// </summary>
        internal int? GatewayId { get; }

        /// <summary>
        /// Gets Context Id or null if routing to Gateway
        /// </summary>
        internal int? ContextId { get; }

        #endregion
    }
}
