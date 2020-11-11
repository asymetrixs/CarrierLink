namespace CarrierLink.Controller.Engine.Caching.Model
{
    /// <summary>
    /// This class provides information about a call leg
    /// </summary>
    internal class CallLegInfo
    {
        #region Properties

        /// <summary>
        /// Gets or sets the call legs bill Id
        /// </summary>
        internal string BillId { get; set; }

        /// <summary>
        /// Gets or sets the call legs channel Id
        /// </summary>
        internal string ChannelId { get; set; }

        /// <summary>
        /// Gets or sets the call legs YRtp Id
        /// </summary>
        internal string YRtpId { get; set; }

        /// <summary>
        /// Gets or sets the call legs remote Rtp Ip
        /// </summary>
        internal string RemoteRtpIp { get; set; }

        /// <summary>
        /// Gets or sets the call legs remote Rtp Port
        /// </summary>
        internal int? RemoteRtpPort { get; set; }

        #endregion
    }
}
