namespace CarrierLink.Controller.Engine.Caching.Model
{
    /// <summary>
    /// This class provides the customer price
    /// </summary>
    public class CustomerRate
    {
        #region Properties

        /// <summary>
        /// Gets Currency of rate
        /// </summary>
        internal string Currency { get; private set; }

        /// <summary>
        /// Gets Id of rate
        /// </summary>
        internal long? Id { get; private set; }

        /// <summary>
        /// Gets normalized rate
        /// </summary>
        internal decimal? RateNormalized { get; private set; }

        /// <summary>
        /// Gets rate per minute
        /// </summary>
        internal decimal? RatePerMin { get; private set; }

        #endregion Properties

        #region Methods

        /// <summary>
        /// Sets information about the rate
        /// </summary>
        /// <param name="id">Rate Id</param>
        /// <param name="ratePerMin">Rate per minute</param>
        /// <param name="currency">Currency of rate</param>
        /// <param name="rateNormalized">Normalized value of rate</param>
        internal void Set(long? id, decimal? ratePerMin, string currency, decimal? rateNormalized)
        {
            this.Id = id;
            this.RatePerMin = ratePerMin;
            this.Currency = currency;
            this.RateNormalized = rateNormalized;
        }

        #endregion Methods
    }
}