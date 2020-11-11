namespace CarrierLink.Controller.Engine.Caching.Model
{
    /// <summary>
    /// This class provides the IP of the node
    /// </summary>
    public class NodeIP
    {
        #region Constructor

        /// <summary>
        /// Initializes a new instance of the <see cref="NodeIP"/> class
        /// </summary>
        /// <param name="address">See <see cref="Address"/></param>
        /// <param name="port">See <see cref="Port"/></param>
        internal NodeIP(string address, string port)
        {
            this.Address = address;
            this.Port = port;
        }

        #endregion Constructor

        #region Properties

        /// <summary>
        /// Gets the address
        /// </summary>
        internal string Address { get; }

        /// <summary>
        /// Gets the port
        /// </summary>
        internal string Port { get; }

        #endregion Properties
    }
}