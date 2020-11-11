namespace CarrierLink.Controller.Engine.Workers
{
    using System;
    using System.Threading;

    /// <summary>
    /// This class describes query functionality for workers
    /// </summary>
    internal abstract class AbstractQueryWorker
    {
        #region Constructor

        /// <summary>
        /// Initializes a new instance of the inheriting class
        /// </summary>
        internal AbstractQueryWorker()
        {
            this.Time = (int)(DateTime.UtcNow - new DateTime(1970, 1, 1)).TotalSeconds;
            this.Waiter = new SemaphoreSlim(initialCount: 0, maxCount: 1);
        }

        #endregion

        #region Properties

        /// <summary>
        /// Gets yates answer to requested parameter
        /// </summary>
        public string Result { get; protected set; }

        /// <summary>
        /// Gets or sets a value indicating whether request was successful or not
        /// </summary>
        public bool Successful { get; protected set; }

        /// <summary>
        /// Unix time when message is send
        /// </summary>
        public int Time { get; private set; }

        /// <summary>
        /// Gets waiter to pause thread while waiting for result
        /// </summary>
        public SemaphoreSlim Waiter { get; private set; }

        #endregion

        #region Methods

        /// <summary>
        /// Returns actual yate command
        /// </summary>
        /// <returns>Yate message</returns>
        internal abstract string Query();

        /// <summary>
        /// Used to set yates answer from another thread. Signals internally to continue requesting thread.
        /// </summary>
        /// <param name="successful">True if query was successful</param>
        /// <param name="result">Result of query</param>
        internal abstract void SetResult(bool successful, string result);

        #endregion
    }
}
