namespace CarrierLink.Controller.Utilities
{
    /// <summary>
    /// This Enum describes the time period of values used to calculate results
    /// </summary>
    public enum Interval
    {
        /// <summary>
        /// Latest value
        /// </summary>
        Latest = 0,

        /// <summary>
        /// 1 minute average
        /// </summary>
        Average1Min = 1,

        /// <summary>
        /// 5 minutes average
        /// </summary>
        Average5Min = 5,

        /// <summary>
        /// 15 minutes average
        /// </summary>
        Average15Min = 15
    }
}
