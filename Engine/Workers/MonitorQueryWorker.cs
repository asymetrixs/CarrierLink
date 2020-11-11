namespace CarrierLink.Controller.Engine.Workers
{
    using Caching;
    using System.Runtime.CompilerServices;
    using Yate;

    /// <summary>
    /// This class handles monitoring messages from Yate
    /// </summary>
    internal class MonitorQueryWorker : AbstractQueryWorker
    {
        #region Constructor

        /// <summary>
        /// Initializes a new instance of the <see cref="MonitorQueryWorker"/> class
        /// </summary>
        /// <param name="info">Requested information</param>
        internal MonitorQueryWorker(MonitorParameter info)
            : base()
        {
            this.Info = info;
        }

        #endregion Constructor

        #region Properties

        /// <summary>
        /// Gets requested parameter
        /// </summary>
        internal MonitorParameter Info { get; private set; }

        #endregion Properties

        #region Methods

        /// <summary>
        /// Returns actual yate command
        /// </summary>
        /// <returns>Returns message for Yate</returns>
        [MethodImpl(MethodImplOptions.AggressiveInlining)]
        internal override string Query() => $"message:cl{Time}:{Time}:monitor.query::name={Pool.MonitorParameters.ToString(this.Info)}";

        /// <summary>
        /// Used to set yates answer from another thread. Signals internally to continue requesting thread.
        /// </summary>
        /// <param name="successful">Indicates if query was successful</param>
        /// <param name="result">Result of query</param>
        [MethodImpl(MethodImplOptions.AggressiveInlining)]
        internal override void SetResult(bool successful, string result)
        {
            this.Successful = successful;
            this.Result = result;
            this.Waiter.Release();
        }

        #endregion Methods
    }
}