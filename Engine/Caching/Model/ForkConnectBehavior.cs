namespace CarrierLink.Controller.Engine.Caching.Model
{
    using Utilities;

    /// <summary>
    /// Specifies the connection behavior when forking
    /// </summary>
    internal enum ForkConnectBehavior
    {
        /// <summary>
        /// Connect to gateways consecutively without disconnecting the previous gateway connection
        /// </summary>
        [TechnicalName("|next=")]
        Next = 1,

        /// <summary>
        /// Connect to gateways consecutively but disconnect the previous gateway connection prior to open a new one
        /// </summary>
        [TechnicalName("|drop=")]
        Drop = 2,

        /// <summary>
        /// Connect to all gateways simultaneously
        /// </summary>
        [TechnicalName("")]
        Simultaneously = 3,

        /// <summary>
        /// Connect to all gateways consecutively
        /// </summary>
        [TechnicalName("|")]
        Automatically = 4
    }
}
