namespace CarrierLink.Controller.Engine.Caching.Model
{
    /// <summary>
    /// This class provides the Controller connections
    /// </summary>
    public class ControllerConnection
    {
        #region Constructor

        /// <summary>
        /// Initializes a new instance of the <see cref="ControllerConnection"/> class
        /// </summary>
        /// <param name="nodeId">Node Id</param>
        /// <param name="controlState">Control State</param>
        /// <param name="autoConnect">Auto-Connect flag</param>
        internal ControllerConnection(int nodeId, ControlState controlState, bool autoConnect)
        {
            this.NodeId = nodeId;
            this.ControlState = controlState;
            this.AutoConnect = autoConnect;
        }

        #endregion Constructor

        #region Properties

        /// <summary>
        /// Gets a value indicating whether auto-connect is activated or not
        /// </summary>
        internal bool AutoConnect { get; private set; }

        /// <summary>
        /// Gets the control state
        /// </summary>
        internal ControlState ControlState { get; private set; }

        /// <summary>
        /// Gets the node Id
        /// </summary>
        internal int NodeId { get; private set; }

        #endregion Properties
    }
}