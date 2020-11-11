namespace CarrierLink.Controller.Engine
{
    using System;
    using System.Threading.Tasks;

    /// <summary>
    /// This class provides helpers to deal with tasks
    /// </summary>
    internal static class TaskHelper
    {
        #region Functions

        /// <summary>
        /// Runs a TPL Task fire-and-forget style, the right way - in the
        /// background, separate from the current thread, with no risk
        /// of it trying to rejoin the current thread.
        /// </summary>
        public static void RunInBackground(Func<Task> func)
        {
            Task.Run(func).ConfigureAwait(false);
        }

        /// <summary>
        /// Runs a task fire-and-forget style and notifies the TPL that this
        /// will not need a Thread to resume on for a long time, or that there
        /// are multiple gaps in thread use that may be long.
        /// Use for example when talking to a slow webservice.
        /// </summary>
        public static void RunInBackgroundLong(Func<Task> func)
        {
            Task.Factory.StartNew(func, TaskCreationOptions.LongRunning).ConfigureAwait(false);
        }

        #endregion
    }
}
