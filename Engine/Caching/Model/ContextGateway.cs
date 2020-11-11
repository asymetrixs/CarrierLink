namespace CarrierLink.Controller.Engine.Caching.Model
{
    /// <summary>
    /// This class provides the connection between the context and the gateways
    /// </summary>
    public class ContextGateway
    {
        #region Constructor

        /// <summary>
        /// Initializes a new instance of the <see cref="ContextGateway"/> class
        /// </summary>
        /// <param name="contextId">Context Id</param>
        /// <param name="gatewayId">Gateway Id</param>
        internal ContextGateway(int contextId, int gatewayId)
        {
            this.ContextId = contextId;
            this.GatewayId = gatewayId;
        }

        #endregion Constructor

        #region Properties

        /// <summary>
        /// Gets Id of context
        /// </summary>
        internal int ContextId { get; }

        /// <summary>
        /// Gets Id of gateway
        /// </summary>
        internal int GatewayId { get; }

        #endregion Properties

        #region Methods

        /// <summary>
        /// Compares two context gateway instances
        /// </summary>
        /// <param name="obj"><see cref="ContextGateway"/> instance to compare with</param>
        /// <returns>True if same, false if not</returns>
        public override bool Equals(object obj)
        {
            var cg = (ContextGateway)obj;
            return this.ContextId == cg.ContextId && this.GatewayId == cg.GatewayId;
        }

        /// <summary>
        /// Generates the Hash Code of that instance
        /// </summary>
        /// <returns>Hash Code</returns>
        public override int GetHashCode()
        {
            return (this.ContextId.GetHashCode() * 1009) + (this.GatewayId.GetHashCode() * 5);
        }

        #endregion Methods
    }
}