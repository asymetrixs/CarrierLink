namespace CarrierLink.Controller.Engine.Caching.Model
{
    /// <summary>
    /// This class provides the gateway IP
    /// </summary>
    public class GatewayIP
    {
        #region Constructor

        /// <summary>
        /// Initializes a new instance of the <see cref="GatewayIP"/> class
        /// </summary>
        /// <param name="id">See <see cref="Id"/></param>
        /// <param name="address">See <see cref="Address"/></param>
        /// <param name="port">See <see cref="Port"/></param>
        /// <param name="protocol">See <see cref="Protocol"/></param>
        /// <param name="rtpAddress">See <see cref="RTPAddress"/></param>
        /// <param name="rtpPort">See <see cref="RTPPort"/></param>
        /// <param name="rtpForward">See <see cref="RTPForward"/></param>
        /// <param name="sipPAssertedIdentity">See <see cref="SIPPAssertedIdentity"/></param>
        /// <param name="billTime">See <see cref="BillTime"/></param>
        /// <param name="gatewayId">See <see cref="GatewayId"/></param>
        internal GatewayIP(string id, string address, string port, string protocol, string rtpAddress, string rtpPort, string rtpForward, string sipPAssertedIdentity, long billTime, string gatewayId)
        {
            this.Id = id;
            this.Address = address;
            this.Port = port;
            this.Protocol = protocol;
            this.RTPAddress = rtpAddress;
            this.RTPPort = rtpPort;
            this.RTPForward = rtpForward;
            this.SIPPAssertedIdentity = sipPAssertedIdentity;
            this.BillTime = billTime;
            this.GatewayId = gatewayId;
        }

        #endregion Constructor

        #region Fields

        /// <summary>
        /// Gets database Id
        /// </summary>
        internal string Id { get; }

        /// <summary>
        /// Gets address
        /// </summary>
        internal string Address { get; }

        /// <summary>
        /// Gets port
        /// </summary>
        internal string Port { get; }

        /// <summary>
        /// Gets protocol
        /// </summary>
        internal string Protocol { get; }

        /// <summary>
        /// Gets RTP address
        /// </summary>
        internal string RTPAddress { get; }

        /// <summary>
        /// Gets RTP Port
        /// </summary>
        internal string RTPPort { get; }

        /// <summary>
        /// Gets a value indicating whether RTP should be forwarded or not
        /// </summary>
        internal string RTPForward { get; }

        /// <summary>
        /// Gets the SIP asserted identity
        /// </summary>
        internal string SIPPAssertedIdentity { get; }

        /// <summary>
        /// Gets bill time
        /// </summary>
        internal long BillTime { get; }

        /// <summary>
        /// Gets database Id of gateway
        /// </summary>
        internal string GatewayId { get; }

        #endregion Properties
    }
}