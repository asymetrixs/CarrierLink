namespace CarrierLink.Controller.Engine.Workers
{
    using Caching;
    using Caching.Model;
    using Yate.Messaging;

    /// <summary>
    /// This class handles chan.hangup messages
    /// </summary>
    internal class ChanHangupWatcher : AbstractWatcher
    {
        #region Methods

        /// <summary>
        /// Handles a chan.hangup message
        /// </summary>
        /// <param name="message">See <seealso cref="Message"/></param>
        /// <returns></returns>
        internal override void Handle(Message message)
        {
            // TODO: optimize variable resolving
            this.Initialize(message);

            var rtpStats = this.Message.GetValue("rtp_stats");

            var rtpData = getRtpDetailsFromChangHangup();

            var rtpStatistic = new RtpStats(this.Message.GetValue("billid"), this.Message.GetValue("id"), this.Message.Node, rtpData?.RemoteRtpIp, rtpData?.RemoteRtpPort);

            if (!string.IsNullOrEmpty(rtpStats))
            {
                var stats = rtpStats.Split(',');
                string[] sPV;

                foreach (var s in stats)
                {
                    sPV = s.Split('=');
                    switch (sPV[0])
                    {
                        case "PS":
                            rtpStatistic.PacketsSent = long.Parse(sPV[1], Formats.CultureInfo);
                            break;

                        case "OS":
                            rtpStatistic.OctetsSent = long.Parse(sPV[1], Formats.CultureInfo);
                            break;

                        case "PR":
                            rtpStatistic.PacketsReceived = long.Parse(sPV[1], Formats.CultureInfo);
                            break;

                        case "OR":
                            rtpStatistic.OctetsReceived = long.Parse(sPV[1], Formats.CultureInfo);
                            break;

                        case "PL":
                            rtpStatistic.PacketLoss = long.Parse(sPV[1], Formats.CultureInfo);
                            break;

                        default:
                            break;
                    }
                }
            }

            TaskHelper.RunInBackground(async () =>
            {
                var database = Pool.Database.Get();
                await database.AddRtpStats(rtpStatistic);
                Pool.Database.Put(database);
            });
        }

        /// <summary>
        /// Retrieves RTP data from cache
        /// </summary>
        /// <returns></returns>
        private CallLegInfo getRtpDetailsFromChangHangup()
        {
            if (this.Message.MessageType != MessageType.ChanHangup)
            {
                return null;
            }

            string channelId = this.Message.GetValue("id");
            int nodeId = this.Message.Node.Id;

            var callLeg = new CallLegInfo();
            callLeg.ChannelId = channelId;
            callLeg.BillId = this.Message.GetValue("billid");

            // Usage of same 'data' reference for performance
            object data = LiveCache.Get($"channelIdToYRtpId-{nodeId}-{channelId}");
            if (data != null && data is string)
            {
                callLeg.YRtpId = data as string;
            }
            else
            {
                return null;
            }

            if (string.IsNullOrEmpty(callLeg.BillId))
            {
                data = LiveCache.Get($"yRtpIdToBillId-{nodeId}-{callLeg.YRtpId}");
                if (data == null)
                {
                    data = LiveCache.Get($"channelIdToBillId-{nodeId}-{channelId}");
                }

                if (data != null && data is string)
                {
                    callLeg.BillId = data as string;
                }
            }

            // Resolve remote ip
            data = LiveCache.Get($"yRtpIdToRemoteRtpIp-{nodeId}-{callLeg.YRtpId}");
            if (data != null && data is string)
            {
                callLeg.RemoteRtpIp = data as string;
            }

            // Resolve remote port
            data = LiveCache.Get($"yRtpIdToRemoteRtpPort-{nodeId}-{callLeg.YRtpId}");
            if (data != null && data is string)
            {
                callLeg.RemoteRtpPort = int.Parse(data as string);
            }
            
            // Cleanup
            // Clean ChannelId To YRtpId            
            if (!string.IsNullOrEmpty(callLeg.ChannelId))
            {
                LiveCache.Remove($"channelIdToYRtpId-{nodeId}-{callLeg.ChannelId}");
            }

            // Clean ChannelId to BillId
            if (!string.IsNullOrEmpty(callLeg.ChannelId))
            {
                LiveCache.Remove($"channelIdToBillId-{nodeId}-{callLeg.ChannelId}");
            }

            // Clean YRtpId to BillId
            if (!string.IsNullOrEmpty(callLeg.YRtpId))
            {
                LiveCache.Remove($"yRtpIdToBillId-{nodeId}-{callLeg.YRtpId}");
            }

            // Clean YRtpId to RemoteRtpIP
            if (!string.IsNullOrEmpty(callLeg.YRtpId))
            {
                LiveCache.Remove($"yRtpIdToRemoteRtpIp-{nodeId}-{callLeg.YRtpId}");
            }

            return callLeg;
        }

        #endregion
    }
}
