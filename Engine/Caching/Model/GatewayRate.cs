namespace CarrierLink.Controller.Engine.Caching.Model
{
    /// <summary>
    /// This class provides the gateway price
    /// </summary>
    public class GatewayRate
    {
        #region Constructor

        /// <summary>
        /// Initializes a new instance of the <see cref="GatewayRate"/> class
        /// </summary>
        /// <param name="gatewayId">See <see cref="GatewayId"/></param>
        /// <param name="gatewayRateId">See <see cref="GatewayRateId"/></param>
        /// <param name="ratePerMinute">See <see cref="RatePerMinute"/></param>
        /// <param name="currency">See <see cref="Currency"/></param>
        /// <param name="rateNormalized">See <see cref="RateNormalized"/></param>
        /// <param name="timeband">See <see cref="Timeband"/></param>
        internal GatewayRate(int gatewayId, long gatewayRateId, decimal ratePerMinute, string currency, decimal rateNormalized, string timeband)
        {
            this.GatewayId = gatewayId;
            this.GatewayRateId = gatewayRateId;
            this.RatePerMinute = ratePerMinute;
            this.RateNormalized = rateNormalized;
            this.Currency = currency;
            this.Timeband = timeband;
        }

        #endregion Constructor

        #region Properties

        /// <summary>
        /// Gets currency
        /// </summary>
        internal string Currency { get; }

        /// <summary>
        /// Gets gateway Id
        /// </summary>
        internal int GatewayId { get; }

        /// <summary>
        /// Gets gateway rate Id
        /// </summary>
        internal long GatewayRateId { get; }

        /// <summary>
        /// Gets gateway rate per minute
        /// </summary>
        internal decimal RatePerMinute { get; }

        /// <summary>
        /// Gets normalized rate
        /// </summary>
        internal decimal RateNormalized { get; }

        /// <summary>
        /// Gets time band
        /// </summary>
        internal string Timeband { get; }

        #endregion Properties
    }
}