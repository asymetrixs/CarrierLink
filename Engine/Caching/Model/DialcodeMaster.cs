namespace CarrierLink.Controller.Engine.Caching.Model
{
    /// <summary>
    /// This class provides information about numbers
    /// </summary>
    public class DialcodeMaster
    {
        #region Constructor

        /// <summary>
        /// Initializes a new instance of the <see cref="DialcodeMaster"/> class
        /// </summary>
        /// <param name="dialcodeMasterId">See <see cref="DialcodeMasterId"/></param>
        /// <param name="isMobile">See <see cref="IsMobile"/></param>
        /// <param name="dialcode">See <see cref="Dialcode"/></param>
        internal DialcodeMaster(int dialcodeMasterId, bool isMobile, string dialcode)
        {
            this.DialcodeMasterId = dialcodeMasterId;
            this.IsMobile = isMobile;
            this.Dialcode = dialcode;
        }

        #endregion Constructor

        #region Properties

        /// <summary>
        /// Gets dialcode
        /// </summary>
        internal string Dialcode { get; }

        /// <summary>
        /// Gets database Id of Dialcode
        /// </summary>
        internal int DialcodeMasterId { get; }

        /// <summary>
        /// Gets a value indicating whether number is mobile or not
        /// </summary>
        internal bool IsMobile { get; }

        #endregion Properties
    }
}