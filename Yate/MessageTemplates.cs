namespace CarrierLink.Controller.Yate
{
    public static class MessageTemplates
    {
        #region Fields

        /// <summary>
        /// Call data record acknowledge
        /// </summary>
        public const string CALL_DATA_RECORD_ACKNOWLEDGE = "message:{0}:{1}:call.cdr::";

        /// <summary>
        /// Route acknowledge no fork
        /// </summary>
        public const string ROUTE_ACKNOWLEDGE_NO_FORK = "message:{0}:{1}:call.route::error={2}:reason={3}:clnodeid={4}:clcustomerid={5}"
            + ":clcustomeripid={6}:cltrackingid={7}:clprocessingtime={8}:clcustomerpriceid={9}:clcustomerpricepermin={10}:clcustomercurrency={11}"
            + ":cldialcodemasterid={12}:clwaitingtime={13}:copyparams=clgatewayid,cltechcalled,clgatewayipid,clgatewayaccountid,cltrackingid,clwaitingtime,"
            + "clprocessingtime,clcustomerid,cldialcodemasterid,clgatewaypriceid,clgatewaypricepermin,clgatewaycurrency,clcustomerpriceid,clcustomerpricepermin,"
            + "clcustomercurrency,clnodeid,clcustomeripid";

        /// <summary>
        /// Route acknowledge no fork route
        /// </summary>
        public const string ROUTE_ACKNOWLEDGE_NO_FORK_ROUTE = ":location={0}:called={1}:caller={2}:callername={3}:format={4}:formats={5}:line={6}:maxcall={7}"
            + ":osip_P-Asserted-Identity={8}:osip_Gateway-ID={9}:osip_Tracking-ID={10}:rtp_addr={11}:rtp_forward={12}:rtp_port={13}:oconnection_id={14}:" +
            "clgatewayid={15}:clgatewayaccountid={16}:clgatewayipid={17}:cltechcalled={18}:clgatewaypriceid={19}:clgatewaypricepermin={20}:clgatewaycurrency={21}" +
            ":timeout={22}";

        /// <summary>
        /// Route acknowledge fork
        /// </summary>
        public const string ROUTE_ACKNOWLEDGE_FORK = "message:{0}:{1}:call.route::error={2}:reason={3}:location={4}:fork.calltype={5}:fork.autoring={6}:" +
            "fork.automessage={7}:fork.ringer={8}:clnodeid={9}:clcustomerid={10}:clcustomeripid={11}:cltrackingid={12}:clprocessingtime={13}:clcustomerpriceid={14}" +
            ":clcustomerpricepermin={15}:clcustomercurrency={16}:cldialcodemasterid={17}:clwaitingtime={18}:copyparams=clgatewayid,cltechcalled,clgatewayipid," +
            "clgatewayaccountid,cltrackingid,clwaitingtime,clprocessingtime,clcustomerid,cldialcodemasterid,clgatewaypriceid,clgatewaypricepermin,clgatewaycurrency," +
            "clcustomerpriceid,clcustomerpricepermin,clcustomercurrency,clnodeid,clcustomeripid";

        /// <summary>
        /// Route acknowledge location
        /// </summary>
        public const string ROUTE_ACKNOWLEDGE_LOCATION = ":callto.{0}={1}";

        /// <summary>
        /// Route acknowlege call to
        /// </summary>
        public const string ROUTE_ACKNOWLEDGE_CALL_TO = ":callto.{0}={1}:callto.{0}.called={2}:callto.{0}.caller={3}:callto.{0}.callername={4}:callto.{0}.format={5}" +
            ":callto.{0}.formats={6}:callto.{0}.line={7}:callto.{0}.maxcall={8}:callto.{0}.osip_P-Asserted-Identity={9}:callto.{0}.osip_Gateway-ID={10}" +
            ":callto.{0}.osip_Tracking-ID={11}:callto.{0}.rtp_addr={12}:callto.{0}.rtp_forward={13}:callto.{0}.rtp_port={14}:callto.{0}.oconnection_id={15}" +
            ":callto.{0}.clgatewayid={16}:callto.{0}.clgatewayaccountid={17}:callto.{0}.clgatewayipid={18}:callto.{0}.cltechcalled={19}:callto.{0}.clgatewaypriceid={20}" +
            ":callto.{0}.clgatewaypricepermin={21}:callto.{0}.clgatewaycurrency={22}:callto.{0}.cldecision={23}:callto.{0}.timeout={24}";

        /// <summary>
        /// Engine timer to string
        /// </summary>
        public const string ENGINE_TIMER_TO_STRING = "{0}>> ID: {1} - Nodename: {2} - Time: {3:yyyy-MM-dd HH:mm:ss}";

        /// <summary>
        /// Engine timer acknowledge
        /// </summary>
        public const string ENGINE_TIMER_ACKNOWLEDGE = "message:{0}:{1}:engine.timer::time={2}";

        /// <summary>
        /// Chan DTMF acknowledge
        /// </summary>
        public const string CHAN_DTMF_ACKNOWLEDGE = "message:{0}:{1}:chan.dtmf::";

        /// <summary>
        /// Chan notify acknowledge
        /// </summary>
        public const string CHAN_NOTIFY_ACKNOWLEDGE = "message:{0}:{1}:chan.notify::";

        /// <summary>
        /// Unhandled message
        /// </summary>
        public const string UNHANDLED_MESSAGE = "message:{0}:{1}:{2}::";

        #endregion
    }
}
