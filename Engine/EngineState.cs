namespace CarrierLink.Controller.Engine
{
    /// <summary>
    /// Engine states
    /// </summary>
    public enum EngineState
    {
        /// <summary>
        /// Unspecified state
        /// </summary>
        None,

        /// <summary>
        /// Engine is stopped
        /// </summary>
        Stopped,

        /// <summary>
        /// Engine is running
        /// </summary>
        Running,

        /// <summary>
        /// Engine is paused
        /// </summary>
        Paused,

        /// <summary>
        /// Engine is stopping
        /// </summary>
        Stopping
    }
}