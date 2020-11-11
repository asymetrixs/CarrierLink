namespace CarrierLink.Controller.Engine.Workers
{
    using Caching;
    using System.Runtime.CompilerServices;
    using Utilities;

    /// <summary>
    /// This class handles monitoring messages from Yate
    /// </summary>
    internal class CarrierLinkWorker : AbstractQueryWorker
    {
        #region Constructor

        /// <summary>
        /// Initializes a new instance of the <see cref="CarrierLinkWorker"/> class
        /// </summary>
        /// <param name="info">Requested information</param>
        internal CarrierLinkWorker(CarrierLinkParameter info)
            : base()
        {
            this.Info = info;
        }

        #endregion Constructor

        #region Properties

        /// <summary>
        /// Gets requested parameter
        /// </summary>
        internal CarrierLinkParameter Info { get; private set; }

        #endregion Properties

        #region Methods

        /// <summary>
        /// Returns actual yate command
        /// </summary>
        /// <returns>Returns message for Yate</returns>
        [MethodImpl(MethodImplOptions.AggressiveInlining)]
        internal override string Query() => $"message:cl{Time}:{Time}:cali.node::name={Pool.CarrierLinkParameters.ToString(this.Info)}";

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
