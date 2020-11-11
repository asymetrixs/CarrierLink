namespace CarrierLink.Controller.Engine.Caching.Routing
{
    using System;

    /// <summary>
    /// This enumeration holds information about the routing action
    /// </summary>
    [Flags]
    internal enum Action
    {
        /// <summary>
        /// Nothing specified
        /// </summary>
        None = 1,

        /// <summary>
        /// Routing is forbidden and call will be blocked
        /// </summary>
        Forbidden = 2,

        /// <summary>
        /// Fixed route routing
        /// </summary>
        FixedRouteRouting = 4,

        /// <summary>
        /// Least Cost Routing (LCR)
        /// </summary>
        LeastCostRouting = 8,

        /// <summary>
        /// Internal Routing
        /// </summary>
        InternalRouting = 16,

        /// <summary>
        /// Actually cancelling the call sending an error message
        /// </summary>
        Error = 32,

        /// <summary>
        /// Context has been skipped because was already targeted
        /// </summary>
        ContextSkipped = 64
    }
}
