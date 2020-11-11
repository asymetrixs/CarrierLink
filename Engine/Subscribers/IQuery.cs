namespace CarrierLink.Controller.Engine.Subscribers
{
    using System;
    using System.Threading.Tasks;
    using Results;

    /// <summary>
    /// This interface is used in subscribers that request information from Yate
    /// </summary>
    internal interface IQuery
    {
        #region Properties

        /// <summary>
        /// Gets handler id
        /// </summary>
        Guid Id { get; }

        #endregion Properties

        #region Methods

        /// <summary>
        /// Query Yate
        /// </summary>
        /// <returns>Returns query result</returns>
        Task<QueryParameterResult> QueryAsync();

        /// <summary>
        /// Start the implementing object instance
        /// </summary>
        void Start();

        /// <summary>
        /// Stops the implementing object instance
        /// </summary>
        void Stop();

        #endregion Methods
    }
}