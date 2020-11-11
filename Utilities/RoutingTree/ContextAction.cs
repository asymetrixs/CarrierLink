namespace CarrierLink.Controller.Utilities.RoutingTree
{
    using System;

    /// <summary>
    /// This class indicates the action performed for contexts
    /// </summary>
    [Flags]
    public enum ContextAction
    {
        /// <summary>
        /// Default value
        /// </summary>
        None = 0,

        /// <summary>
        /// Fixed Routing
        /// </summary>
        Fixed = 1,

        /// <summary>
        /// Least Cost Routing
        /// </summary>
        LCR = 2,

        /// <summary>
        /// Routed internally
        /// </summary>
        Internal = 4,

        /// <summary>
        /// Routing is forbidden
        /// </summary>
        Cancelled = 8
    }
}
