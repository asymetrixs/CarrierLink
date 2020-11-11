namespace CarrierLink.Controller.Yate
{
    using Utilities;

    /// <summary>
    /// Monitor parameters supported by Yate
    /// </summary>
    public enum MonitorParameter
    {
        /// <summary>
        /// Database Count
        /// </summary>
        [TechnicalName("databaseCount")]
        DatabaseCount,

        /// <summary>
        /// Database Index
        /// </summary>
        [TechnicalName("databaseIndex")]
        DatabaseIndex,

        /// <summary>
        /// Database Account
        /// </summary>
        [TechnicalName("databaseAccount")]
        DatabaseAccount,

        /// <summary>
        /// Database Queries Count
        /// </summary>
        [TechnicalName("queriesCount")]
        DatabaseQueriesCount,

        /// <summary>
        /// Database Failed Queries
        /// </summary>
        [TechnicalName("failedQueries")]
        DatabaseFailedQueries,

        /// <summary>
        /// Database Error Queries
        /// </summary>
        [TechnicalName("errorQueries")]
        DatabaseErrorQueries,

        /// <summary>
        /// Database Query Execution Time
        /// </summary>
        [TechnicalName("queryExecTime")]
        DatabaseQueryExecTime,

        /// <summary>
        /// Database Successful Connections
        /// </summary>
        [TechnicalName("successfulConnections")]
        DatabaseSuccessfulConnections,

        /// <summary>
        /// Database Failed Connections
        /// </summary>
        [TechnicalName("failedConnections")]
        DatabaseFailedConnections,

        /// <summary>
        /// Database Too Many Queries Alarms
        /// </summary>
        [TechnicalName("tooManyQueriesAlarms")]
        DatabaseTooManyQueriesAlarms,

        /// <summary>
        /// Database Too Many Failed Queries Alarms
        /// </summary>
        [TechnicalName("tooManyFailedQueriesAlarms")]
        DatabaseTooManyFailedQueriesAlarms,

        /// <summary>
        /// Database Too Many Error Queries Alarms
        /// </summary>
        [TechnicalName("tooManyErrorQueriesAlarms")]
        DatabaseTooManyErrorQueriesAlarms,

        /// <summary>
        /// Database Query Execution Time Too Long Alarms
        /// </summary>
        [TechnicalName("queryExecTooLongAlarms")]
        DatabaseQueryExecTooLongAlarms,

        /// <summary>
        /// Database No Connection Alarms
        /// </summary>
        [TechnicalName("noConnectionAlarms")]
        DatabaseNoConnectionAlarms,

        /// <summary>
        /// Database Queries Count Threshold
        /// </summary>
        [TechnicalName("queriesCountThreshold")]
        DatabaseQueriesCountThreshold,

        /// <summary>
        /// Database Failed Queries Threshold
        /// </summary>
        [TechnicalName("failedQueriesThreshold")]
        DatabaseFailedQueriesThreshold,

        /// <summary>
        /// Database Error Queries Threshold
        /// </summary>
        [TechnicalName("errorQueriesThreshold")]
        DatabaseErrorQueriesThreshold,

        /// <summary>
        /// Database Query Execution Time Threshold
        /// </summary>
        [TechnicalName("queryExecTimeThreshold")]
        DatabaseQueryExecTimeThreshold,

        /// <summary>
        /// QoS Directions Count
        /// </summary>
        [TechnicalName("qosDirectionsCount")]
        QOSDirectionsCount,

        /// <summary>
        /// QoS Entry Index
        /// </summary>
        [TechnicalName("qosEntryIndex")]
        QOSEntryIndex,

        /// <summary>
        /// QoS Entry Direction
        /// </summary>
        [TechnicalName("qosEntryDirection")]
        QOSEntryDirection,

        /// <summary>
        /// QoS Low ASR Threshold
        /// </summary>
        [TechnicalName("lowASRThreshold")]
        QOSLowASRThreshold,

        /// <summary>
        /// QoS High ASR Treshold
        /// </summary>
        [TechnicalName("highASRThreshold")]
        QOSHighASRThreshold,

        /// <summary>
        /// QoS Current ASR
        /// </summary>
        [TechnicalName("currentASR")]
        QOSCurrentASR,

        /// <summary>
        /// QoS Overall ASR
        /// </summary>
        [TechnicalName("overallASR")]
        QOSOverallASR,

        /// <summary>
        /// QoS Low NER Threshold
        /// </summary>
        [TechnicalName("lowNERThreshold")]
        QOSLowNERTreshold,

        /// <summary>
        /// QoS Current NER
        /// </summary>
        [TechnicalName("currentNER")]
        QOSCurrentNER,

        /// <summary>
        /// QoS Overall NER
        /// </summary>
        [TechnicalName("overallNER")]
        QOSOverallNER,

        /// <summary>
        /// QoS Current Low ASR Alarm Count
        /// </summary>
        [TechnicalName("currentLowASRAlarmCount")]
        QOSCurrentLowASRAlarmCount,

        /// <summary>
        /// QoS All Low ASR Alarm Count
        /// </summary>
        [TechnicalName("overallLowASRAlarmCount")]
        QOSAllLowASRAlarmCount,

        /// <summary>
        /// QoS Current High ASR Alarm Count
        /// </summary>
        [TechnicalName("currentHighASRAlarmCount")]
        QOSCurrentHighASRAlarmCount,

        /// <summary>
        /// QoS Overall High ASR Alarm Count
        /// </summary>
        [TechnicalName("overallHighASRAlarmCount")]
        QOSOverallHighASRAlarmCount,

        /// <summary>
        /// QoS Current Low NER Alarm Count
        /// </summary>
        [TechnicalName("currentLowNERAlarmCount")]
        QOSCurrentLowNERAlarmCount,

        /// <summary>
        /// QoS Overall Low NER Alarm Count
        /// </summary>
        [TechnicalName("overallLowNERAlarmCount")]
        QOSOverallLowNERAlarmCount,

        /// <summary>
        /// Call Counter Incoming Calls
        /// </summary>
        [TechnicalName("incomingCalls")]
        CallCounterIncomingCalls,

        /// <summary>
        /// Call Counter Current Hangup End Cause
        /// </summary>
        [TechnicalName("outgoingCalls")]
        CallCounterOutgoingCalls,

        /// <summary>
        /// Call Counter Current Hangup End Cause
        /// </summary>
        [TechnicalName("currentHangupEndCause")]
        CallCounterCurrentHangupEndCause,

        /// <summary>
        /// Call Counter Current Busy End Cause
        /// </summary>
        [TechnicalName("currentBusyEndCause")]
        CallCounterCurrentBusyEndCause,

        /// <summary>
        /// Call Counter Current Rejected End Cause
        /// </summary>
        [TechnicalName("currentRejectedEndCause")]
        CallCounterCurrentRejectedEndCause,

        /// <summary>
        /// Call Counter Current Cancelled End Cause
        /// </summary>
        [TechnicalName("currentCancelledEndCause")]
        CallCounterCurrentCancelledEndCause,

        /// <summary>
        /// Call Counter Current No Answer End Cause
        /// </summary>
        [TechnicalName("currentNoAnswerEndCause")]
        CallCounterCurrentNoAnswerEndCause,

        /// <summary>
        /// Call Counter Current No Route End Cause
        /// </summary>
        [TechnicalName("currentNoRouteEndCause")]
        CallCounterCurrentNoRouteEndCause,

        /// <summary>
        /// Call Counter Current No Connection End Cause
        /// </summary>
        [TechnicalName("currentNoConnectionEndCause")]
        CallCounterCurrentNoConnectionEndCause,

        /// <summary>
        /// Call Counter Current No Auth End Cause
        /// </summary>
        [TechnicalName("currentNoAuthEndCause")]
        CallCounterCurrentNoAuthEndCause,

        /// <summary>
        /// Call Counter Current Congestion End Cause
        /// </summary>
        [TechnicalName("currentCongestionEndCause")]
        CallCounterCurrentCongestionEndCause,

        /// <summary>
        /// Call Counter Current No Media End Cause
        /// </summary>
        [TechnicalName("currentNoMediaEndCause")]
        CallCounterCurrentNoMediaEndCause,

        /// <summary>
        /// Call Counter Overall Hangup End Cause
        /// </summary>
        [TechnicalName("overallHangupEndCause")]
        CallCounterOverallHangupEndCause,

        /// <summary>
        /// Call Counter Overall Busy End Cause
        /// </summary>
        [TechnicalName("overallBusyEndCause")]
        CallCounterOverallBusyEndCause,

        /// <summary>
        /// Call Counter Overall Rejected End Cause
        /// </summary>
        [TechnicalName("overallRejectedEndCause")]
        CallCounterOverallRejectedEndCause,

        /// <summary>
        /// Call Counter Overall Cancelled End Cause
        /// </summary>
        [TechnicalName("overallCancelledEndCause")]
        CallCounterOverallCancelledEndCause,

        /// <summary>
        /// Call Counter Overall No Answer End Cause
        /// </summary>
        [TechnicalName("overallNoAnswerEndCause")]
        CallCounterOverallNoAnswerEndCause,

        /// <summary>
        /// Call Counter Overall No Route End Cause
        /// </summary>
        [TechnicalName("overallNoRouteEndCause")]
        CallCounterOverallNoRouteEndCause,

        /// <summary>
        /// Call Counter Overall No Connection End Cause
        /// </summary>
        [TechnicalName("overallNoConnectionEndCause")]
        CallCounterOverallNoConnectionEndCause,

        /// <summary>
        /// Call Counter Overall No Auth End Cause
        /// </summary>
        [TechnicalName("overallNoAuthEndCause")]
        CallCounterOverallNoAuthEndCause,

        /// <summary>
        /// Call Counter Overall Congestion End Cause
        /// </summary>
        [TechnicalName("overallCongestionEndCause")]
        CallCounterOverallCongestionEndCause,

        /// <summary>
        /// Call Counter Overall No Media End Cause
        /// </summary>
        [TechnicalName("overallNoMediaEndCause")]
        CallCounterOverallNoMediaEndCause,

        /// <summary>
        /// Connection Info Link Set Count
        /// </summary>
        [TechnicalName("linksetCount")]
        ConnectionInfoLinkSetCount,

        /// <summary>
        /// Connection Info Link Set Index
        /// </summary>
        [TechnicalName("linksetIndex")]
        ConnectionInfoLinkSetIndex,

        /// <summary>
        /// Connection Info Link Set Id
        /// </summary>
        [TechnicalName("linksetID")]
        ConnectionInfoLinkSetId,

        /// <summary>
        /// Connection Info Link Set Type
        /// </summary>
        [TechnicalName("linksetType")]
        ConnectionInfoLinkSetType,

        /// <summary>
        /// Connection Info Link Set Status
        /// </summary>
        [TechnicalName("linksetStatus")]
        ConnectionInfoLinkSetStatus,

        /// <summary>
        /// Connection Info Link Set Down Alarms
        /// </summary>
        [TechnicalName("linksetDownAlarms")]
        ConnectionInfoLinkSetDownAlarms,

        /// <summary>
        /// Connection Info Link Count
        /// </summary>
        [TechnicalName("linkCount")]
        ConnectionInfoLinkCount,

        /// <summary>
        /// Connection Info Link Index
        /// </summary>
        [TechnicalName("linkIndex")]
        ConnectionInfoLinkIndex,

        /// <summary>
        /// Connection Info Link Id
        /// </summary>
        [TechnicalName("linkID")]
        ConnectionInfoLinkId,

        /// <summary>
        /// Connection Info Link Type
        /// </summary>
        [TechnicalName("linkType")]
        ConnectionInfoLinkType,

        /// <summary>
        /// Connection Info Link Status
        /// </summary>
        [TechnicalName("linkStatus")]
        ConnectionInfoLinkStatus,

        /// <summary>
        /// Connection Info Link Down Alarms
        /// </summary>
        [TechnicalName("linkDownAlarms")]
        ConnectionInfoLinkDownAlarms,

        /// <summary>
        /// Connection Info Link Uptime
        /// </summary>
        [TechnicalName("linkUptime")]
        ConnectionInfoLinkUptime,

        /// <summary>
        /// Interfaces Count
        /// </summary>
        [TechnicalName("interfacesCount")]
        InterfacesCount,

        /// <summary>
        /// Interface Index
        /// </summary>
        [TechnicalName("interfaceIndex")]
        InterfaceIndex,

        /// <summary>
        /// Interface Id
        /// </summary>
        [TechnicalName("interfaceID")]
        InterfaceId,

        /// <summary>
        /// Interface Status
        /// </summary>
        [TechnicalName("interfaceStatus")]
        InterfaceStatus,

        /// <summary>
        /// Interface Down Alarms
        /// </summary>
        [TechnicalName("interfaceDownAlarms")]
        InterfaceDownAlarms,

        /// <summary>
        /// Accounts Count
        /// </summary>
        [TechnicalName("accountsCount")]
        AccountsCount,

        /// <summary>
        /// Accounts Index
        /// </summary>
        [TechnicalName("accountIndex")]
        AccountsIndex,

        /// <summary>
        /// Account Id
        /// </summary>
        [TechnicalName("accountID")]
        AccountId,

        /// <summary>
        /// Account Status
        /// </summary>
        [TechnicalName("accountStatus")]
        AccountStatus,

        /// <summary>
        /// Account Protocol
        /// </summary>
        [TechnicalName("accountProtocol")]
        AccountProtocol,

        /// <summary>
        /// Account Username
        /// </summary>
        [TechnicalName("accountUsername")]
        AccountUsername,

        /// <summary>
        /// Active Calls Count
        /// </summary>
        [TechnicalName("activeCallsCount")]
        ActiveCallsCount,

        /// <summary>
        /// Call Entry Index
        /// </summary>
        [TechnicalName("callEntryIndex")]
        CallEntryIndex,

        /// <summary>
        /// Calls Entry Id
        /// </summary>
        [TechnicalName("callEntryID")]
        CallEntryId,

        /// <summary>
        /// Call Entry Status
        /// </summary>
        [TechnicalName("callEntryStatus")]
        CallEntryStatus,

        /// <summary>
        /// Call Entry Caller
        /// </summary>
        [TechnicalName("callEntryCaller")]
        CallEntryCaller,

        /// <summary>
        /// Call Entry Called
        /// </summary>
        [TechnicalName("callEntryCalled")]
        CallEntryCalled,

        /// <summary>
        /// Call Entry Peer Chan
        /// </summary>
        [TechnicalName("callEntryPeerChan")]
        CallEntryPeerChan,

        /// <summary>
        /// Call Entry Duration
        /// </summary>
        [TechnicalName("callEntryDuration")]
        CallEntryDuration,

        /// <summary>
        /// Trunk Count
        /// </summary>
        [TechnicalName("trunksCount")]
        TrunksCount,

        /// <summary>
        /// Trunk Index
        /// </summary>
        [TechnicalName("trunkIndex")]
        TrunkIndex,

        /// <summary>
        /// Trunk Id
        /// </summary>
        [TechnicalName("trunkID")]
        TrunkId,

        /// <summary>
        /// Trunk Type
        /// </summary>
        [TechnicalName("trunkType")]
        TrunkType,

        /// <summary>
        /// Trunk Circuit Count
        /// </summary>
        [TechnicalName("trunkCircuitCount")]
        TrunkCircuitCount,

        /// <summary>
        /// Trunk Current Calls Count
        /// </summary>
        [TechnicalName("trunkCurrentCallsCount")]
        TrunkCurrenCallsCount,

        /// <summary>
        /// Trunk Down Alarms
        /// </summary>
        [TechnicalName("trunkDownAlarms")]
        TrunkDownAlarms,

        /// <summary>
        /// Trunk Circuits Locked
        /// </summary>
        [TechnicalName("trunkCircuitsLocked")]
        TrunkCircuitsLocked,

        /// <summary>
        /// Trunk Circuits Idle
        /// </summary>
        [TechnicalName("trunkCircuitsIdle")]
        TrunkCircuitsIdle,

        /// <summary>
        /// Engine Plugins
        /// </summary>
        [TechnicalName("plugins")]
        EnginePlugins,

        /// <summary>
        /// Engine Handlers
        /// </summary>
        [TechnicalName("handlers")]
        EngineHandlers,

        /// <summary>
        /// Engine Messages
        /// </summary>
        [TechnicalName("messages")]
        EngineMessages,

        /// <summary>
        /// Engine Threads
        /// </summary>
        [TechnicalName("threads")]
        EngineThreads,

        /// <summary>
        /// Engine Workers
        /// </summary>
        [TechnicalName("workers")]
        EngineWorkers,

        /// <summary>
        /// Engine Mutexes
        /// </summary>
        [TechnicalName("mutexes")]
        EngineMutexes,

        /// <summary>
        /// Engine Locks
        /// </summary>
        [TechnicalName("locks")]
        EngineLocks,

        /// <summary>
        /// Engine Semaphores
        /// </summary>
        [TechnicalName("semaphores")]
        EngineSemaphores,

        /// <summary>
        /// Engine Waiting Semaphores
        /// </summary>
        [TechnicalName("waitingSemaphores")]
        EngineWaitingSemaphores,

        /// <summary>
        /// Engine Accept Status
        /// </summary>
        [TechnicalName("acceptStatus")]
        EngineAcceptStatus,

        /// <summary>
        /// Engine Unexpected Restart
        /// </summary>
        [TechnicalName("unexpectedRestart")]
        EngineUnexpectedRestart,

        /// <summary>
        /// Node Run Attempt
        /// </summary>
        [TechnicalName("runAttempt")]
        NodeRunAttempt,

        /// <summary>
        /// Node Name
        /// </summary>
        [TechnicalName("name")]
        NodeName,

        /// <summary>
        /// Node State
        /// </summary>
        [TechnicalName("state")]
        NodeState,

        /// <summary>
        /// Module Count
        /// </summary>
        [TechnicalName("moduleCount")]
        ModuleCount,

        /// <summary>
        /// Module Index
        /// </summary>
        [TechnicalName("moduleIndex")]
        ModuleIndex,

        /// <summary>
        /// Module Name
        /// </summary>
        [TechnicalName("moduleName")]
        ModuleName,

        /// <summary>
        /// Module Type
        /// </summary>
        [TechnicalName("moduleType")]
        ModuleType,

        /// <summary>
        /// Module Extra
        /// </summary>
        [TechnicalName("moduleExtra")]
        ModuleExtra,

        /// <summary>
        /// Request Authentication Requests
        /// </summary>
        [TechnicalName("authenticationRequests")]
        RequestAuthenticationRequests,

        /// <summary>
        /// Request Register Requests
        /// </summary>
        [TechnicalName("registerRequests")]
        RequestRegisterRequests,

        /// <summary>
        /// RTP Directions Count
        /// </summary>
        [TechnicalName("rtpDirectionsCount")]
        RTPDirectionsCount,

        /// <summary>
        /// RTP Entry Index
        /// </summary>
        [TechnicalName("rtpEntryIndex")]
        RTPEntryIndex,

        /// <summary>
        /// RTP Direction
        /// </summary>
        [TechnicalName("rtpDirection")]
        RTPDirection,

        /// <summary>
        /// RTP No Audio Count
        /// </summary>
        [TechnicalName("noAudioCounter")]
        RTPNoAudioCounter,

        /// <summary>
        /// RTP Lost Audio Counter
        /// </summary>
        [TechnicalName("lostAudioCounter")]
        RTPLostAudioCounter,

        /// <summary>
        /// RTP Packets Lost
        /// </summary>
        [TechnicalName("packetsLost")]
        RTPPacketsLost,

        /// <summary>
        /// RTP Sync Lost
        /// </summary>
        [TechnicalName("syncLost")]
        RTPSyncLost,

        /// <summary>
        /// RTP Sequence Number Lost
        /// </summary>
        [TechnicalName("sequenceNumberLost")]
        RTPSequenceNumberLost,

        /// <summary>
        /// RTP Wrong SRC
        /// </summary>
        [TechnicalName("wrongSRC")]
        RTPWrongSRC,

        /// <summary>
        /// RTP Wrong SSRC
        /// </summary>
        [TechnicalName("wrongSSRC")]
        RTPWrongSSRC,

        /// <summary>
        /// SIP Transactions Timed Out
        /// </summary>
        [TechnicalName("transactionsTimedOut")]
        SIPTransactionsTimedOut,

        /// <summary>
        /// SIP Failed Auths
        /// </summary>
        [TechnicalName("failedAuths")]
        SIPFailedAuths,

        /// <summary>
        /// SIP Bytes Timed Out
        /// </summary>
        [TechnicalName("byesTimedOut")]
        SIPByesTimedOut,

        /// <summary>
        /// MGCP Transactions Timed Out
        /// </summary>
        [TechnicalName("mgcpTransactionsTimedOut")]
        MGCPTransactionsTimedOut,

        /// <summary>
        /// MGCP Delete Transactions Timed Out
        /// </summary>
        [TechnicalName("deleteTransactionsTimedOut")]
        MGCPDeleteTransactionsTimedOut,
        
        /// <summary>
        /// YATE CPU kernel-space load settings
        /// </summary>
        [TechnicalName("kernelLoad")]
        KernelLoad,

        /// <summary>
        /// YATE CPU user-space load settings
        /// </summary>
        [TechnicalName("userLoad")]
        UserLoad,

        /// <summary>
        /// YATE CPU load settings
        /// </summary>
        [TechnicalName("totalLoad")]
        TotalLoad,

        /// <summary>
        /// System CPU load settings
        /// </summary>
        [TechnicalName("systemLoad")]
        SystemLoad
    }
}