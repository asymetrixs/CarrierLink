namespace CarrierLink.Controller.Engine.Workers
{
    using Caching;
    using System.Linq;
    using Yate;
    using Yate.Messaging;

    /// <summary>
    /// This class handles chan.rtp messages
    /// </summary>
    internal class ChanRtpWatcher : AbstractWatcher
    {
        #region Fields

        /// <summary>
        /// Channel Id
        /// </summary>
        private string channelId;

        /// <summary>
        /// Remote RTP IP
        /// </summary>
        private string remoteRtpIp;
        
        /// <summary>
        /// Remote RTP Port
        /// </summary>
        private string remoteRtpPort;

        /// <summary>
        /// RTP Channel Id
        /// </summary>
        private string rtpChannelId;

        /// <summary>
        /// Bill ID
        /// </summary>
        private string callBillId;

        #endregion

        #region Methods

        /// <summary>
        /// Message handling
        /// </summary>
        /// <param name="message">See <see cref="Message"/></param>
        internal override void Handle(Message message)
        {
            // TODO: Tests for LiveCache
            this._Parse();

            int nodeId = message.Node.Id;

            if (!string.IsNullOrEmpty(channelId))
            {
                LiveCache.AddOrReplace($"channelIdToYRtpId-{nodeId}-{this.channelId}", this.rtpChannelId);
            }

            if (!string.IsNullOrEmpty(remoteRtpIp))
            {
                LiveCache.AddOrReplace($"yRtpIdToRemoteRtpIp-{nodeId}-{this.rtpChannelId}", this.remoteRtpIp);
            }

            if (!string.IsNullOrEmpty(callBillId))
            {
                LiveCache.AddOrReplace($"yRtpIdToBillId-{nodeId}-{this.rtpChannelId}", this.callBillId);
            }

            if (!string.IsNullOrEmpty(this.remoteRtpPort))
            {
                LiveCache.AddOrReplace($"yRtpIdToRemoteRtpPort-{nodeId}-{this.rtpChannelId}", this.remoteRtpPort);
            }

            this._Reset();
        }

        /// <summary>
        /// Resets values
        /// </summary>
        private void _Reset()
        {
            this.remoteRtpIp = string.Empty;
            this.remoteRtpPort = string.Empty;
            this.rtpChannelId = string.Empty;
            this.callBillId = string.Empty;
            this.channelId = string.Empty;
        }

        /// <summary>
        /// Parses the message for it's values
        /// </summary>
        private void _Parse()
        {
            var values = Messages.Skip(4).ToArray();

            string yateParameter, yateValue;
            int pos;

            foreach (var value in values)
            {
                pos = value.IndexOf('=');

                // ignore everything without =
                if (pos == -1)
                {
                    continue;
                }

                yateParameter = value.Substring(0, pos);

                // Check if has value
                if (pos <= value.Length - 1)
                {
                    yateValue = CharacterCoding.Decode(value.Substring(pos + 1));
                }
                else
                {
                    continue;
                }

                switch (yateParameter)
                {
                    case "id":
                        this.channelId = yateValue;
                        break;

                    case "remoteip":
                        this.remoteRtpIp = yateValue;
                        break;

                    case "remoteport":
                        this.remoteRtpPort = yateValue;
                        break;

                    case "rtpId":
                        this.rtpChannelId = yateValue;
                        break;

                    case "call_billid":
                        this.callBillId = yateValue;
                        break;

                    default:
                        continue;
                }
            }
        }

        #endregion
    }
}
