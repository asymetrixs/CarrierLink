namespace CarrierLink.Controller.Utilities.RoutingTree
{
    /// <summary>
    /// This class describes the gateway as a target
    /// </summary>
    public class Gateway : Target
    {
        #region Constructor

        /// <summary>
        /// Initializes a new instance of the <see cref="Gateway"/> class
        /// </summary>
        /// <param name="id"></param>
        public Gateway()
            : base(TargetType.Gateway)
        {

        }

        #endregion

        #region Properties

        /// <summary>
        /// Routing via Node
        /// </summary>
        public Node Via { get; private set; }

        #endregion

        #region Methods

        /// <summary>
        /// Route to Gateway via Node
        /// </summary>
        /// <param name="node"></param>
        public void ViaNode(Node node)
        {
            this.Via = node;
        }

        #endregion
    }
}
