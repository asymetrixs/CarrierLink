namespace CarrierLink.Controller.Yate
{
    using Utilities;

    /// <summary>
    /// Subscriber types
    /// </summary>
    public enum SubscriberType
    {
        /// <summary>
        /// Handler type that receives messages and answers them as handled if they were processed
        /// </summary>
        [TechnicalName("install")]
        Handler,

        /// <summary>
        /// Handler type that receives messages after they are answered by handlers for monitoring purpose
        /// </summary>
        [TechnicalName("watch")]
        Watcher
    }
}