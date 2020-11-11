namespace CarrierLink.Controller.Utilities.RoutingTree
{
    using Newtonsoft.Json;
    using Newtonsoft.Json.Converters;

    /// <summary>
    /// Abstract class for targets
    /// </summary>
    public abstract class Target
    {
        #region Constructor

        /// <summary>
        /// Constructs a new instance of the <see cref="Target"/> class
        /// </summary>
        /// <param name="endpoint"></param>
        internal Target(TargetType endpoint)
        {
            this.Endpoint = endpoint;
            this.Id = null;
        }

        #endregion

        #region Properties

        /// <summary>
        /// Type of target
        /// </summary>
        [JsonConverter(typeof(StringEnumConverter))]
        public TargetType Endpoint { get; private set; }

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

        /// <summary>
        /// Sets the endpoint type
        /// </summary>
        /// <param name="target"></param>
        public void SetEndpoint(TargetType target)
        {
            this.Endpoint = target;
        }

        #endregion
    }
}
