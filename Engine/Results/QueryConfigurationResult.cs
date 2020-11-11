namespace CarrierLink.Controller.Engine.Results
{
    /// <summary>
    /// This class holds the configuration setting returned by querying Yate
    /// </summary>
    public class QueryConfigurationResult
    {
        #region Constructor

        /// <summary>
        /// Initializes a new instance of the <see cref="QueryConfigurationResult"/> class
        /// </summary>
        /// <param name="section">Section to query</param>
        /// <param name="key">Keys value to retrieve</param>
        /// <param name="result">Holds yate's response</param>
        /// <param name="success">Indicates if communication with yate was successful</param>
        public QueryConfigurationResult(string section, string key, string result, bool success)
        {
            this.Section = section;
            this.Key = key;
            this.Result = result;
            this.Success = success;
        }

        #endregion Constructor

        #region Properties

        /// <summary>
        /// Gets or sets section that is queried
        /// </summary>
        public string Section { get; set; }

        /// <summary>
        /// Gets or sets key that is queried
        /// </summary>
        public string Key { get; set; }

        /// <summary>
        /// Gets response from yate
        /// </summary>
        public string Result { get; private set; }

        /// <summary>
        /// Gets a value indicating whether communication with yate was successful or not
        /// </summary>
        public bool Success { get; private set; }

        #endregion Properties
    }
}