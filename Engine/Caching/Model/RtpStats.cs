namespace CarrierLink.Controller.Engine.Caching.Model
{
    using Yate;

    /// <summary>
    /// This class provides RTP statistics
    /// </summary>
    public class RtpStats
    {
        #region Constructor

        /// <summary>
        /// Initializes a new instance of the <see cref="RtpStats"/> class
        /// </summary>
        /// <param name="billId">See <see cref="BillId"/></param>
        /// <param name="chan">See <see cref="Chan"/></param>
        /// <param name="node">See <see cref="Node"/></param>
        /// <param name="remoteIp">See <see cref="RemoteIp"/></param>
        internal RtpStats(string billId, string chan, INode node, string remoteIp, int? remotePort)
        {
            this.BillId = billId;
            this.Chan = chan;
            this.Node = node;
            this.RemoteIp = remoteIp;
            this.RemotePort = remotePort;
        }

        #endregion Constructor

        #region Properties

        /// <summary>
        /// Gets bill Id of call
        /// </summary>
        internal string BillId { get; private set; }

        /// <summary>
        /// Gets channel of call
        /// </summary>
        internal string Chan { get; private set; }

        /// <summary>
        /// Gets or sets RTP octets received
        /// </summary>
        internal long OctetsReceived { get; set; }

        /// <summary>
        /// Gets or sets RTP octets sent
        /// </summary>
        internal long OctetsSent { get; set; }

        /// <summary>
        /// Gets or sets RTP packet loss
        /// </summary>
        internal long PacketLoss { get; set; }

        /// <summary>
        /// Gets or sets RTP packets received
        /// </summary>
        internal long PacketsReceived { get; set; }

        /// <summary>
        /// Gets or sets RTP packets sent
        /// </summary>
        internal long PacketsSent { get; set; }

        /// <summary>
        /// Gets node handling the call
        /// </summary>
        internal INode Node { get; private set; }

        /// <summary>
        /// Gets the remote parties RTP IP address
        /// </summary>
        internal string RemoteIp { get; private set; }

        /// <summary>
        /// Gets the remote parties RTP Port
        /// </summary>
        internal int? RemotePort { get; private set; }

        #endregion Properties
    }
}