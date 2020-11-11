namespace CarrierLink.Controller.Utilities
{
    /// <summary>
    /// This class helps managing the naming between Core and Yate
    /// </summary>
    [System.AttributeUsage(System.AttributeTargets.Property | System.AttributeTargets.Field)]
    public sealed class TechnicalName : System.Attribute
    {
        #region Properties

        /// <summary>
        /// Yate internal command name
        /// </summary>
        public string Name { get; private set; }

        #endregion Properties

        #region Constructor

        /// <summary>
        /// Initializes a new instance of the <see cref="TechnicalName"/> class
        /// </summary>
        /// <param name="name"></param>
        public TechnicalName(string name)
        {
            this.Name = name;
        }

        #endregion Constructor
    }
}