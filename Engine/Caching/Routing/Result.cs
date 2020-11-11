namespace CarrierLink.Controller.Engine.Caching.Routing
{
    using Model;

    /// <summary>
    /// This class provides information about how and where to route a call
    /// </summary>
    internal class Result
    {
        #region Properties

        /// <summary>
        /// Gets a value indicating whether the customer has a rate or not
        /// </summary>
        internal bool CustomerHasRate { get; private set; }

        /// <summary>
        /// Gets currency of customers rate
        /// </summary>
        internal string CustomerRateCurrency { get; private set; }

        /// <summary>
        /// Gets database Id of customers rate
        /// </summary>
        internal long? CustomerRateId { get; private set; }

        /// <summary>
        /// Gets value of customers rate normalized to USD
        /// </summary>
        internal decimal? CustomerRateNormalized { get; private set; }

        /// <summary>
        /// Gets value of customers rate
        /// </summary>
        internal decimal? CustomerRatePerMin { get; private set; }

        /// <summary>
        /// Gets or sets decision about how to route the call
        /// </summary>
        internal Action Decision { get; set; }

        /// <summary>
        /// Gets a value indicating whether fake ringing should be provided or not
        /// </summary>
        internal bool FakeRinging { get; private set; }
        
        /// <summary>
        /// Gets a value indicating whether the customer has a fixed route or not
        /// </summary>
        internal bool HasRoute
        {
            get
            {
                return this.Route != null;
            }
        }

        /// <summary>
        /// Gets a value indicating whether the context offers Least Cost Routing (LCR) or not
        /// </summary>
        internal bool IsLCR { get; private set; }

        /// <summary>
        /// Gets route information
        /// </summary>
        internal Route Route { get; private set; }

        #endregion Properties

        #region Methods
        
        /// <summary>
        /// Sets context information
        /// </summary>
        /// <param name="context">See <see cref="Context"/></param>
        internal void SetContext(Context context)
        {
            this.IsLCR = context.IsLeastCostRouting;
        }

        /// <summary>
        /// Set customer information
        /// </summary>
        /// <param name="customer">See <see cref="Customer"/></param>
        /// <param name="customerRate">See <see cref="CustomerRate"/></param>
        internal void SetCustomerInformation(Customer customer, CustomerRate customerRate)
        {
            this.FakeRinging = customer.FakeRinging;

            this.CustomerHasRate = customerRate.Id.HasValue;
            this.CustomerRateId = customerRate.Id;
            this.CustomerRatePerMin = customerRate.RatePerMin;
            this.CustomerRateCurrency = customerRate.Currency;
            this.CustomerRateNormalized = customerRate.RateNormalized;
        }

        /// <summary>
        /// Sets route information
        /// </summary>
        /// <param name="route">See <see cref="Database.Model.Route"/></param>
        internal void SetRoute(Route route)
        {
            this.Route = route;
        }

        #endregion Methods
    }
}