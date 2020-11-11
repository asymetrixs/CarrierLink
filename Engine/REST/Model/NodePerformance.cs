namespace CarrierLink.Controller.Engine.REST.Model
{
    using System;

    /// <summary>
    /// Class to provide node performance information
    /// </summary>
    public class NodePerformance
    {
        #region Properties

        /// <summary>
        /// Node Id
        /// </summary>
        internal int NodeId { get; set; }

        /// <summary>
        /// Last engine.time message
        /// </summary>
        internal DateTime LastEngineTime { get; set; }

        /// <summary>
        /// Gets date data was collected
        /// </summary>
        internal DateTime RecordedOn { get; set; }
        
        /// <summary>
        /// Gets CPU count
        /// </summary>
        internal int CpuCount { get; set; }

        /// <summary>
        /// Gets CPU usage by user in percent
        /// </summary>
        internal decimal CpuUser { get; set; }

        /// <summary>
        /// Gets CPU usage by nice in percent
        /// </summary>
        internal decimal CpuNice { get; set; }

        /// <summary>
        /// Gets CPU usage by system in percent
        /// </summary>
        internal decimal CpuSystem { get; set; }

        /// <summary>
        /// Gets CPU idling in percent
        /// </summary>
        internal decimal CpuIdle { get; set; }

        /// <summary>
        /// Gets CPU waiting in percent
        /// </summary>
        internal decimal CpuIoWait { get; set; }

        /// <summary>
        /// Gets CPU usage by hard irq in percent
        /// </summary>
        internal decimal CpuHardIrq { get; set; }

        /// <summary>
        /// Gets CPU usage by soft irq in percent
        /// </summary>
        internal decimal CpuSoftIrq { get; set; }

        /// <summary>
        /// Gets total memory in KiB
        /// </summary>
        internal int MemoryTotal { get; set; }

        /// <summary>
        /// Gets used memory in KiB
        /// </summary>
        internal int MemoryUsed { get; set; }

        /// <summary>
        /// Gets free memory in KiB
        /// </summary>
        internal int MemoryFree { get; set; }

        /// <summary>
        /// Gets total swap in KiB
        /// </summary>
        internal int SwapTotal { get; set; }

        /// <summary>
        /// Gets used swap in KiB
        /// </summary>
        internal int SwapUsed { get; set; }

        /// <summary>
        /// Gets free swap in KiB
        /// </summary>
        internal int SwapFree { get; set; }

        /// <summary>
        /// Gets value indicating how many percent of the call.route messages is being
        /// </summary>
        internal int ProcessingPercentage { get; set; }

        #endregion
    }
}
