namespace CarrierLink.Controller.Engine.Caching.Model
{
    using System;

    /// <summary>
    /// This class is used to store live call information regarding Ids
    /// </summary>
    internal class LiveData
    {
        #region Constructor

        /// <summary>
        /// Initializes a new instance of the <see cref="LiveData"/> class
        /// </summary>
        /// <param name="data"></param>
        internal LiveData(object data)
        {
            Data = data;
            Created = DateTime.UtcNow;
        }

        #endregion

        #region Properties

        /// <summary>
        /// Gets Id information
        /// </summary>
        public object Data { get; }

        /// <summary>
        /// Gets returns date (utc) this instance was created
        /// </summary>
        public DateTime Created { get; }

        #endregion
    }
}
