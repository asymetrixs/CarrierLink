namespace CarrierLink.Controller.Engine.Caching.Model
{
    /// <summary>
    /// This class provides the context
    /// </summary>
    public class Context
    {
        #region Constructor

        /// <summary>
        /// Initializes a new instance of the <see cref="Context"/> class
        /// </summary>
        /// <param name="id">See <see cref="Id"/></param>
        /// <param name="timeout">See <see cref="Timeout"/></param>
        /// <param name="isLeastCostRouting">See <see cref="IsLeastCostRouting"/></param>
        /// <param name="enableLCRWithoutRate">See <see cref="EnableLCRWithoutRate"/></param>
        /// <param name="forkConnectBehavior">See <see cref="ForkConnectBehavior"/></param>
        /// <param name="forkConnectBehaviorTimeout">See <see cref="ForkConnectBehaviorTimeout"/></param>
        /// <param name="lcrBlendPercentage">See <see cref="LCRBlendPercentage"/></param>
        /// <param name="lcrBlendToContextId">See <see cref="LCRBlendToContextId"/></param>
        internal Context(int id, int timeout, bool isLeastCostRouting, bool enableLCRWithoutRate, ForkConnectBehavior forkConnectBehavior,
            int forkConnectBehaviorTimeout, int? lcrBlendPercentage, int? lcrBlendToContextId)
        {
            this.Id = id;
            this.Timeout = timeout;
            this.IsLeastCostRouting = isLeastCostRouting;
            this.EnableLCRWithoutRate = enableLCRWithoutRate;
            this.ForkConnectBehavior = forkConnectBehavior;
            this.ForkConnectBehaviorTimeout = forkConnectBehaviorTimeout;
            this.LCRBlendPercentage = lcrBlendPercentage;
            this.LCRBlendToContextId = lcrBlendToContextId;
        }

        #endregion Constructor

        #region Properties

        /// <summary>
        /// Gets a value indicating whether LCR is also possible if the customer does not have a rate
        /// </summary>
        internal bool EnableLCRWithoutRate { get; }

        /// <summary>
        /// Gets a value indicating the probability of call blending
        /// </summary>
        internal int? LCRBlendPercentage { get; }

        /// <summary>
        /// Gets a value indicating to which context the call should get blended
        /// </summary>
        internal int? LCRBlendToContextId { get; }

        /// <summary>
        /// Gets the connect behavior on forking
        /// </summary>
        internal ForkConnectBehavior ForkConnectBehavior { get; }

        /// <summary>
        /// Gets the timeout for connecting to a gateway
        /// </summary>
        internal int ForkConnectBehaviorTimeout { get; }

        /// <summary>
        /// Gets Id of context
        /// </summary>
        internal int Id { get; }

        /// <summary>
        /// Gets a value indicating whether this context support Least Cost Routing or not
        /// </summary>
        internal bool IsLeastCostRouting { get; }
        
        /// <summary>
        /// Gets timeout for call
        /// </summary>
        internal int Timeout { get; }

        #endregion Properties

        #region Methods

        /// <summary>
        /// Override of <see cref="Equals(object)"/> 
        /// </summary>
        /// <returns></returns>
        public override bool Equals(object obj)
        {
            return (obj as Context)?.Id == this.Id;
        }

        /// <summary>
        /// Override of <see cref="GetHashCode"/> 
        /// </summary>
        /// <returns></returns>
        public override int GetHashCode()
        {
            return this.Id.GetHashCode();
        }

        /// <summary>
        /// Override of <see cref="ToString"/> 
        /// </summary>
        /// <returns></returns>
        public override string ToString()
        {
            return this.Id.ToString();
        }

        #endregion
    }
}