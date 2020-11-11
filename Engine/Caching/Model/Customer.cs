namespace CarrierLink.Controller.Engine.Caching.Model
{
    /// <summary>
    /// This class provides customer information
    /// </summary>
    public class Customer
    {
        #region Constructor

        /// <summary>
        /// Initializes a new instance of the <see cref="Customer"/> class
        /// </summary>
        /// <param name="id">See <see cref="Id"/></param>
        /// <param name="identifier">See <see cref="Identifier"/></param>
        /// <param name="customerIPId">See <see cref="CustomerIPId"/></param>
        /// <param name="contextId">See <see cref="ContextId"/></param>
        /// <param name="limitOK">See <see cref="LimitOK"/></param>
        /// <param name="fakeRinging">See <see cref="FakeRinging"/></param>
        /// <param name="customerIP">See <see cref="CustomerIP"/></param>
        /// <param name="prefix">See <see cref="Prefix"/></param>
        /// <param name="qosGroupId">See <see cref="QoSGroupId"/></param>
        /// <param name="companyId">See <see cref="CompanyId"/></param>
        internal Customer(int id, string identifier, int customerIPId, int contextId, bool limitOK, bool fakeRinging, string customerIP, string prefix, int qosGroupId, int companyId)
        {
            this.Id = id;
            this.Identifier = identifier;
            this.CustomerIPId = customerIPId;
            this.ContextId = contextId;
            this.LimitOK = limitOK;
            this.FakeRinging = fakeRinging;
            this.CustomerIP = customerIP;
            this.Prefix = prefix;
            this.QoSGroupId = qosGroupId;
            this.CompanyId = companyId;
        }

        #endregion Constructor

        #region Properties

        /// <summary>
        /// Gets Id of Company
        /// </summary>
        internal int CompanyId { get; }

        /// <summary>
        /// Gets Id of context the customer belongs to
        /// </summary>
        internal int ContextId { get; }

        /// <summary>
        /// Gets IP customer is using
        /// </summary>
        internal string CustomerIP { get; }

        /// <summary>
        /// Gets Id of IP customer is using
        /// </summary>
        internal int CustomerIPId { get; }

        /// <summary>
        /// Gets a value indicating whether the customer needs fake ringing or not
        /// </summary>
        internal bool FakeRinging { get; }

        /// <summary>
        /// Gets Id of customer
        /// </summary>
        internal int Id { get; }

        /// <summary>
        /// Gets Identifier of customer (IP#Prefix)
        /// </summary>
        internal string Identifier { get; }

        /// <summary>
        /// Gets a value indicating whether limits are ok or not
        /// </summary>
        internal bool LimitOK { get; }

        /// <summary>
        /// Gets prefix the customer is using
        /// </summary>
        internal string Prefix { get; }

        /// <summary>
        /// Gets Id of Quality of Service group
        /// </summary>
        internal int QoSGroupId { get; }
        
        #endregion Properties
    }
}