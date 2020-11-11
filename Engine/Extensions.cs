namespace CarrierLink.Controller.Engine
{
    using Caching;
    using Caching.Model;
    using NLog;
    using Yate.Messaging;

    /// <summary>
    /// This class provides extension methods for various classes
    /// </summary>
    internal static class Extensions
    {
        #region Fields

        /// <summary>
        /// Provides logging capabilities
        /// </summary>
        private static Logger logger = LogManager.GetCurrentClassLogger();

        #endregion Fields

        #region Functions

        /// <summary>
        /// Retrieves the TechnicalName-attribute value of <paramref name="type"/>
        /// </summary>
        /// <param name="type">Type of message as technical name</param>
        /// <returns>Returns the type as string</returns>
        public static string ToTechnicalName(this MessageType type)
        {
            return Pool.MessageTypes.ToString(type);
        }

        /// <summary>
        /// Retrieves the TechnicalName-attribute value of <paramref name="type"/>
        /// </summary>
        /// <param name="type">Fork connect behavior as technical name</param>
        /// <returns>Returns the type as string</returns>
        public static string ToTechnicalName(this ForkConnectBehavior type)
        {
            return Pool.ForkConnectBehaviors.ToString(type);
        }
        
        #endregion Functions
    }
}