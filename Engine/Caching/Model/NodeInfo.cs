namespace CarrierLink.Controller.Engine.Caching.Model
{
    /// <summary>
    /// This class provides node information
    /// </summary>
    public class NodeInfo
    {
        #region Constructor

        /// <summary>
        /// Initializes a new instance of the <see cref="NodeInfo"/> class
        /// </summary>
        /// <param name="ipAddress">Yate Endpoint IP Address</param>
        /// <param name="port">Yate Endpoint Port</param>
        /// <param name="nodeId">Internal Yate Node Id</param>
        /// <param name="criticalLoadThreshold">Critical load threshold</param>
        internal NodeInfo(System.Net.IPAddress ipAddress, int port, int nodeId, int criticalLoadThreshold)
        {
            this.IPAddress = ipAddress;
            this.Port = port;
            this.CriticalLoadThreshold = criticalLoadThreshold;

            if (port < 1 || port > 65536)
            {
                throw new System.ArgumentOutOfRangeException("port", "Port must be between 1 and 65535!");
            }

            this.Id = nodeId;
        }

        #endregion Constructor

        #region Properties

        /// <summary>
        /// Gets yate database Id
        /// </summary>
        public int Id { get; }

        /// <summary>
        /// Gets yate endpoint IP
        /// </summary>
        public System.Net.IPAddress IPAddress { get; }

        /// <summary>
        /// Gets yate port
        /// </summary>
        public int Port { get; }

        /// <summary>
        /// Gets critical load value
        /// </summary>
        public int CriticalLoadThreshold { get; }

        #endregion Properties
    }
}