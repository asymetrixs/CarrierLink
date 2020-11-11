namespace CarrierLink.Controller.Yate.Model
{
    using System;
    using System.Globalization;

    /// <summary>
    /// This class provides information about CPU load information
    /// </summary>
    public class PerformanceInformation
    {
        #region Constructor

        /// <summary>
        /// Initializes a new instance of the <see cref="PerformanceInformation"/> class.
        /// </summary>
        /// <param name="cpuCount">See <see cref="CpuCount"/></param>
        /// <param name="cpuUser">See <see cref="CpuUser"/></param>
        /// <param name="cpuNice">See <see cref="CpuNice"/></param>
        /// <param name="cpuSystem">See <see cref="CpuSystem"/></param>
        /// <param name="cpuIdle">See <see cref="CpuIdle"/></param>
        /// <param name="cpuIoWait">See <see cref="CpuIoWait"/></param>
        /// <param name="cpuHardIrq">See <see cref="CpuHardIrq"/></param>
        /// <param name="cpuSoftIrq">See <see cref="CpuSoftIrq"/></param>
        /// <param name="memoryTotal">See <see cref="MemoryTotal"/></param>
        /// <param name="memoryUsed">See <see cref="MemoryUsed"/></param>
        /// <param name="memoryFree">See <see cref="MemoryFree"/></param>
        /// <param name="swapTotal">See <see cref="SwapTotal"/></param>
        /// <param name="swapUsed">See <see cref="SwapUsed"/></param>
        /// <param name="swapFree">See <see cref="SwapFree"/></param>
        /// <param name="processingPercentage">See <see cref="ProcessingPercentage"/></param>
        private PerformanceInformation(int cpuCount, decimal cpuUser, decimal cpuNice, decimal cpuSystem, decimal cpuIdle, decimal cpuIoWait,
            decimal cpuHardIrq, decimal cpuSoftIrq, int memoryTotal, int memoryUsed, int memoryFree, int swapTotal, int swapUsed, int swapFree,
            int processingPercentage)
        {
            this.RecordedOn = DateTime.UtcNow;

            this.CpuCount = cpuCount;
            this.CpuUser = cpuUser;
            this.CpuNice = cpuNice;
            this.CpuSystem = cpuSystem;
            this.CpuIdle = cpuIdle;
            this.CpuIoWait = cpuIoWait;
            this.CpuHardIrq = cpuHardIrq;
            this.CpuSoftIrq = cpuSoftIrq;
            this.MemoryTotal = memoryTotal;
            this.MemoryUsed = memoryUsed;
            this.MemoryFree = memoryFree;
            this.SwapTotal = swapTotal;
            this.SwapUsed = swapUsed;
            this.SwapFree = swapFree;

            this.ProcessingPercentage = processingPercentage;
        }

        /// <summary>
        /// Private constructor used when errors occur
        /// </summary>
        /// <param name="processingPercentage">See <see cref="ProcessingPercentage"/></param>
        private PerformanceInformation(int processingPercentage)
        {
            this.RecordedOn = DateTime.UtcNow;

            this.CpuCount = -1;
            this.CpuUser = -1;
            this.CpuNice = -1;
            this.CpuSystem = -1;
            this.CpuIdle = -1;
            this.CpuIoWait = -1;
            this.CpuHardIrq = -1;
            this.CpuSoftIrq = -1;
            this.MemoryTotal = -1;
            this.MemoryUsed = -1;
            this.MemoryFree = -1;
            this.SwapTotal = -1;
            this.SwapUsed = -1;
            this.SwapFree = -1;

            this.ProcessingPercentage = processingPercentage;
        }

        #endregion

        #region Properties

        /// <summary>
        /// Gets date data was collected
        /// </summary>
        public DateTime RecordedOn { get; private set; }

        /// <summary>
        /// Gets CPU count
        /// </summary>
        public int CpuCount { get; private set; }

        /// <summary>
        /// Gets CPU usage by user in percent
        /// </summary>
        public decimal CpuUser { get; private set; }

        /// <summary>
        /// Gets CPU usage by nice in percent
        /// </summary>
        public decimal CpuNice { get; private set; }

        /// <summary>
        /// Gets CPU usage by system in percent
        /// </summary>
        public decimal CpuSystem { get; private set; }

        /// <summary>
        /// Gets CPU idling in percent
        /// </summary>
        public decimal CpuIdle { get; private set; }

        /// <summary>
        /// Gets CPU waiting in percent
        /// </summary>
        public decimal CpuIoWait { get; private set; }

        /// <summary>
        /// Gets CPU usage by hard irq in percent
        /// </summary>
        public decimal CpuHardIrq { get; private set; }

        /// <summary>
        /// Gets CPU usage by soft irq in percent
        /// </summary>
        public decimal CpuSoftIrq { get; private set; }

        /// <summary>
        /// Gets total memory in KiB
        /// </summary>
        public int MemoryTotal { get; private set; }

        /// <summary>
        /// Gets used memory in KiB
        /// </summary>
        public int MemoryUsed { get; private set; }

        /// <summary>
        /// Gets free memory in KiB
        /// </summary>
        public int MemoryFree { get; private set; }

        /// <summary>
        /// Gets total swap in KiB
        /// </summary>
        public int SwapTotal { get; private set; }

        /// <summary>
        /// Gets used swap in KiB
        /// </summary>
        public int SwapUsed { get; private set; }

        /// <summary>
        /// Gets free swap in KiB
        /// </summary>
        public int SwapFree { get; private set; }

        /// <summary>
        /// Gets value indicating how many percent of the call.route messages is being
        /// </summary>
        public int ProcessingPercentage { get; private set; }

        /// <summary>
        /// Gets total Cpu usage
        /// </summary>
        public decimal CpuUsage
        {
            get
            {
                return this.CpuHardIrq + this.CpuIoWait + this.CpuNice + this.CpuSoftIrq + this.CpuSystem + this.CpuUser;
            }
        }

        #endregion

        #region Functions

        /// <summary>
        /// Parses performance information
        /// </summary>
        /// <param name="result"></param>
        /// <param name="processingPercentage"></param>
        /// <returns></returns>
        public static PerformanceInformation Parse(string result, int processingPercentage)
        {
            PerformanceInformation perfInfo = null;

            try
            {
                var data = result.Split(':');

                /** Data
                 *  ccount = '6'
                 *  cuser = '1.5'
                 *  cnice = '5.6'
                 *  csystem = '29'
                 *  cidle = '31'
                 *  ciowait = '0'
                 *  chardirq = '0'
                 *  csoftirq = '1'
                 *  mtotal = '984'
                 *  mused = '711'
                 *  mfree = '272'
                 *  stotal = '1019'
                 *  sused = '0'
                 *  sfree = '1019'
                 *  */

                var cultureInfo = new CultureInfo("en-US");

                perfInfo = new PerformanceInformation(
                    cpuCount: int.Parse(data[0].Split('=')[1]),
                    cpuUser: decimal.Parse(data[1].Split('=')[1], cultureInfo),
                    cpuNice: decimal.Parse(data[2].Split('=')[1], cultureInfo),
                    cpuSystem: decimal.Parse(data[3].Split('=')[1], cultureInfo),
                    cpuIdle: decimal.Parse(data[4].Split('=')[1], cultureInfo),
                    cpuIoWait: decimal.Parse(data[5].Split('=')[1], cultureInfo),
                    cpuHardIrq: decimal.Parse(data[6].Split('=')[1], cultureInfo),
                    cpuSoftIrq: decimal.Parse(data[7].Split('=')[1], cultureInfo),
                    memoryTotal: int.Parse(data[8].Split('=')[1]),
                    memoryUsed: int.Parse(data[9].Split('=')[1]),
                    memoryFree: int.Parse(data[10].Split('=')[1]),
                    swapTotal: int.Parse(data[11].Split('=')[1]),
                    swapUsed: int.Parse(data[12].Split('=')[1]),
                    swapFree: int.Parse(data[13].Split('=')[1]),
                    processingPercentage: processingPercentage
                    );
            }
            catch
            {
                perfInfo = new PerformanceInformation(processingPercentage);
            }

            return perfInfo;
        }

        #endregion
    }
}
