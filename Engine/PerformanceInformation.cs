namespace CarrierLink.Controller.Engine
{
    using NLog;
    using System;
    using System.Collections.Generic;
    using System.Diagnostics;
    using System.Linq;
    using Utilities;

    /// <summary>
    /// This class provides information about the system load
    /// </summary>
    internal class PerformanceInformation
    {
        #region Fields

        /// <summary>
        /// Stores performance information
        /// </summary>
        private static List<PerformanceInformation> performanceInformation;

        /// <summary>
        /// Logger
        /// </summary>
        private static Logger logger = LogManager.GetCurrentClassLogger();

        #endregion Fields

        #region Constructor

        /// <summary>
        /// Static constructor
        /// </summary>
        static PerformanceInformation()
        {
            performanceInformation = new List<PerformanceInformation>();

            ArgumentList = Process.GetCurrentProcess().StartInfo.ArgumentList;
            Id = Process.GetCurrentProcess().Id;
            MachineName = Process.GetCurrentProcess().MachineName;
            UserName = Process.GetCurrentProcess().StartInfo.UserName;
            StartTime = Process.GetCurrentProcess().StartTime;
            ProcessorCount = Environment.ProcessorCount;
        }

        /// <summary>
        /// Initializes a new instance of the <see cref="PerformanceInformation"/> class
        /// </summary>
        private PerformanceInformation()
        {
            this.MinWorkingSet = Process.GetCurrentProcess().MinWorkingSet.ToInt64();
            this.MaxWorkingSet = Process.GetCurrentProcess().MaxWorkingSet.ToInt64();
            this.PriorityClass = Process.GetCurrentProcess().PriorityClass.ToString();

            this.Threads = Process.GetCurrentProcess().Threads.Count;
            this.TotalProcessorTime = Process.GetCurrentProcess().TotalProcessorTime;
            this.UserProcessorTime = Process.GetCurrentProcess().UserProcessorTime;

            this.NonpagedSystemMemorySize = Process.GetCurrentProcess().NonpagedSystemMemorySize64;
            this.PagedMemorySize = Process.GetCurrentProcess().PagedMemorySize64;
            this.PagedSystemMemorySize = Process.GetCurrentProcess().PagedSystemMemorySize64;
            this.PeakPagedMemorySize = Process.GetCurrentProcess().PeakPagedMemorySize64;
            this.PeakVirtualMemorySize = Process.GetCurrentProcess().PeakVirtualMemorySize64;
            this.PeakWorkingSet = Process.GetCurrentProcess().PeakWorkingSet64;
            this.PrivateMemorySize = Process.GetCurrentProcess().PrivateMemorySize64;
            this.WorkingSet = Process.GetCurrentProcess().WorkingSet64;
            this.VirtualMemorySize = Process.GetCurrentProcess().VirtualMemorySize64;

            this.RecordedOn = DateTime.UtcNow;
        }

        /// <summary>
        /// Initialiyes a new instance of the <see cref="PerformanceInformation"/> class
        /// </summary>
        /// <param name="minWorkingSet"></param>
        /// <param name="maxWorkingSet"></param>
        /// <param name="threads"></param>
        /// <param name="nonpagedSystemMemorySize"></param>
        /// <param name="pagedMemorySize"></param>
        /// <param name="peakPagedMemorySize"></param>
        /// <param name="peakVirtualMemorySize"></param>
        /// <param name="peakWorkingSet"></param>
        /// <param name="privateMemorySize"></param>
        /// <param name="workingSet"></param>
        /// <param name="virtualMemorySize"></param>
        private PerformanceInformation(long minWorkingSet, long maxWorkingSet, int threads, long nonpagedSystemMemorySize, long pagedMemorySize,
            long peakPagedMemorySize, long peakVirtualMemorySize, long peakWorkingSet, long privateMemorySize, long workingSet, long virtualMemorySize)
        {
            this.MinWorkingSet = minWorkingSet;
            this.MaxWorkingSet = maxWorkingSet;
            this.Threads = threads;
            this.NonpagedSystemMemorySize = nonpagedSystemMemorySize;
            this.PagedMemorySize = pagedMemorySize;
            this.PeakVirtualMemorySize = peakVirtualMemorySize;
            this.PeakWorkingSet = peakWorkingSet;
            this.PrivateMemorySize = privateMemorySize;
            this.WorkingSet = workingSet;
            this.VirtualMemorySize = virtualMemorySize;
            this.TotalProcessorTime = Process.GetCurrentProcess().TotalProcessorTime;
            this.UserProcessorTime = Process.GetCurrentProcess().UserProcessorTime;
        }

        #endregion

        #region Properties

        /// <summary>
        /// List of supplied arguments during start
        /// </summary>
        public static ICollection<string> ArgumentList { get; }

        /// <summary>
        /// Process Id
        /// </summary>
        public static int Id { get; }

        /// <summary>
        /// Machine name
        /// </summary>
        public static string MachineName { get; }

        /// <summary>
        /// User name running this process
        /// </summary>
        public static string UserName { get; }

        /// <summary>
        /// Process start time
        /// </summary>
        public static DateTime StartTime { get; }

        /// <summary>
        /// Amount of processors
        /// </summary>
        public static int ProcessorCount { get; }

        /// <summary>
        /// Minimal working set
        /// </summary>
        public long MinWorkingSet { get; private set; } = -1;

        /// <summary>
        /// Maximal working set
        /// </summary>
        public long MaxWorkingSet { get; private set; } = -1;

        /// <summary>
        /// Process priority
        /// </summary>
        public string PriorityClass { get; private set; } = "unknown";

        /// <summary>
        /// Amount of threads belonging to this process
        /// </summary>
        public int Threads { get; private set; } = -1;

        /// <summary>
        /// Consumed processor time in system level
        /// </summary>
        public TimeSpan TotalProcessorTime { get; private set; } = default(TimeSpan);

        /// <summary>
        /// Consumed processor time in user level
        /// </summary>
        public TimeSpan UserProcessorTime { get; private set; } = default(TimeSpan);

        /// <summary>
        /// Non paged system memory size
        /// </summary>
        public long NonpagedSystemMemorySize { get; private set; } = -1;

        /// <summary>
        /// Paged memory size
        /// </summary>
        public long PagedMemorySize { get; private set; } = -1;

        /// <summary>
        /// Paged system memory size
        /// </summary>
        public long PagedSystemMemorySize { get; private set; } = -1;

        /// <summary>
        /// Peak paged memory size
        /// </summary>
        public long PeakPagedMemorySize { get; private set; } = -1;

        /// <summary>
        /// Peak virtual memory size
        /// </summary>
        public long PeakVirtualMemorySize { get; private set; } = -1;

        /// <summary>
        /// Peak working set
        /// </summary>
        public long PeakWorkingSet { get; private set; } = -1;

        /// <summary>
        /// Private memory size
        /// </summary>
        public long PrivateMemorySize { get; private set; } = -1;

        /// <summary>
        /// Working set
        /// </summary>
        public long WorkingSet { get; private set; } = -1;

        /// <summary>
        /// Virtual memory size
        /// </summary>
        public long VirtualMemorySize { get; private set; } = -1;

        /// <summary>
        /// Recording time
        /// </summary>
        internal DateTime RecordedOn { get; private set; }

        /// <summary>
        /// Gets a value indicating if the current system load is critical
        /// </summary>
        internal static bool LoadIsCritical { get; private set; }

        #endregion Properties

        #region Functions

        /// <summary>
        /// Returns the average performance
        /// </summary>
        /// <param name="interval">Interval to take into account</param>
        /// <returns>Average System Load</returns>
        internal static PerformanceInformation GetPerformanceInformation(Interval interval)
        {
            PerformanceInformation result;

            if (interval == Interval.Latest)
            {
                result = performanceInformation.OrderByDescending(li => li.RecordedOn).FirstOrDefault();
            }
            else
            {
                result = performanceInformation
                            .Where(pI => pI.RecordedOn >= DateTime.UtcNow.AddMinutes(-(int)interval))
                            .GroupBy(g => 1)
                            .Select(g => new PerformanceInformation((long)g.Average(f => f.MinWorkingSet),
                                    (long)g.Average(f => f.MaxWorkingSet),
                                    (int)g.Average(f => f.Threads),
                                    (long)g.Average(f => f.NonpagedSystemMemorySize),
                                    (long)g.Average(f => f.PagedMemorySize),
                                    (long)g.Average(f => f.PeakPagedMemorySize),
                                    (long)g.Average(f => f.PeakVirtualMemorySize),
                                    (long)g.Average(f => f.PeakWorkingSet),
                                    (long)g.Average(f => f.PrivateMemorySize),
                                    (long)g.Average(f => f.WorkingSet),
                                    (long)g.Average(f => f.VirtualMemorySize)
                                )).FirstOrDefault();
            }

            if (result == null)
            {
                result = new PerformanceInformation();
            }

            return result;
        }

        #endregion
    }
}