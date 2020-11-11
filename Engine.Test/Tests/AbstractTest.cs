namespace CarrierLink.Controller.Engine.Test.Tests
{
    using Yate;
    using System;

    /// <summary>
    /// Base class for tests
    /// </summary>
    public abstract class AbstractTest
    {
        #region Properties

        /// <summary>
        /// Current Time as UnixTimestamp
        /// </summary>
        protected static int UnixTimestamp
        {
            get
            {
                return (int)(DateTime.Now - new DateTime(1970, 1, 1)).TotalSeconds;
            }
        }

        /// <summary>
        /// Parameters that needs to be copied by Yate
        /// </summary>
        protected static string CopyParams { get; } = ":copyparams=clgatewayid,cltechcalled,clgatewayipid,clgatewayaccountid,cltrackingid,clwaitingtime,clprocessingtime,clcustomerid,cldialcodemasterid,clgatewaypriceid,clgatewaypricepermin,clgatewaycurrency,clcustomerpriceid,clcustomerpricepermin,clcustomercurrency,clnodeid,clcustomeripid";

        #endregion Properties

        #region Helper

        /// <summary>
        /// Accesses the LiveCache to get the Routing Tree
        /// </summary>
        /// <param name="node"></param>
        /// <param name="billId"></param>
        /// <param name="ended"></param>
        /// <returns></returns>
        internal Utilities.RoutingTree.Root getRoutingTree(INode node, string billId, bool ended)
        {
            object data = null;
            Utilities.RoutingTree.Root root = null;
            string key = $"routingTree-{node.Id}-{billId}";

            data = Caching.LiveCache.Get(key);
            if (data != null && data is Utilities.RoutingTree.Root)
            {
                root = data as Utilities.RoutingTree.Root;
            }

            if(ended)
            {
                Caching.LiveCache.Remove(key);
            }

            return root;
        }

        #endregion
    }
}
