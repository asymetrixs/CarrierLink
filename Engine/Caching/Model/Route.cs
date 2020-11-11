namespace CarrierLink.Controller.Engine.Caching.Model
{
    using System.Collections.Generic;
    using System.Text.RegularExpressions;

    /// <summary>
    /// This class holds route information
    /// </summary>
    public class Route
    {
        #region Constructor

        /// <summary>
        /// Initializes a new instance of the <see cref="Route"/> class
        /// </summary>
        /// <param name="timeout">See <see cref="Timeout"/></param>
        /// <param name="action">See <see cref="Action"/></param>
        /// <param name="isDid">See <see cref="IsDid"/></param>
        /// <param name="routeId">See <see cref="Id"/></param>
        /// <param name="newCaller">See <see cref="NewCaller"/></param>
        /// <param name="newCallername">See <see cref="NewCallername"/></param>
        /// <param name="ignoreMissingRate">See <see cref="IgnoreMissingRate"/></param>
        /// <param name="fallbackTolcr">See <see cref="FallbackToLCR"/></param>
        /// <param name="contextId">See <see cref="ContextId"/> </param>
        /// <param name="pattern">See <see cref="Pattern"/> </param>
        /// <param name="sort">See <see cref="Sort"/></param>
        /// <param name="blendPercentage">See <see cref="BlendPercentage"/></param>
        /// <param name="blendToContextId">See <see cref="BlendToContextId"/></param>
        internal Route(int id, int contextId, string pattern, string action, int sort, bool isDid, string newCaller, string newCallername,
            bool ignoreMissingRate, bool fallbackTolcr, int timeout, int? blendPercentage, int? blendToContextId)
        {
            this.Timeout = timeout;
            this.Action = action;
            this.BlendPercentage = blendPercentage;
            this.BlendToContextId = blendToContextId;
            this.IsDid = isDid;
            this.Id = id;
            this.NewCaller = newCaller;
            this.NewCallername = newCallername;
            this.IgnoreMissingRate = ignoreMissingRate;
            this.FallbackToLCR = fallbackTolcr;
            this.ContextId = contextId;
            this.Sort = sort;
            this.Pattern = pattern;
            this.RexexMatch = new Regex(pattern);
            this.Targets = new List<RouteTarget>();
        }

        #endregion Constructor

        #region Properties

        /// <summary>
        /// Gets default action on routing the call
        /// </summary>
        internal string Action { get; }

        /// <summary>
        /// Gets a value indicating the probability of call blending
        /// </summary>
        internal int? BlendPercentage { get; }

        /// <summary>
        /// Gets a value indicating to which context the call should get blended
        /// </summary>
        internal int? BlendToContextId { get; }

        /// <summary>
        /// Gets context Id
        /// </summary>
        internal int ContextId { get; }

        /// <summary>
        /// Gets a value indicating whether LCR is used as fallback in case fixed routing fails
        /// </summary>
        internal bool FallbackToLCR { get; }

        /// <summary>
        /// Gets default route Id to use
        /// </summary>
        internal int Id { get; }

        /// <summary>
        /// Gets a value indicating whether the customer needs a rate which is checked against the gateway rate(s) against loss or not
        /// </summary>
        internal bool IgnoreMissingRate { get; }

        /// <summary>
        /// Gets a value indicating whether the call is Did or Wholesale
        /// </summary>
        internal bool IsDid { get; }

        /// <summary>
        /// Gets new caller
        /// </summary>
        internal string NewCaller { get; }

        /// <summary>
        /// Gets new caller name
        /// </summary>
        internal string NewCallername { get; }

        /// <summary>
        /// Gets regular expression pattern to match on called number
        /// </summary>
        internal string Pattern { get; }

        /// <summary>
        /// Gets the regular expression instance to match with
        /// </summary>
        internal Regex RexexMatch { get; }

        /// <summary>
        /// Gets sort order value (higher is better)
        /// </summary>
        internal int Sort { get; }

        /// <summary>
        /// Gets targets to use in order
        /// </summary>
        internal List<RouteTarget> Targets { get; private set; }

        /// <summary>
        /// Gets time the call can last
        /// </summary>
        internal int Timeout { get; }

        #endregion Properties

        #region Methods

        /// <summary>
        /// Adds possible route targets
        /// </summary>
        /// <param name="routeTargets">Targets to route to</param>
        internal void AddTargets(List<RouteTarget> routeTargets)
        {
            this.Targets = routeTargets;
        }

        #endregion
    }
}