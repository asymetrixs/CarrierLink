namespace CarrierLink.Controller.Engine.Workers
{
    using Caching;
    using Yate.Messaging;

    /// <summary>
    /// This class handles chan.startup messages
    /// </summary>
    internal class ChanStartupWatcher : AbstractWatcher
    {
        #region Methods

        /// <summary>
        /// Message handling
        /// </summary>
        /// <param name="message">See <see cref="Message"/></param>
        internal override void Handle(Message message)
        {
            string channelId = message.GetValue("id");
            string billId = message.GetValue("billid");
            int nodeId = message.Node.Id;

            LiveCache.AddOrReplace($"channelIdToBillId-{nodeId}-{channelId}", billId);
        }

        #endregion
    }
}
