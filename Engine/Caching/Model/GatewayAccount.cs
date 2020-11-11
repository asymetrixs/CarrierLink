namespace CarrierLink.Controller.Engine.Caching.Model
{
    /// <summary>
    /// This class provides the gateway account
    /// </summary>
    public class GatewayAccount
    {
        #region Constructor

        /// <summary>
        /// Initializes a new instance of the <see cref="GatewayAccount"/> class
        /// </summary>
        /// <param name="id">See <see cref="Id"/></param>
        /// <param name="account">See <see cref="Account"/></param>
        /// <param name="protocol">See <see cref="Protocol"/></param>
        /// <param name="newCaller">See <see cref="NewCaller"/></param>
        /// <param name="newCallername">See <see cref="NewCallername"/></param>
        /// <param name="billTime">See <see cref="BillTime"/></param>
        /// <param name="gatewayId">See <see cref="GatewayId"/></param>
        internal GatewayAccount(string id, string account, string protocol, string newCaller, string newCallername, long billTime, string gatewayId)
        {
            this.Id = id;
            this.Account = account;
            this.Protocol = protocol;
            this.NewCaller = newCaller;
            this.NewCallername = newCallername;
            this.BillTime = billTime;
            this.GatewayId = gatewayId;
        }

        #endregion Constructor

        #region Properties

        /// <summary>
        /// Gets account
        /// </summary>
        internal string Account { get; }

        /// <summary>
        /// Gets bill time
        /// </summary>
        internal long BillTime { get; }

        /// <summary>
        /// Gets gateway Id
        /// </summary>
        internal string GatewayId { get; }

        /// <summary>
        /// Gets gateway account Id
        /// </summary>
        internal string Id { get; }

        /// <summary>
        /// Gets new caller
        /// </summary>
        internal string NewCaller { get; }

        /// <summary>
        /// Gets new caller name
        /// </summary>
        internal string NewCallername { get; }

        /// <summary>
        /// Gets protocol
        /// </summary>
        internal string Protocol { get; }

        /// <summary>
        /// Gets server
        /// </summary>
        internal string Server { get; }

        #endregion Properties
    }
}