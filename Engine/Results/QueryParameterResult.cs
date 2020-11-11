namespace CarrierLink.Controller.Engine.Results
{
    /// <summary>
    /// This class holds the parameter value returned by querying Yate
    /// </summary>
    public class QueryParameterResult
    {
        #region Constructor

        /// <summary>
        /// Initializes a new instance of the <see cref="QueryParameterResult"/> class
        /// </summary>
        /// <param name="parameter">Parameter to query for</param>
        /// <param name="result">Holds yate's response</param>
        /// <param name="success">Indicates if communication with yate was successful</param>
        public QueryParameterResult(System.Enum parameter, string result, bool success)
        {
            this.Parameter = parameter;
            this.Result = result;
            this.Success = success;
        }

        #endregion Constructor

        #region Properties

        /// <summary>
        /// Gets or sets parameter that is queried
        /// </summary>
        public System.Enum Parameter { get; set; }

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