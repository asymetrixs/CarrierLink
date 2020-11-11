namespace CarrierLink.Controller.Engine.REST.Model
{
    using CarrierLink.Controller.Utilities;
    using System;
    using System.Collections.Generic;

    /// <summary>
    /// Class to provide controller performance information
    /// </summary>
    public class ControllerPerformance
    {
        #region Properties

        /// <summary>
        /// List of supplied arguments during start
        /// </summary>
        internal static ICollection<string> ArgumentList { get; set; }

        /// <summary>
        /// Process Id
        /// </summary>
        internal static int Id { get; set; }

        /// <summary>
        /// Machine name
        /// </summary>
        internal static string MachineName { get; set; }

        /// <summary>
        /// User name running this process
        /// </summary>
        internal static string UserName { get; set; }

        /// <summary>
        /// Process start time
        /// </summary>
        internal static DateTime StartTime { get; set; }

        /// <summary>
        /// Amount of processors
        /// </summary>
        internal static int ProcessorCount { get; set; }

        /// <summary>
        /// Minimal working set
        /// </summary>
        internal long MinWorkingSet { get; set; } = -1;

        /// <summary>
        /// Maximal working set
        /// </summary>
        internal long MaxWorkingSet { get; set; } = -1;

        /// <summary>
        /// Process priority
        /// </summary>
        internal string PriorityClass { get; set; } = "unknown";

        /// <summary>
        /// Amount of threads belonging to this process
        /// </summary>
        internal int Threads { get; set; } = -1;

        /// <summary>
        /// Consumed processor time in system level
        /// </summary>
        internal TimeSpan TotalProcessorTime { get; set; } = default(TimeSpan);

        /// <summary>
        /// Consumed processor time in user level
        /// </summary>
        internal TimeSpan UserProcessorTime { get; set; } = default(TimeSpan);

        /// <summary>
        /// Non paged system memory size
        /// </summary>
        internal long NonpagedSystemMemorySize { get; set; } = -1;

        /// <summary>
        /// Paged memory size
        /// </summary>
        internal long PagedMemorySize { get; set; } = -1;

        /// <summary>
        /// Paged system memory size
        /// </summary>
        internal long PagedSystemMemorySize { get; set; } = -1;

        /// <summary>
        /// Peak paged memory size
        /// </summary>
        internal long PeakPagedMemorySize { get; set; } = -1;

        /// <summary>
        /// Peak virtual memory size
        /// </summary>
        internal long PeakVirtualMemorySize { get; set; } = -1;

        /// <summary>
        /// Peak working set
        /// </summary>
        internal long PeakWorkingSet { get; set; } = -1;

        /// <summary>
        /// Private memory size
        /// </summary>
        internal long PrivateMemorySize { get; set; } = -1;

        /// <summary>
        /// Working set
        /// </summary>
        internal long WorkingSet { get; set; } = -1;

        /// <summary>
        /// Virtual memory size
        /// </summary>
        internal long VirtualMemorySize { get; set; } = -1;

        /// <summary>
        /// Gets or sets the period of time of values
        /// </summary>
        internal Interval Time { get; set; }

        #endregion Properties
    }
}