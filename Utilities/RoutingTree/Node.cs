namespace CarrierLink.Controller.Utilities.RoutingTree
{
    using Newtonsoft.Json;
    using Newtonsoft.Json.Converters;

    /// <summary>
    /// This class describes the node as a target
    /// </summary>
    public class Node
    {
        #region Constructor

        /// <summary>
        /// Initializes a new instance of the <see cref="Gateway"/> class
        /// </summary>
        /// <param name="id"></param>
        public Node()
        {

        }

        #endregion

        #region Properties

        /// <summary>
        /// Id
        /// </summary>
        public int? Id { get; private set; }

        /// <summary>
        /// Indicates if this target is skipped because it was already targeted earlier
        /// </summary>
        [JsonConverter(typeof(StringEnumConverter))]
        public Reason TargetReason { get; private set; }

        #endregion

        #region Methods

        /// <summary>
        /// Adds an action
        /// </summary>
        public void AddReason(Reason action)
        {
            this.TargetReason |= action;
        }

        /// <summary>
        /// Sets the Id
        /// </summary>
        /// <param name="id">Id</param>
        public void SetId(int id)
        {
            this.Id = id;
        }

        #endregion
    }
}
