namespace CarrierLink.Controller.Engine.REST.Model
{
    /// <summary>
    /// Class to provide query configuration information
    /// </summary>
    public class QueryConfigurationResult
    {
        #region Properties

        /// <summary>
        /// Gets or sets section to query
        /// </summary>
        public string Section { get; set; }

        /// <summary>
        /// Gets or sets keys value to retrieve
        /// </summary>
        public string Key { get; set; }

        /// <summary>
        /// Gets or sets response from yate
        /// </summary>
        public string Result { get; set; }

        /// <summary>
        /// Gets or sets a value indicating whether communication with yate was successful or not
        /// </summary>
        public bool Success { get; set; }

        #endregion Properties
    }
}