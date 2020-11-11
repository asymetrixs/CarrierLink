namespace CarrierLink.Controller.Engine.Caching.Model
{
    using System.Collections.Generic;

    /// <summary>
    /// This class provides the targets for a route
    /// </summary>
    public class TargetsForRoute
    {
        #region Constructor

        /// <summary>
        /// Initializes a new instance of the <see cref="TargetsForRoute"/> class
        /// </summary>
        /// <param name="routeId">See <see cref="RouteId"/></param>
        /// <param name="targets">See <see cref="Targets"/></param>
        internal TargetsForRoute(int routeId, List<RouteTarget> targets)
        {
            this.RouteId = routeId;
            this.Targets = targets;
        }

        #endregion Constructor

        #region Properties

        /// <summary>
        /// Gets the target referred by the route
        /// </summary>
        internal List<RouteTarget> Targets { get; }

        /// <summary>
        /// Gets the route Id
        /// </summary>
        internal int RouteId { get; }

        #endregion Properties
    }
}