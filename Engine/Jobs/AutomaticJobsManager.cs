namespace CarrierLink.Controller.Engine.Jobs
{
    using NLog;
    using System;
    using System.Collections.Generic;
    using System.Linq;
    using System.Reflection;

    /// <summary>
    /// This class starts and stops all automatic jobs
    /// </summary>
    internal static class AutomaticJobsManager
    {
        #region Fields

        /// <summary>
        /// List of jobs
        /// </summary>
        private static List<AutomaticJobContainer> _jobs;

        /// <summary>
        /// Flag indicating if jobs are started
        /// </summary>
        private static bool _started;

        /// <summary>
        /// Logger
        /// </summary>
        private static Logger _logger;

        #endregion

        #region Constructor

        /// <summary>
        /// Performs basic setup
        /// </summary>
        static AutomaticJobsManager()
        {
            _logger = LogManager.GetCurrentClassLogger();

            _started = false;
            _jobs = new List<AutomaticJobContainer>();

            var methods = AppDomain.CurrentDomain.GetAssemblies().SelectMany(a => a.GetTypes())
                .SelectMany(t => t.GetMethods(BindingFlags.NonPublic | BindingFlags.Public | BindingFlags.Static | BindingFlags.FlattenHierarchy))
                .Where(m => m.GetCustomAttributes(typeof(AutomaticJobAttribute), true).Length > 0).ToArray();

            foreach (MethodInfo method in methods)
            {
                AutomaticJobAttribute attr = (AutomaticJobAttribute)method.GetCustomAttributes(typeof(AutomaticJobAttribute), true)[0];

                _jobs.Add(new AutomaticJobContainer(method, attr.Milliseconds));
            }
        }

        #endregion

        #region Functions

        /// <summary>
        /// Starts timers
        /// </summary>
        internal static void Start()
        {
            if (!_started)
            {
                _started = true;
                _logger.Debug("Starting Jobs");

                foreach (var job in _jobs)
                {
                    job.Start();
                    _logger.Debug($"Started {job.Path}.{job.Name}");
                }
            }
        }

        /// <summary>
        /// Stops timers
        /// </summary>
        internal static void Stop()
        {
            if (_started)
            {
                _logger.Debug("Stopping Jobs");
                foreach (var job in _jobs.ToList())
                {
                    job.Stop();
                    _logger.Debug($"Stopped {job.Path}.{job.Name}");
                    job.Dispose();
                }
            }
        }

        #endregion
    }
}
