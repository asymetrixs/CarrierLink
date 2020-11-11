namespace CarrierLink.Controller.Engine.Workers
{
    /// <summary>
    /// This class handles configuration messages
    /// </summary>
    internal class ConfigurationMessageWorker : AbstractQueryWorker
    {
        #region Constructor

        /// <summary>
        /// Initializes a new instance of the <see cref="ConfigurationMessageWorker"/> class
        /// </summary>
        /// <param name="section">Section to query</param>
        /// <param name="key">Keys value to retrieve</param>
        internal ConfigurationMessageWorker(string section, string key)
            : base()
        {
            this.Section = section;
            this.Key = key;
        }

        #endregion Constructor

        #region Properties

        /// <summary>
        /// Gets Key
        /// </summary>
        internal string Key { get; private set; }

        /// <summary>
        /// Gets section to query
        /// </summary>
        internal string Section { get; private set; }

        #endregion Properties

        #region Methods

        /// <summary>
        /// Returns actual yate command
        /// </summary>
        /// <returns>Yate message</returns>
        internal override string Query() => $"setlocal:config.{Section}.{Key}:";

        /// <summary>
        /// Used to set yates answer from another thread. Signals internally to continue requesting thread.
        /// </summary>
        /// <param name="successful">True if query was successful</param>
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