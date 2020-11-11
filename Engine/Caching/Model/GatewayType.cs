namespace CarrierLink.Controller.Engine.Caching.Model
{
    /// <summary>
    /// Provides gateway types
    /// </summary>
    internal enum GatewayType
    {
        /// <summary>
        /// Gateway establishes a connection via authentication information (needs to have an account)
        /// </summary>
        Account,

        /// <summary>
        /// Gateway establishes a connection via IP information
        /// </summary>
        IP
    }
}