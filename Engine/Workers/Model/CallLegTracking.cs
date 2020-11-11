namespace CarrierLink.Controller.Engine.Workers.Model
{
    using Caching.Model;
    using System;

    /// <summary>
    /// Tracks call legs
    /// </summary>
    internal class CallLegTracking
    {
        #region Fields

        /// <summary>
        /// Gets or sets direction of call
        /// </summary>
        internal Direction Direction { get; set; }

        /// <summary>
        /// Gets or sets a value indicating whether call has ended or not
        /// </summary>
        internal bool Ended { get; set; }

        /// <summary>
        /// Gets or sets date on which call has ended
        /// </summary>
        internal DateTime EndedOn { get; set; }

        /// <summary>
        /// Gets or sets identifier
        /// </summary>
        internal string Identifier { get; set; }

        /// <summary>
        /// Gets or sets operation
        /// </summary>
        internal string Operation { get; set; }

        /// <summary>
        /// Gets or sets status
        /// </summary>
        internal string Status { get; set; }
        #endregion Fields
    }
}