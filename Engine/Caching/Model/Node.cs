namespace CarrierLink.Controller.Engine.Caching.Model
{
    /// <summary>
    /// This class provides the node
    /// </summary>
    public class Node
    {
        #region Constructor

        /// <summary>
        /// Initializes a new instance of the <see cref="Node"/> class
        /// </summary>
        /// <param name="id">See <see cref="Id"/></param>
        /// <param name="identifier">See <see cref="Identifier"/></param>
        internal Node(int id, string identifier)
        {
            this.Id = id;
            this.Identifier = identifier;
        }

        #endregion Constructor

        #region Properties

        /// <summary>
        /// Gets database Id
        /// </summary>
        internal int Id { get; }

        /// <summary>
        /// Gets identifier
        /// </summary>
        internal string Identifier { get; }

        #endregion Properties
    }
}