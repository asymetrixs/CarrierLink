namespace CarrierLink.Controller.Engine.Caching.Model
{
    using System.Text.RegularExpressions;

    /// <summary>
    /// This class provides the number modification policy
    /// </summary>
    public class NumberModificationPolicy
    {
        #region Constructor

        /// <summary>
        /// Initializes a new instance of the <see cref="NumberModificationPolicy"/> class
        /// </summary>
        /// <param name="pattern">See <see cref="Pattern"/></param>
        /// <param name="removePrefix">See <see cref="RemovePrefix"/></param>
        /// <param name="addPrefix">See <see cref="AddPrefix"/></param>
        /// <param name="priority">See <see cref="Priority"/></param>
        internal NumberModificationPolicy(Regex pattern, string removePrefix, string addPrefix, int priority)
        {
            this.Pattern = pattern;
            this.RemovePrefix = removePrefix;
            this.AddPrefix = addPrefix;
            this.Priority = priority;
        }

        #endregion Constructor

        #region Properties

        /// <summary>
        /// Gets the prefix that needs to be added
        /// </summary>
        internal string AddPrefix { get; }

        /// <summary>
        /// Gets the regular expression pattern
        /// </summary>
        internal Regex Pattern { get; }

        /// <summary>
        /// Gets the priority
        /// </summary>
        internal int Priority { get; }

        /// <summary>
        /// Gets the prefix that needs to be removed
        /// </summary>
        internal string RemovePrefix { get; }

        #endregion Properties
    }
}