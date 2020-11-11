namespace CarrierLink.Controller.Engine
{
    /// <summary>
    /// Possible subscriber states
    /// </summary>
    public enum SubscriberState
    {
        /// <summary>
        /// Subscriber start requested
        /// </summary>
        StartRequested = 1,

        /// <summary>
        /// Subscriber starting
        /// </summary>
        Starting = 2,
        
        /// <summary>
        /// Subscriber started
        /// </summary>
        Started = 3,

        /// <summary>
        /// Installation requested
        /// </summary>
        InstallationRequested = 4,

        /// <summary>
        /// Subscriber installed
        /// </summary>
        Installed = 5,

        /// <summary>
        /// Subscriber running
        /// </summary>
        Running = 6,

        /// <summary>
        /// Subscriber paused
        /// </summary>
        Paused = 7,

        /// <summary>
        /// Stop requested
        /// </summary>
        StopRequested = 8,

        /// <summary>
        /// Subscriber stopping
        /// </summary>
        Stopping = 9,

        /// <summary>
        /// Uninstallation requested
        /// </summary>
        DeinstallationRequested = 10,

        /// <summary>
        /// Subscriber uninstalled
        /// </summary>
        Deinstalled = 11,

        /// <summary>
        /// Subscriber stopped
        /// </summary>
        Stopped = 12,

        /// <summary>
        /// Connecting failed
        /// </summary>
        ConnectingFailed = 13
    }
}