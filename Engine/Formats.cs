namespace CarrierLink.Controller.Engine
{
    using System.Globalization;

    /// <summary>
    /// This class provides specific conversion formats for various data types
    /// </summary>
    internal static class Formats
    {
        #region Properties

        /// <summary>
        /// Gets format for formatting decimal values to string
        /// </summary>
        internal static string DecimalToString { get; } = "########0.##########";

        /// <summary>
        /// Gets format for formatting objects to a specific culture
        /// </summary>
        internal static CultureInfo CultureInfo { get; } = new CultureInfo("de-DE");
        
        #endregion Properties
    }
}