namespace CarrierLink.Controller.Engine.Jobs
{
    using Caching;
    using Database;
    using NLog;
    using System;
    using System.Reflection;
    using System.Runtime.CompilerServices;
    using System.Threading;
    using System.Threading.Tasks;

    /// <summary>
    /// This class provides the base for a class that periodically executes a method.
    /// In case the method is still running while execution is requested, the method is not executed concurrently.
    /// Further the execution is dismissed. The timer executes every <see cref="Interval"/>.
    /// </summary>
    internal class AutomaticJobContainer : IDisposable
    {
        #region Fields

        /// <summary>
        /// Timer to handle execution
        /// </summary>
        private System.Timers.Timer _timer;

        /// <summary>
        /// Flag: Has Dispose already been called?
        /// </summary>
        private bool _disposed;

        /// <summary>
        /// Method to run
        /// </summary>
        private MethodInfo _methodInfo;

        /// <summary>
        /// Logger
        /// </summary>
        private Logger _logger;

        #endregion

        #region Constructor

        /// <summary>
        /// Initializes a new instance of the <see cref="AutomaticJobContainer"/> class
        /// </summary>
        /// <param name="interval"></param>
        internal AutomaticJobContainer(MethodInfo methodInfo, int milliseconds)
        {
            _disposed = false;
            _logger = LogManager.GetLogger(methodInfo.DeclaringType.FullName);

            _methodInfo = methodInfo;

            _timer = new System.Timers.Timer();
            _timer.Interval = milliseconds;
            _timer.Elapsed += Timer_Elapsed;
            _timer.AutoReset = true;
        }

        #endregion

        #region Properties

        /// <summary>
        /// Returns name of invoked methos
        /// </summary>
        internal string Path
        {
            get
            {
                return _methodInfo.DeclaringType.FullName;
            }
        }

        internal string Name
        {
            get
            {
                return _methodInfo.Name;
            }
        }

        #endregion

        #region Methods

        /// <summary>
        /// Starts the timer. When overriding, use base.Start()
        /// </summary>
        internal virtual void Start()
        {
            _timer.Start();
        }

        /// <summary>
        /// Stops the timer. When overriding, use base.Stop();
        /// </summary>
        internal virtual void Stop()
        {
            _timer.Stop();
        }

        /// <summary>
        /// Method called when timer elapses
        /// </summary>
        /// <param name="sender"></param>
        /// <param name="e"></param>
        private void Timer_Elapsed(object sender, System.Timers.ElapsedEventArgs e)
        {
            if (Monitor.TryEnter(_timer))
            {
                _logger.Debug($"Job {_methodInfo.Name} started");

                var database = Pool.Database.Get();
                var parameters = new object[1] { database };
                try
                {
                    // Get return type
                    object returnObj;

                    if(_methodInfo.GetParameters().GetLength(0) == 1 && _methodInfo.GetParameters()[0].ParameterType == typeof(IDatabase))
                    {
                        returnObj = _methodInfo.Invoke(null, parameters);
                    }
                    else
                    {
                        returnObj =  _methodInfo.Invoke(null, null);
                    }
                    

                    // Check for asynchronicity
                    var asma = _methodInfo.GetCustomAttribute<AsyncStateMachineAttribute>();
                    if (asma != null && returnObj is Task)
                    {
                        // await Task
                        (returnObj as Task).Wait();
                    }
                }

                catch(Exception ex)
                {
                    _logger.Error(ex, $"Job {_methodInfo.Name} finished");
#if DEBUG
                    throw;
#endif
                }
                finally
                {
                    Pool.Database.Put(database);
                    database = null;

                    if (Core.CancellationToken.IsCancellationRequested)
                    {
                        _timer.Stop();
                    }
                    else
                    {
                        Monitor.Exit(_timer);
                    }

                    _logger.Debug($"Job {_methodInfo.Name} finished");
                }
            }
        }

        #endregion

        #region Dispose

        /// <summary>
        /// Public implementation of Dispose pattern callable by consumers.
        /// </summary>
        public void Dispose()
        {
            Dispose(true);
            GC.SuppressFinalize(this);
        }

        /// <summary>
        /// Protected implementation of Dispose pattern.
        /// </summary>
        /// <param name="disposing"></param>
        protected virtual void Dispose(bool disposing)
        {
            if (_disposed)
            {
                return;
            }

            if (disposing)
            {
                _timer.Stop();
                _timer.Dispose();
                _timer = null;
            }

            _disposed = true;
        }

        #endregion
    }
}
