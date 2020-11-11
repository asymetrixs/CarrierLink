namespace CarrierLink.Controller.Engine.Workers
{
    using Caching;
    using Yate;

    /// <summary>
    /// This class queries Yate for engine parameters
    /// </summary>
    internal class EngineParameterWorker : AbstractQueryWorker
    {
        #region Constructor

        /// <summary>
        /// Initializes a new instance of the <see cref="EngineParameterWorker"/> class
        /// </summary>
        /// <param name="info">Requested information</param>
        internal EngineParameterWorker(EngineParameter info)
            : base()
        {
            this.Info = info;
        }

        #endregion Constructor

        #region Properties

        /// <summary>
        /// Gets requested parameter
        /// </summary>
        internal EngineParameter Info { get; private set; }

        #endregion Properties

        #region Methods

        /// <summary>
        /// Returns actual yate command
        /// </summary>
        /// <returns>Returns Yate message</returns>
        internal override string Query() => $"setlocal:{Pool.EngineParameters.ToString(this.Info)}:";

        /// <summary>
        /// Used to set yates answer from another thread. Signals internally to continue requesting thread.
        /// </summary>
        /// <param name="successful">True if result was received from yate</param>
        /// <param name="result">Result of query</param>
        internal override void SetResult(bool successful, string result)
        {
            this.Successful = successful;
            this.Result = result;
            this.Waiter.Release();
        }

        #endregion Methods
    }
}