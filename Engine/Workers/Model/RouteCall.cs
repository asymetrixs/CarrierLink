namespace CarrierLink.Controller.Engine.Workers.Model
{
    /// <summary>
    /// This class holds call route information
    /// </summary>
    internal class RouteCall : Route
    {
        #region Yate Properties

        #region Default Yate Properties

        /// <summary>
        /// Gets or sets Default Yate Field: callto.X.called
        /// </summary>
        internal string YCalled { get; set; }

        /// <summary>
        /// Gets or sets Default Yate Field: callto.X.caller
        /// </summary>
        internal string YCaller { get; set; }

        /// <summary>
        /// Gets or sets Default Yate Field: callto.X.callername
        /// </summary>
        internal string YCallername { get; set; }

        /// <summary>
        /// Gets or sets Default Yate Field: callto.X.format
        /// </summary>
        internal string YFormat { get; set; }

        /// <summary>
        /// Gets or sets Default Yate Field: callto.X.formats
        /// </summary>
        internal string YFormats { get; set; }

        /// <summary>
        /// Gets or sets Default Yate Field: callto.X.line
        /// </summary>
        internal string YLine { get; set; }
        
        /// <summary>
        /// Gets or sets Default Yate Field: callto.X.maxcall
        /// </summary>
        internal string YMaxCall { get; set; }

        /// <summary>
        /// Gets or sets Default Yate Field: callto.X.oconnection_id
        /// </summary>
        internal string YOConnectionID { get; set; }

        /// <summary>
        /// Gets or sets Default Yate Field: callto.X.rtp_addr
        /// </summary>
        internal string YRTPAddr { get; set; }

        /// <summary>
        /// Gets or sets Default Yate Field: callto.X.rtp_port
        /// </summary>
        internal string YRTPPort { get; set; }

        /// <summary>
        /// Gets or sets Default Yate Field: callto.X.rtp_forward
        /// </summary>
        internal string YRTPForward { get; set; }

        /// <summary>
        /// Gets or sets Default Yate Field: callto.X.timeout
        /// </summary>
        internal string YTimeout { get; set; }

        #endregion Default Yate Properties

        #region SIP Properties

        /// <summary>
        /// Gets or sets Standard SIP Field: callto.X.osip_P-Asserted-Identity
        /// </summary>
        internal string OSIPPAssertedIdentity { get; set; }

        /// <summary>
        /// Gets or sets CarrierLink SIP Field: callto.X.osip_Gateway-ID
        /// </summary>
        internal string OSIPGatewayID { get; set; }

        /// <summary>
        /// Gets or sets CarrierLink SIP Field: callto.X.osip_Tracking-ID
        /// </summary>
        internal string OSIPTrackingID { get; set; }

        #endregion SIP Properties

        #region CarrierLink Yate Properties

        /// <summary>
        /// Gets or sets CarrierLink Yate Field: callto.X.cldecision
        /// </summary>
        internal string CLDecision { get; set; }

        /// <summary>
        /// Gets or sets CarrierLink Yate Field: callto.X.clgatewayid
        /// </summary>
        internal string CLGatewayID { get; set; }

        /// <summary>
        /// Gets or sets CarrierLink Yate Field: callto.X.clgatewayaccountid
        /// </summary>
        internal string CLGatewayAccountID { get; set; }

        /// <summary>
        /// Gets or sets CarrierLink Yate Field: callto.X.clgatewayipid
        /// </summary>
        internal string CLGatewayIPID { get; set; }

        /// <summary>
        /// Gets CarrierLink Yate Field: callto.X.cltechcalled
        /// </summary>
        internal string CLTechCalled
        {
            get
            {
                return this.YTARGET;
            }
        }

        /// <summary>
        /// Gets or sets CarrierLink Yate Field: callto.X.clgatewaypriceid
        /// </summary>
        internal string CLGatewayRateId { get; set; }

        /// <summary>
        /// Gets or sets CarrierLink Yate Field: callto.X.clgatewaypricepermin
        /// </summary>
        internal string CLGatewayRatePerMin { get; set; }

        /// <summary>
        /// Gets or sets CarrierLink Yate Field: callto.X.clgatewaycurrency
        /// </summary>
        internal string CLGatewayCurrency { get; set; }

        #endregion CarrierLink Yate Properties

        #endregion Yate Properties
    }
}