namespace CarrierLink.Controller.Engine.Workers.Model
{
    /// <summary>
    /// This class holds simple route parameter
    /// </summary>
    internal abstract class Route
    {
        #region Properties

        /// <summary>
        /// Gets or sets Default Yate Field: callto.X
        /// </summary>
        internal string YTARGET { get; set; }

        #endregion
    }
}
