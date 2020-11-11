namespace CarrierLink.Controller.Engine.Caching
{
    using Jobs;
    using Model;
    using NLog;
    using System;
    using System.Collections.Concurrent;

    /// <summary>
    /// Cache for live data
    /// </summary>
    public static class LiveCache
    {
        #region Fields

        /// <summary>
        /// Logger
        /// </summary>
        private static Logger logger = LogManager.GetCurrentClassLogger();

        /// <summary>
        /// Cache
        /// </summary>
        private static ConcurrentDictionary<string, LiveData> cache;

        #endregion

        #region Constructor

        static LiveCache()
        {
            cache = new ConcurrentDictionary<string, LiveData>();
        }

        #endregion

        #region Functions

        /// <summary>
        /// Adds data to the cache or replaces the old data with the provided <paramref name="data"/>
        /// </summary>
        /// <param name="key"></param>
        /// <param name="data"></param>
        public static void AddOrReplace(string key, object data)
        {
            var cachedData = new LiveData(data);
            cache.AddOrUpdate(key, cachedData, (k, v) => cachedData);
        }

        /// <summary>
        /// Retrieves data from cache
        /// </summary>
        /// <param name="key"></param>
        /// <returns></returns>
        public static object Get(string key)
        {
            cache.TryGetValue(key, out LiveData d);
            if (d != null)
            {
                return d.Data;
            }

            return null;
        }

        /// <summary>
        /// Removes the data stored at <paramref name="key"/> 
        /// </summary>
        /// <param name="key"></param>
        public static void Remove(string key)
        {
            cache.TryRemove(key, out LiveData d);
        }

        #endregion

        #region Jobs
        
        /// <summary>
        /// Removes old cached data
        /// </summary>
        [AutomaticJob(60000)]
        private static void CleanUp()
        {
            DateTime oldestCall = DateTime.UtcNow.AddMinutes(-150);

            // Clean ChannelId To YRtpId
            foreach (var ld in cache.ToArray())
            {
                if (ld.Value.Created < oldestCall)
                {
                    cache.TryRemove(ld.Key, out LiveData oldData);
                }
            }
        }

        #endregion
    }
}
