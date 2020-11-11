namespace CarrierLink.Controller.Engine
{
    /// <summary>
    /// SIP error codes
    /// </summary>
    internal enum ErrorCode
    {
        /// <summary>
        /// Rejected because customer is not allowed to call
        /// </summary>
        Forbidden = 403,

        /// <summary>
        /// Rejected because upstream gateway is temporarily unavailable
        /// </summary>
        TemporarilyUnavailable = 480,

        /// <summary>
        /// Rejected because the called number is incomplete
        /// </summary>
        AddressIncomplete = 484,

        /// <summary>
        /// Rejected because an internal server error occurred
        /// </summary>
        InternalServerError = 500,

        /// <summary>
        /// Rejected because the service cannot be provided
        /// </summary>
        ServiceUnavailable = 503,
    }
}