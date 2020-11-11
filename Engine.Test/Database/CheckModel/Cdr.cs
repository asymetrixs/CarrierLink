namespace CarrierLink.Controller.Engine.Test.Database.CheckModel
{
    using System;

    /// <summary>
    /// Class representing the CDR database table
    /// </summary>
    internal class Cdr
    {
        #region Properties

        /// <summary>
        /// Database Id
        /// </summary>
        internal long Id { get; set; }

        /// <summary>
        /// Actual Readable Time of call
        /// </summary>
        internal DateTime SqlTime { get; set; }

        /// <summary>
        /// Unix Time of call
        /// </summary>
        internal decimal YateTime { get; set; }

        /// <summary>
        /// Bill Id of call
        /// </summary>
        internal string BillId { get; set; }

        /// <summary>
        /// Channel used by call
        /// </summary>
        internal string Chan { get; set; }

        /// <summary>
        /// Sending/Receiving IP Address of call
        /// </summary>
        internal string Address { get; set; }

        /// <summary>
        /// Sending/Receiving Port of call
        /// </summary>
        internal int Port { get; set; }

        /// <summary>
        /// Caller of call
        /// </summary>
        internal string Caller { get; set; }

        /// <summary>
        /// Callername of call
        /// </summary>
        internal string Callername { get; set; }

        /// <summary>
        /// Called number/user of call
        /// </summary>
        internal string Called { get; set; }

        /// <summary>
        /// Status of Call
        /// </summary>
        internal string Status { get; set; }

        /// <summary>
        /// Reason caused ending the call
        /// </summary>
        internal string Reason { get; set; }

        /// <summary>
        /// Value indicating whether call has ended or not
        /// </summary>
        internal bool Ended { get; set; }

        /// <summary>
        /// Gateway Account Id of call if sending to account
        /// </summary>
        internal int? GatewayAccountId { get; set; }

        /// <summary>
        /// Gateway IP Id of call if sending to IP
        /// </summary>
        internal int? GatewayIpId { get; set; }

        /// <summary>
        /// Customer IP Id of call origination
        /// </summary>
        internal int? CustomerIpId { get; set; }

        /// <summary>
        /// Outgoing price per minute
        /// </summary>
        internal decimal? GatewayPricePerMin { get; set; }

        /// <summary>
        /// Outgoing price total
        /// </summary>
        internal decimal? GatewayPriceTotal { get; set; }

        /// <summary>
        /// Outgoing price currency
        /// </summary>
        internal string GatewayCurrency { get; set; }

        /// <summary>
        /// Outgoing price id
        /// </summary>
        internal long? GatewayPriceId { get; set; }

        /// <summary>
        /// Incoming price per minute
        /// </summary>
        internal decimal? CustomerPricePerMin { get; set; }

        /// <summary>
        /// Incoming price total
        /// </summary>
        internal decimal? CustomerPriceTotal { get; set; }

        /// <summary>
        /// Incoming price currency
        /// </summary>
        internal string CustomerCurrency { get; set; }

        /// <summary>
        /// Incoming price id
        /// </summary>
        internal long? CustomerPriceId { get; set; }

        /// <summary>
        /// Dialcode Id of call
        /// </summary>
        internal int? DialcodeMasterId { get; set; }

        /// <summary>
        /// Node Id handling the call
        /// </summary>
        internal int NodeId { get; set; }

        /// <summary>
        /// Date the record was billed
        /// </summary>
        internal DateTime? BilledOn { get; set; }

        /// <summary>
        /// Outgoing gateway id
        /// </summary>
        internal int? GatewayId { get; set; }

        /// <summary>
        /// Incoming customer id
        /// </summary>
        internal int? CustomerId { get; set; }

        /// <summary>
        /// Used format for call
        /// </summary>
        internal string Format { get; set; }

        /// <summary>
        /// Available formats for call
        /// </summary>
        internal string Formats { get; set; }

        /// <summary>
        /// RTP Address of call
        /// </summary>
        internal string RTPAddress { get; set; }

        /// <summary>
        /// Indicates if RTP was forwarded or handled
        /// </summary>
        internal bool? RTPForward { get; set; }

        /// <summary>
        /// Sql Time when call ended
        /// </summary>
        internal DateTime? SqlTimeEnd { get; set; }

        /// <summary>
        /// Technical calling string
        /// </summary>
        internal string TechCalled { get; set; }

        /// <summary>
        /// RTP Port of call
        /// </summary>
        internal int? RTPPort { get; set; }

        /// <summary>
        /// Tracking Id for internal tracking of call in case is sent through different nodes
        /// </summary>
        internal string TrackingId { get; set; }

        /// <summary>
        /// Actual billing time of call
        /// </summary>
        internal long? BillTime { get; set; }

        /// <summary>
        /// Actual ringing time of call
        /// </summary>
        internal long? Ringtime { get; set; }

        /// <summary>
        /// Actual total duration of call
        /// </summary>
        internal long? Duration { get; set; }

        /// <summary>
        /// Incoming or outgoing
        /// </summary>
        internal string Direction { get; set; }

        /// <summary>
        /// Cause in Q931 protocol
        /// </summary>
        internal string CauseQ931 { get; set; }

        /// <summary>
        /// Duration for prerouting the call
        /// </summary>
        internal long? PrerouteDuration { get; set; }

        /// <summary>
        /// Duration for routing the call
        /// </summary>
        internal long? RouteDuration { get; set; }

        /// <summary>
        /// Error causing end of call
        /// </summary>
        internal string Error { get; set; }

        /// <summary>
        /// Reason for terminating SIP
        /// </summary>
        internal string CauseSIP { get; set; }

        /// <summary>
        /// Incoming/Outgoing user agent
        /// </summary>
        internal string SIPUserAgent { get; set; }

        /// <summary>
        /// Incoming/Outgoing Asterisk Hangup Cause
        /// </summary>
        internal string SIPXAsteriskHangupCause { get; set; }

        /// <summary>
        /// Incoming/Outgoing Asterisk Hangup Cause Code
        /// </summary>
        internal string SIPXAsteriskHangupCauseCode { get; set; }

        /// <summary>
        /// Gateway Response time
        /// </summary>
        internal long? ResponseTime { get; set; }

        /// <summary>
        /// RTP Packets sent
        /// </summary>
        internal long? RTPPacketsSent { get; set; }

        /// <summary>
        /// RTP Octests Sent
        /// </summary>
        internal long? RTPOctetsSent { get; set; }

        /// <summary>
        /// RTP Packets Received
        /// </summary>
        internal long? RTPPacketsReceived { get; set; }

        /// <summary>
        /// RTP Octets Received
        /// </summary>
        internal long? RTPOctetsReceived { get; set; }

        /// <summary>
        /// RTP Packet Loss
        /// </summary>
        internal long? RTPPacketLoss { get; set; }

        /// <summary>
        /// Routing waiting time
        /// </summary>
        internal int? RoutingWaitingTime { get; set; }

        /// <summary>
        /// Routing processing time
        /// </summary>
        internal int? RoutingProcessingTime { get; set; }
        
        /// <summary>
        /// Routing Tree
        /// </summary>
        internal string RoutingTree { get; set; }

        #endregion
    }
}
