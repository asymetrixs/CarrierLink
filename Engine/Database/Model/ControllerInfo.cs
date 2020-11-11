namespace CarrierLink.Controller.Engine.Database.Model
{
    /// <summary>
    /// This class provides controller information
    /// </summary>
    public class ControllerInfo
    {
        #region Constructor

        /// <summary>
        /// Initializes a new instance of the <see cref="ControllerInfo"/> class.
        /// </summary>
        /// <param name="cpu1m">See <see cref="Cpu1mThreshold"/></param>
        /// <param name="cpu5m">See <see cref="Cpu5mThreshold"/></param>
        internal ControllerInfo(int cpu1m, int cpu5m)
        {
            this.Cpu1mThreshold = cpu1m;
            this.Cpu5mThreshold = cpu5m;
        }

        #endregion

        #region Properties

        /// <summary>
        /// Cpu usage threshold for current and 1m period
        /// </summary>
        internal int Cpu1mThreshold { get; }

        /// <summary>
        /// Cpu usage threshold for 5m period
        /// </summary>
        internal int Cpu5mThreshold { get; }

        #endregion
    }
}
