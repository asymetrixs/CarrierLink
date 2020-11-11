namespace CarrierLink.Controller.Engine.Caching.Model
{
    using System;

    /// <summary>
    /// This class provides an IVR record
    /// </summary>
    public class IvrRecord
    {
        #region Constructor

        /// <summary>
        /// Initializes a new instance of the <see cref="IvrRecord"/> class
        /// </summary>
        /// <param name="id">See <see cref="Id"/></param>
        /// <param name="created">See <see cref="Created"/></param>
        internal IvrRecord(int id, DateTime created)
        {
            this.Id = id;
            this.Created = created;
        }

        #endregion Constructor

        #region Properties

        /// <summary>
        /// Gets creation date
        /// </summary>
        internal DateTime Created { get; private set; }

        /// <summary>
        /// Gets database Id
        /// </summary>
        internal int Id { get; private set; }

        #endregion Properties
    }
}