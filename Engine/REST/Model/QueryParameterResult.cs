namespace CarrierLink.Controller.Engine.REST.Model
{
    /// <summary>
    /// Class to provide query parameter information
    /// </summary>
    public class QueryParameterResult
    {
        #region Properties

        /// <summary>
        /// Gets or sets parameter that is queried
        /// </summary>
        public string Parameter { get; set; }

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