namespace CarrierLink.Controller.Yate
{
    /// <summary>
    /// List of possible connection states
    /// </summary>
    internal enum ConnectionState
    {
        /// <summary>
        /// Not connected
        /// </summary>
        None,

        /// <summary>
        /// Connect requested
        /// </summary>
        ConnectRequested,

        /// <summary>
        /// Connection established
        /// </summary>
        Connected,

        /// <summary>
        /// Disconnect requested
        /// </summary>
        DisconnectRequested,

        /// <summary>
        /// Connection disconnected
        /// </summary>
        Disconnected
    }
}