namespace CarrierLink.Controller.Engine.Workers.Model
{
    /// <summary>
    /// This class provides information about the target gateway for routing priority
    /// </summary>
    internal class TargetGateway
    {
        #region Properties

        /// <summary>
        /// Gets or sets Gateway Id
        /// </summary>
        internal int GatewayId { get; set; }

        /// <summary>
        /// Gets or sets Gateway Priority
        /// </summary>
        internal decimal Priority { get; set; }

        /// <summary>
        /// Gets or sets Gateway Rate Id
        /// </summary>
        internal long RateId { get; set; }

        /// <summary>
        /// Gets or sets Gateway Rate per Minute
        /// </summary>
        internal decimal RatePerMinute { get; set; }

        /// <summary>
        /// Gets or sets Gateway Rate Currency
        /// </summary>
        internal string Currency { get; set; }

        #endregion Properties
    }
}
