namespace CarrierLink.Controller.Yate
{
    using Utilities;

    /// <summary>
    /// Engine parameters supported by Yate
    /// </summary>
    public enum EngineParameter
    {
        /// <summary>
        /// Engine Version
        /// </summary>
        [TechnicalName("engine.version")]
        Version,

        /// <summary>
        /// Engine Release
        /// </summary>
        [TechnicalName("engine.release")]
        Release,

        /// <summary>
        /// Engine Nodename
        /// </summary>
        [TechnicalName("engine.nodename")]
        NodeName,

        /// <summary>
        /// Engine Run Id
        /// </summary>
        [TechnicalName("engine.runid")]
        RunId,

        /// <summary>
        /// Engine Configname
        /// </summary>
        [TechnicalName("engine.configname")]
        ConfigName,

        /// <summary>
        /// Engine Shared Path
        /// </summary>
        [TechnicalName("engine.sharedpath")]
        SharedPath,

        /// <summary>
        /// Engine Config Path
        /// </summary>
        [TechnicalName("engine.configpath")]
        ConfigPath,

        /// <summary>
        /// Engine Config Suffix
        /// </summary>
        [TechnicalName("engine.cfgsuffix")]
        CfgSuffix,

        /// <summary>
        /// Engine Module Path
        /// </summary>
        [TechnicalName("engine.modulepath")]
        ModulePath,

        /// <summary>
        /// Engine Module Suffix
        /// </summary>
        [TechnicalName("engine.modsuffix")]
        ModSuffix,

        /// <summary>
        /// Engine Log File
        /// </summary>
        [TechnicalName("engine.logfile")]
        LogFile,

        /// <summary>
        /// Engine Client Mode
        /// </summary>
        [TechnicalName("engine.clientmode")]
        ClientMode,

        /// <summary>
        /// Engine Supervised
        /// </summary>
        [TechnicalName("engine.supervised")]
        Supervised,

        /// <summary>
        /// Engine Maximal Workers
        /// </summary>
        [TechnicalName("engine.maxworkers")]
        MaxWorkers
    }
}