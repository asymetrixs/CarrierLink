namespace CarrierLink.Controller.Yate.Messaging
{
    using Utilities;

    /// <summary>
    /// Yate message types
    /// </summary>
    public enum MessageType
    {
        [TechnicalName("engine.timer")]
        EngineTimer,

        [TechnicalName("call.route")]
        CallRoute,

        [TechnicalName("setlocal")]
        Query,

        [TechnicalName("call.cdr")]
        CallCdr,

        [TechnicalName("monitor.query")]
        MonitorQuery,

        [TechnicalName("config")]
        Config,

        [TechnicalName("chan.dtmf")]
        ChanDtmf,

        [TechnicalName("chan.startup")]
        ChanStartup,

        [TechnicalName("call.execute")]
        CallExecute,

        [TechnicalName("chan.hangup")]
        ChanHangup,

        [TechnicalName("chan.disconnected")]
        ChanDisconnected,

        [TechnicalName("chan.notify")]
        ChanNotify,

        [TechnicalName("call.answered")]
        CallAnswered,

        [TechnicalName("call.drop")]
        CallDrop,

        [TechnicalName("chan.attach")]
        ChanAttach,

        [TechnicalName("chan.masquerade")]
        ChanMasquerade,

        [TechnicalName("chan.rtp")]
        ChanRtp,

        [TechnicalName("cali.node")]
        CarrierLinkNode
    }
}