namespace CarrierLink.Controller.Engine.Workers.Model
{
    using Caching.Model;
    using System;

    /// <summary>
    /// This class to stores CDR information red from the message to be put into the database
    /// </summary>
    public class CallDataRecord
    {
        #region Yate Properties

        #region Default Yate Properties

        /// <summary>
        /// Gets or sets default Yate Field: address
        /// </summary>
        internal System.Net.IPEndPoint YAddress { get; set; }

        /// <summary>
        /// Gets or sets default Yate Field: billid
        /// </summary>
        internal string YBillId { get; set; }

        /// <summary>
        /// Gets or sets default Yate Field: billtime
        /// </summary>
        internal long YBilltime { get; set; }

        /// <summary>
        /// Gets or sets default Yate Field: called
        /// </summary>
        internal string YCalled { get; set; }

        /// <summary>
        /// Gets or sets default Yate Field: caller
        /// </summary>
        internal string YCaller { get; set; }

        /// <summary>
        /// Gets or sets default Yate Field: callername
        /// </summary>
        internal string YCallername { get; set; }

        /// <summary>
        /// Gets or sets default Yate Field: cause_q931
        /// </summary>
        internal string YCauseQ931 { get; set; }

        /// <summary>
        /// Gets or sets default Yate Field: cause_sip
        /// </summary>
        internal string YCauseSIP { get; set; }

        /// <summary>
        /// Gets or sets default Yate Field: chan
        /// </summary>
        internal string YChan { get; set; }

        /// <summary>
        /// Gets or sets default Yate Field: direction
        /// </summary>
        internal Direction YDirection { get; set; }

        /// <summary>
        /// Gets or sets default Yate Field: duration
        /// </summary>
        internal long YDuration { get; set; }

        /// <summary>
        /// Gets or sets a value indicating whether the call has ended or not - default Yate Field: ended
        /// </summary>
        internal bool YEnded { get; set; }

        /// <summary>
        /// Gets or sets default Yate Field: error
        /// </summary>
        internal string YError { get; set; }

        /// <summary>
        /// Gets or sets default Yate Field: format
        /// </summary>
        internal string YFormat { get; set; }

        /// <summary>
        /// Gets or sets default Yate Field: Formats
        /// </summary>
        internal string YFormats { get; set; }

        /// <summary>
        /// Gets or sets default Yate Field: reason
        /// </summary>
        internal string YReason { get; set; }

        /// <summary>
        /// Gets or sets default Yate Field: ringtime
        /// </summary>
        internal long YRingtime { get; set; }

        /// <summary>
        /// Gets or sets default Yate Field: rtp_addr
        /// </summary>
        internal System.Net.IPEndPoint YRTPAddress { get; set; }

        /// <summary>
        /// Gets or sets a value indicating whether RTP is forwarded or not - default Yate Field: rtp_forward
        /// </summary>
        internal bool YRTPForward { get; set; }

        /// <summary>
        /// Gets or sets default Yate Field: sip_user_agent
        /// </summary>
        internal string YSIPUserAgent { get; set; }

        /// <summary>
        /// Gets or sets default Yate Field: sip_x_asterisk_hangupcause
        /// </summary>
        internal string YSIPXAsteriskHangupCause { get; set; }

        /// <summary>
        /// Gets or sets default Yate Field: sip_x_asterisk_hangupcode
        /// </summary>
        internal string YSIPXAsteriskHangupCode { get; set; }

        /// <summary>
        /// Gets or sets default Yate Field: status
        /// </summary>
        internal string YStatus { get; set; }

        /// <summary>
        /// Gets or sets default Yate Field: time
        /// </summary>
        internal decimal YYateTime { get; set; }
        #endregion Default Yate Properties

        #region CarrierLink Yate Properties

        /// <summary>
        /// Gets or sets CarrierLink Yate Field: clcustomercurrency
        /// </summary>
        internal string CLCustomerCurrency { get; set; }

        /// <summary>
        /// Gets or sets CarrierLink Yate Field: clcustomerid
        /// </summary>
        internal int? CLCustomerId { get; set; }

        /// <summary>
        /// Gets or sets CarrierLink Yate Field: clcustomeripid
        /// </summary>
        internal int? CLCustomerIPId { get; set; }

        /// <summary>
        /// Gets or sets CarrierLink Yate Field: clcustomerrateid
        /// </summary>
        internal long? CLCustomerRateId { get; set; }

        /// <summary>
        /// Gets or sets CarrierLink Yate Field: clcustomerratepermin
        /// </summary>
        internal decimal? CLCustomerRatePerMin { get; set; }

