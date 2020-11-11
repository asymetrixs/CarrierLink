namespace CarrierLink.Controller.Engine
{
    /// <summary>
    /// State between Controller and Yate
    /// </summary>
    public enum ControlState
    {
        /// <summary>
        /// Disconnected from Yate
        /// </summary>
        Disconnected = 0,

        /// <summary>
        /// Connection to Yate requested
        /// </summary>
        ConnectRequested = 1,

        /// <summary>
        /// Connecting to Yate
        /// </summary>
        Connecting = 2,

        /// <summary>
        /// Connected to Yate
        /// </summary>
        Connected = 3,

        /// <summary>
        /// Disconnect from Yate requested
        /// </summary>
        DisconnectRequested = 4,

        /// <summary>
        /// Disconnecting from Yate
        /// </summary>
        Disconnecting = 5,

        /// <summary>
        /// Connecting to node failed
        /// </summary>
        ConnectionFailed = 6
    }
}