namespace CarrierLink.Controller.Engine.Caching.Model
{
    /// <summary>
    /// This class provides the gateway
    /// </summary>
    public class Gateway
    {
        #region Constructor

        /// <summary>
        /// Initializes a new instance of the <see cref="Gateway"/> class
        /// </summary>
        /// <param name="type">See <see cref="Type"/></param>
        /// <param name="id">See <see cref="Id"/></param>
        /// <param name="removeCountryCode">See <see cref="RemoveCountryCode"/></param>
        /// <param name="numberModificationGroup">See <see cref="NumberModificationGroup"/> Id</param>
        /// <param name="concurrentLinesLimit">See <see cref="ConcurrentLinesLimit"/></param>
        /// <param name="prefix">See <see cref="Prefix"/></param>
        /// <param name="format">See <see cref="Format"/></param>
        /// <param name="formats">See <see cref="Formats"/></param>
        /// <param name="outgoingConnectionId">See <see cref="OutgoingConnectionId"/></param>
        /// <param name="qosGroupId">See <see cref="QoSGroupId"/></param>
        /// <param name="companyId">See <see cref="CompanyId"/></param>
        internal Gateway(GatewayType type, int id, bool removeCountryCode, int? numberModificationGroup, int? concurrentLinesLimit, string prefix, string format, string formats, string outgoingConnectionId, int qosGroupId, int companyId)
        {
            this.Type = type;
            this.IdAsString = id.ToString(Engine.Formats.CultureInfo);
            this.Id = id;
            this.RemoveCountryCode = removeCountryCode;
            this.NumberModificationGroup = numberModificationGroup;
            this.ConcurrentLinesLimit = concurrentLinesLimit;
            this.Prefix = prefix;
            this.Format = format;
            this.Formats = formats;
            this.OutgoingConnectionId = outgoingConnectionId;
            this.QoSGroupId = qosGroupId;
            this.CompanyId = companyId;
        }

        #endregion Constructor

        #region Properties

        /// <summary>
        /// Gets Id of Company
        /// </summary>
        internal int CompanyId { get; }
        
        /// <summary>
        /// Gets the concurrent lines limit
        /// </summary>
        internal int? ConcurrentLinesLimit { get; }

        /// <summary>
        /// Gets the used format
        /// </summary>
        internal string Format { get; }

        /// <summary>
        /// Gets the available formats
        /// </summary>
        internal string Formats { get; }

        /// <summary>
        /// Gets database Id
        /// </summary>
        internal int Id { get; }

        /// <summary>
        /// Gets database Id as string
        /// </summary>
        internal string IdAsString { get; }

        /// <summary>
        /// Gets the corresponding <see cref="NumberModificationGroup"/> database Id
        /// </summary>
        internal int? NumberModificationGroup { get; }

        /// <summary>
        /// Gets the outgoing connection Id
        /// </summary>
        internal string OutgoingConnectionId { get; }

        /// <summary>
        /// Gets the prefix
        /// </summary>
        internal string Prefix { get; }

        /// <summary>
        /// Gets Id of Quality of Service group
        /// </summary>
        internal int QoSGroupId { get; }

        /// <summary>
        /// Gets a value indicating whether the country code should be removed or not
        /// </summary>
        internal bool RemoveCountryCode { get; }

        /// <summary>
        /// Gets type (Account/IP)
        /// </summary>
        internal GatewayType Type { get; }
        
        #endregion Properties
    }
}