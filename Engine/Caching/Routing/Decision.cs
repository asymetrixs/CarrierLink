namespace CarrierLink.Controller.Engine.Caching.Routing
{
    using Model;
    using System.Linq;

    /// <summary>
    /// This class provides the Routing Decision Table
    /// </summary>
    internal class Decision
    {
        #region Fields

        /// <summary>
        /// Holds the basic rules that limit and decide about routing
        /// </summary>
        private static Decision[] decisionTable = new Decision[]
        {
            new Decision(hasRate: true, hasRoute: true, ignoreMissingRate: true, fallbackToLCR: true, hasLCR: true, enableLCRWithoutRate: true, useRoute: true, useLCR: true),
            new Decision(hasRate: true, hasRoute: true, ignoreMissingRate: true, fallbackToLCR: true, hasLCR: true, enableLCRWithoutRate: false, useRoute: true, useLCR: true),
            new Decision(hasRate: true, hasRoute: true, ignoreMissingRate: true, fallbackToLCR: true, hasLCR: false, enableLCRWithoutRate: true, useRoute: true, useLCR: false),
            new Decision(hasRate: true, hasRoute: true, ignoreMissingRate: true, fallbackToLCR: true, hasLCR: false, enableLCRWithoutRate: false, useRoute: true, useLCR: false),
            new Decision(hasRate: true, hasRoute: true, ignoreMissingRate: true, fallbackToLCR: false, hasLCR: true, enableLCRWithoutRate: true, useRoute: true, useLCR: false),
            new Decision(hasRate: true, hasRoute: true, ignoreMissingRate: true, fallbackToLCR: false, hasLCR: true, enableLCRWithoutRate: false, useRoute: true, useLCR: false),
            new Decision(hasRate: true, hasRoute: true, ignoreMissingRate: true, fallbackToLCR: false, hasLCR: false, enableLCRWithoutRate: true, useRoute: true, useLCR: false),
            new Decision(hasRate: true, hasRoute: true, ignoreMissingRate: true, fallbackToLCR: false, hasLCR: false, enableLCRWithoutRate: false, useRoute: true, useLCR: false),
            new Decision(hasRate: true, hasRoute: true, ignoreMissingRate: false, fallbackToLCR: true, hasLCR: true, enableLCRWithoutRate: true, useRoute: true, useLCR: true),
            new Decision(hasRate: true, hasRoute: true, ignoreMissingRate: false, fallbackToLCR: true, hasLCR: true, enableLCRWithoutRate: false, useRoute: true, useLCR: true),
            new Decision(hasRate: true, hasRoute: true, ignoreMissingRate: false, fallbackToLCR: true, hasLCR: false, enableLCRWithoutRate: true, useRoute: true, useLCR: false),
            new Decision(hasRate: true, hasRoute: true, ignoreMissingRate: false, fallbackToLCR: true, hasLCR: false, enableLCRWithoutRate: false, useRoute: true, useLCR: false),
            new Decision(hasRate: true, hasRoute: true, ignoreMissingRate: false, fallbackToLCR: false, hasLCR: true, enableLCRWithoutRate: true, useRoute: true, useLCR: false),
            new Decision(hasRate: true, hasRoute: true, ignoreMissingRate: false, fallbackToLCR: false, hasLCR: true, enableLCRWithoutRate: false, useRoute: true, useLCR: false),
            new Decision(hasRate: true, hasRoute: true, ignoreMissingRate: false, fallbackToLCR: false, hasLCR: false, enableLCRWithoutRate: true, useRoute: true, useLCR: false),
            new Decision(hasRate: true, hasRoute: true, ignoreMissingRate: false, fallbackToLCR: false, hasLCR: false, enableLCRWithoutRate: false, useRoute: true, useLCR: false),
            new Decision(hasRate: true, hasRoute: false, ignoreMissingRate: true, fallbackToLCR: true, hasLCR: true, enableLCRWithoutRate: true, useRoute: false, useLCR: true),
            new Decision(hasRate: true, hasRoute: false, ignoreMissingRate: true, fallbackToLCR: true, hasLCR: true, enableLCRWithoutRate: false, useRoute: false, useLCR: true),
            new Decision(hasRate: true, hasRoute: false, ignoreMissingRate: true, fallbackToLCR: true, hasLCR: false, enableLCRWithoutRate: true, useRoute: false, useLCR: false),
            new Decision(hasRate: true, hasRoute: false, ignoreMissingRate: true, fallbackToLCR: true, hasLCR: false, enableLCRWithoutRate: false, useRoute: false, useLCR: false),
            new Decision(hasRate: true, hasRoute: false, ignoreMissingRate: true, fallbackToLCR: false, hasLCR: true, enableLCRWithoutRate: true, useRoute: false, useLCR: true),
            new Decision(hasRate: true, hasRoute: false, ignoreMissingRate: true, fallbackToLCR: false, hasLCR: true, enableLCRWithoutRate: false, useRoute: false, useLCR: true),
            new Decision(hasRate: true, hasRoute: false, ignoreMissingRate: true, fallbackToLCR: false, hasLCR: false, enableLCRWithoutRate: true, useRoute: false, useLCR: false),
            new Decision(hasRate: true, hasRoute: false, ignoreMissingRate: true, fallbackToLCR: false, hasLCR: false, enableLCRWithoutRate: false, useRoute: false, useLCR: false),
            new Decision(hasRate: true, hasRoute: false, ignoreMissingRate: false, fallbackToLCR: true, hasLCR: true, enableLCRWithoutRate: true, useRoute: false, useLCR: true),
            new Decision(hasRate: true, hasRoute: false, ignoreMissingRate: false, fallbackToLCR: true, hasLCR: true, enableLCRWithoutRate: false, useRoute: false, useLCR: true),
            new Decision(hasRate: true, hasRoute: false, ignoreMissingRate: false, fallbackToLCR: true, hasLCR: false, enableLCRWithoutRate: true, useRoute: false, useLCR: false),
            new Decision(hasRate: true, hasRoute: false, ignoreMissingRate: false, fallbackToLCR: true, hasLCR: false, enableLCRWithoutRate: false, useRoute: false, useLCR: false),
            new Decision(hasRate: true, hasRoute: false, ignoreMissingRate: false, fallbackToLCR: false, hasLCR: true, enableLCRWithoutRate: true, useRoute: false, useLCR: true),
            new Decision(hasRate: true, hasRoute: false, ignoreMissingRate: false, fallbackToLCR: false, hasLCR: true, enableLCRWithoutRate: false, useRoute: false, useLCR: true),
            new Decision(hasRate: true, hasRoute: false, ignoreMissingRate: false, fallbackToLCR: false, hasLCR: false, enableLCRWithoutRate: true, useRoute: false, useLCR: false),
            new Decision(hasRate: true, hasRoute: false, ignoreMissingRate: false, fallbackToLCR: false, hasLCR: false, enableLCRWithoutRate: false, useRoute: false, useLCR: false),
            new Decision(hasRate: false, hasRoute: true, ignoreMissingRate: true, fallbackToLCR: true, hasLCR: true, enableLCRWithoutRate: true, useRoute: true, useLCR: true),
            new Decision(hasRate: false, hasRoute: true, ignoreMissingRate: true, fallbackToLCR: true, hasLCR: true, enableLCRWithoutRate: false, useRoute: true, useLCR: false),
            new Decision(hasRate: false, hasRoute: true, ignoreMissingRate: true, fallbackToLCR: true, hasLCR: false, enableLCRWithoutRate: true, useRoute: true, useLCR: false),
            new Decision(hasRate: false, hasRoute: true, ignoreMissingRate: true, fallbackToLCR: true, hasLCR: false, enableLCRWithoutRate: false, useRoute: true, useLCR: false),
            new Decision(hasRate: false, hasRoute: true, ignoreMissingRate: true, fallbackToLCR: false, hasLCR: true, enableLCRWithoutRate: true, useRoute: true, useLCR: false),
            new Decision(hasRate: false, hasRoute: true, ignoreMissingRate: true, fallbackToLCR: false, hasLCR: true, enableLCRWithoutRate: false, useRoute: true, useLCR: false),
            new Decision(hasRate: false, hasRoute: true, ignoreMissingRate: true, fallbackToLCR: false, hasLCR: false, enableLCRWithoutRate: true, useRoute: true, useLCR: false),
            new Decision(hasRate: false, hasRoute: true, ignoreMissingRate: true, fallbackToLCR: false, hasLCR: false, enableLCRWithoutRate: false, useRoute: true, useLCR: false),
            new Decision(hasRate: false, hasRoute: true, ignoreMissingRate: false, fallbackToLCR: true, hasLCR: true, enableLCRWithoutRate: true, useRoute: false, useLCR: true),
            new Decision(hasRate: false, hasRoute: true, ignoreMissingRate: false, fallbackToLCR: true, hasLCR: true, enableLCRWithoutRate: false, useRoute: false, useLCR: false),
            new Decision(hasRate: false, hasRoute: true, ignoreMissingRate: false, fallbackToLCR: true, hasLCR: false, enableLCRWithoutRate: true, useRoute: false, useLCR: false),
            new Decision(hasRate: false, hasRoute: true, ignoreMissingRate: false, fallbackToLCR: true, hasLCR: false, enableLCRWithoutRate: false, useRoute: false, useLCR: false),
            new Decision(hasRate: false, hasRoute: true, ignoreMissingRate: false, fallbackToLCR: false, hasLCR: true, enableLCRWithoutRate: true, useRoute: false, useLCR: false),
            new Decision(hasRate: false, hasRoute: true, ignoreMissingRate: false, fallbackToLCR: false, hasLCR: true, enableLCRWithoutRate: false, useRoute: false, useLCR: false),
            new Decision(hasRate: false, hasRoute: true, ignoreMissingRate: false, fallbackToLCR: false, hasLCR: false, enableLCRWithoutRate: true, useRoute: false, useLCR: false),
            new Decision(hasRate: false, hasRoute: true, ignoreMissingRate: false, fallbackToLCR: false, hasLCR: false, enableLCRWithoutRate: false, useRoute: false, useLCR: false),
            new Decision(hasRate: false, hasRoute: false, ignoreMissingRate: true, fallbackToLCR: true, hasLCR: true, enableLCRWithoutRate: true, useRoute: false, useLCR: true),
            new Decision(hasRate: false, hasRoute: false, ignoreMissingRate: true, fallbackToLCR: true, hasLCR: true, enableLCRWithoutRate: false, useRoute: false, useLCR: false),
            new Decision(hasRate: false, hasRoute: false, ignoreMissingRate: true, fallbackToLCR: true, hasLCR: false, enableLCRWithoutRate: true, useRoute: false, useLCR: false),
            new Decision(hasRate: false, hasRoute: false, ignoreMissingRate: true, fallbackToLCR: true, hasLCR: false, enableLCRWithoutRate: false, useRoute: false, useLCR: false),
            new Decision(hasRate: false, hasRoute: false, ignoreMissingRate: true, fallbackToLCR: false, hasLCR: true, enableLCRWithoutRate: true, useRoute: false, useLCR: true),
            new Decision(hasRate: false, hasRoute: false, ignoreMissingRate: true, fallbackToLCR: false, hasLCR: true, enableLCRWithoutRate: false, useRoute: false, useLCR: false),
            new Decision(hasRate: false, hasRoute: false, ignoreMissingRate: true, fallbackToLCR: false, hasLCR: false, enableLCRWithoutRate: true, useRoute: false, useLCR: false),
            new Decision(hasRate: false, hasRoute: false, ignoreMissingRate: true, fallbackToLCR: false, hasLCR: false, enableLCRWithoutRate: false, useRoute: false, useLCR: false),
            new Decision(hasRate: false, hasRoute: false, ignoreMissingRate: false, fallbackToLCR: true, hasLCR: true, enableLCRWithoutRate: true, useRoute: false, useLCR: true),
            new Decision(hasRate: false, hasRoute: false, ignoreMissingRate: false, fallbackToLCR: true, hasLCR: true, enableLCRWithoutRate: false, useRoute: false, useLCR: false),
            new Decision(hasRate: false, hasRoute: false, ignoreMissingRate: false, fallbackToLCR: true, hasLCR: false, enableLCRWithoutRate: true, useRoute: false, useLCR: false),
            new Decision(hasRate: false, hasRoute: false, ignoreMissingRate: false, fallbackToLCR: true, hasLCR: false, enableLCRWithoutRate: false, useRoute: false, useLCR: false),
            new Decision(hasRate: false, hasRoute: false, ignoreMissingRate: false, fallbackToLCR: false, hasLCR: true, enableLCRWithoutRate: true, useRoute: false, useLCR: true),
            new Decision(hasRate: false, hasRoute: false, ignoreMissingRate: false, fallbackToLCR: false, hasLCR: true, enableLCRWithoutRate: false, useRoute: false, useLCR: false),
            new Decision(hasRate: false, hasRoute: false, ignoreMissingRate: false, fallbackToLCR: false, hasLCR: false, enableLCRWithoutRate: true, useRoute: false, useLCR: false),
            new Decision(hasRate: false, hasRoute: false, ignoreMissingRate: false, fallbackToLCR: false, hasLCR: false, enableLCRWithoutRate: false, useRoute: false, useLCR: false)
            };

        /// <summary>
        /// Indicates the decision what kind of routing is used
        /// </summary>
        private Action decision;

        /// <summary>
        /// Enables LCR even if customer does not have a rate
        /// </summary>
        private bool enableLCRWithoutRate;

        /// <summary>
        /// Indicates if route offers fallback to LCR
        /// </summary>
        private bool fallbackToLCR;

        /// <summary>
        /// Indicates if context offers LCR
        /// </summary>
        private bool hasLCR;

        /// <summary>
        /// Indicates whether has rate or not
        /// </summary>
        private bool hasRate;

        /// <summary>
        /// Indicates whether has route or not
        /// </summary>
        private bool hasRoute;

        /// <summary>
        /// Enables route-usage even if customer does not have a rate
        /// </summary>
        private bool ignoreMissingRate;

        /// <summary>
        /// Indicates whether LCR can be used or not
        /// </summary>
        private bool useLCR;

        /// <summary>
        /// Indicates whether fixed routing can be used or not
        /// </summary>
        private bool useRoute;

        #endregion Fields

        #region Constructor

        /// <summary>
        /// Initializes a new instance of the <see cref="Decision"/> class
        /// </summary>
        /// <param name="hasRate">See <see cref="hasRate"/></param>
        /// <param name="hasRoute">See <see cref="hasRoute"/></param>
        /// <param name="ignoreMissingRate">See <see cref="ignoreMissingRate"/></param>
        /// <param name="fallbackToLCR">See <see cref="fallbackToLCR"/></param>
        /// <param name="hasLCR">See <see cref="hasLCR"/></param>
        /// <param name="enableLCRWithoutRate">See <see cref="enableLCRWithoutRate"/></param>
        /// <param name="useRoute">See <see cref="useRoute"/></param>
        /// <param name="useLCR">See <see cref="useLCR"/></param>
        private Decision(bool hasRate, bool hasRoute, bool ignoreMissingRate, bool fallbackToLCR, bool hasLCR, bool enableLCRWithoutRate, bool useRoute, bool useLCR)
        {
            this.hasRate = hasRate;
            this.hasRoute = hasRoute;
            this.ignoreMissingRate = ignoreMissingRate;
            this.fallbackToLCR = fallbackToLCR;
            this.hasLCR = hasLCR;
            this.enableLCRWithoutRate = enableLCRWithoutRate;
            this.useRoute = useRoute;
            this.useLCR = useLCR;

            this.decision = Action.None;

            if (!this.useRoute && !this.useLCR)
            {
                this.decision = Action.Forbidden;
                return;
            }

            if (this.useRoute)
            {
                this.decision = Action.FixedRouteRouting;
            }

            if (this.useLCR)
            {
                if (this.decision == Action.None)
                {
                    this.decision = Action.LeastCostRouting;
                }
                else
                {
                    this.decision |= Action.LeastCostRouting;
                }
            }
        }

        #endregion Constructor

        #region Methods

        /// <summary>
        /// Evaluates the Routing Decision
        /// </summary>
        /// <param name="routingRulesResult">See <see cref="Result"/></param>
        /// <param name="context">See <see cref="Context"/></param>
        /// <returns>Returns decision for further routing</returns>
        internal static Action Decide(Result routingRulesResult, Context context)
        {
            var decision = (from a in decisionTable
                            where
                                a.hasRate == routingRulesResult.CustomerHasRate
                            && a.hasLCR == routingRulesResult.IsLCR
                            && a.enableLCRWithoutRate == context.EnableLCRWithoutRate
                            && a.hasRoute == routingRulesResult.HasRoute
                            && a.fallbackToLCR == (routingRulesResult.Route == null ? false : routingRulesResult.Route.FallbackToLCR)
                            && a.ignoreMissingRate == (routingRulesResult.Route == null ? false : routingRulesResult.Route.IgnoreMissingRate)
                            select a).First().decision;

            return decision;
        }

        #endregion Methods
    }
}