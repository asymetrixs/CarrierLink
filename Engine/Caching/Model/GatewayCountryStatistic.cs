namespace CarrierLink.Controller.Engine.Caching.Model
{
    /// <summary>
    /// This class provides statistics for the country of the gateway
    /// </summary>
    internal class GatewayCountryStatistic
    {
        #region Constructor

        /// <summary>
        /// Initializes a new instance of the <see cref="GatewayCountryStatistic"/> class
        /// </summary>
        /// <param name="id">See <see cref="Id"/></param>
        /// <param name="gatewayId">See <see cref="GatewayId"/></param>
        /// <param name="number">See <see cref="Number"/></param>
        /// <param name="asr">See <see cref="ASR"/></param>
        /// <param name="created">See <see cref="Created"/></param>
        internal GatewayCountryStatistic(long id, int gatewayId, string number, decimal asr, long created)
        {
            this.Id = id;
            this.GatewayId = gatewayId;
            this.Number = number;
            this.ASR = asr;
            this.Created = created;
        }

        #endregion Constructor

        #region Properties

        /// <summary>
        /// Gets Answer-Seizure Ratio (ASR) for <see cref="Number"/>
        /// </summary>
        internal decimal ASR { get; }

        /// <summary>
        /// Gets date of creation of that record
        /// </summary>
        internal long Created { get; }

        /// <summary>
        /// Gets gateway Id
        /// </summary>
        internal int GatewayId { get; }

        /// <summary>
        /// Gets database Id
        /// </summary>
        internal long Id { get; }

        /// <summary>
        /// Gets target dial code number
        /// </summary>
        internal string Number { get; }

        #endregion Properties
    }
}