        /// <summary>
        /// Gets or sets CarrierLink Yate Field: clcustomerratetotal
        /// </summary>
        internal decimal? CLCustomerRateTotal { get; set; }
        
        /// <summary>
        /// Gets or sets CarrierLink Yate Field: cldialcodemasterid
        /// </summary>
        internal int? CLDialcodeMasterId { get; set; }

        /// <summary>
        /// Gets or sets CarrierLink Yate Field: clgatewayaccountid
        /// </summary>
        internal int? CLGatewayAccountId { get; set; }

        /// <summary>
        /// Gets or sets CarrierLink Yate Field: clgatewaycurrency
        /// </summary>
        internal string CLGatewayCurrency { get; set; }

        /// <summary>
        /// Gets or sets CarrierLink Yate Field: clgatewayid
        /// </summary>
        internal int? CLGatewayId { get; set; }

        /// <summary>
        /// Gets or sets CarrierLink Yate Field: clgatewayipid
        /// </summary>
        internal int? CLGatewayIPId { get; set; }

        /// <summary>
        /// Gets or sets CarrierLink Yate Field: clgatewayrateid
        /// </summary>
        internal long? CLGatewayRateId { get; set; }

        /// <summary>
        /// Gets or sets CarrierLink Yate Field: clgatewayratepermin
        /// </summary>
        internal decimal? CLGatewayRatePerMin { get; set; }

        /// <summary>
        /// Gets or sets CarrierLink Yate Field: clgatewayratetotal
        /// </summary>
        internal decimal? CLGatewayRateTotal { get; set; }

        /// <summary>
        /// Gets or sets CarrierLink Yate Field: clnodeid
        /// </summary>
        internal int CLNodeId { get; set; }

        /// <summary>
        /// Gets or sets CarrierLink Yate Field: clprocessingtime
        /// </summary>
        internal int? CLProcessingTime { get; set; }

        /// <summary>
        /// Gets or sets CarrierLink Yate Field: generated from 'yate time'
        /// </summary>
        internal DateTime CLSQLTime { get; set; }
        /// <summary>
        /// Gets or sets CarrierLink Yate Field: cltechcalled
        /// </summary>
        internal string CLTechCalled { get; set; }

        /// <summary>
        /// Gets or sets CarrierLink Yate Field: cltrackingid
        /// </summary>
        internal string CLTrackingId { get; set; }

        /// <summary>
        /// Gets or sets CarrierLink Yate Field: clroutingtime
        /// </summary>
        internal int? CLWaitingTime { get; set; }

        /// <summary>
        /// Holds Routing Tree in JSON
        /// </summary>
        internal string RoutingTree { get; set; }

        #endregion CarrierLink Yate Properties

        #endregion Yate Properties

        #region Methods

        /// <summary>
        /// Resets fields for next use
        /// </summary>
        internal void Reset()
        {
            this.YYateTime = 0;
            this.YBillId = string.Empty;
            this.YChan = string.Empty;
            this.YAddress = null;
            this.YCaller = string.Empty;
            this.YCallername = string.Empty;
            this.YCalled = string.Empty;
            this.YStatus = string.Empty;
            this.YReason = string.Empty;
            this.YEnded = false;
            this.YFormat = string.Empty;
            this.YFormats = string.Empty;
            this.YRTPAddress = null;
            this.YRTPForward = false;
            this.YBilltime = 0;
            this.YRingtime = 0;
            this.YDuration = 0;
            this.YDirection = Direction.Incoming;
            this.YCauseQ931 = string.Empty;
            this.YError = string.Empty;
            this.YCauseSIP = string.Empty;
            this.YSIPUserAgent = string.Empty;
            this.YSIPXAsteriskHangupCause = string.Empty;
            this.YSIPXAsteriskHangupCode = string.Empty;
            this.CLSQLTime = new DateTime();
            this.CLGatewayAccountId = null;
            this.CLGatewayIPId = null;
            this.CLCustomerIPId = null;
            this.CLGatewayRatePerMin = null;
            this.CLGatewayRateTotal = null;
            this.CLGatewayCurrency = null;
            this.CLGatewayRateId = null;
            this.CLCustomerRatePerMin = null;
            this.CLCustomerRateTotal = null;
            this.CLCustomerCurrency = null;
            this.CLCustomerRateId = null;
            this.CLDialcodeMasterId = null;
            this.CLNodeId = 0;
            this.CLGatewayId = null;
            this.CLCustomerId = null;
            this.CLProcessingTime = null;
            this.CLTrackingId = null;
            this.CLWaitingTime = null;
            this.CLTechCalled = string.Empty;
            this.RoutingTree = string.Empty;
        }

        #endregion Methods
    }
}