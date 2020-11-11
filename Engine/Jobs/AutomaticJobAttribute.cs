namespace CarrierLink.Controller.Engine.Jobs
{

    using System;

    /// <summary>
    /// This class attributes functions to be run periodically as jobs
    /// </summary>
    [AttributeUsage(AttributeTargets.Method, Inherited = false, AllowMultiple = true)]
    internal class AutomaticJobAttribute : Attribute
    {
        #region Constructor

        /// <summary>
        /// Initializes a new instance of the <see cref="AutomaticJobAttribute"/> class
        /// </summary>
        /// <param name="milliseconds"></param>
        internal AutomaticJobAttribute(int milliseconds)
        {
            Milliseconds = milliseconds;
        }

        #endregion

        #region Properties

        /// <summary>
        /// Timer interval
        /// </summary>
        internal int Milliseconds { get; private set; }

        #endregion
    }
}
