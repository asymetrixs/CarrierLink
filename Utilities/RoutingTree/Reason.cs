namespace CarrierLink.Controller.Utilities.RoutingTree
{
    using System;

    /// <summary>
    /// This class indicates the action performed for Targets
    /// </summary>
    [Flags]
    public enum Reason
    {
        /// <summary>
        /// Exerthing is OK (default)
        /// </summary>
        OK = 0,

        /// <summary>
        /// Gateway was already targeted
        /// </summary>
        AlreadyTargeted = 1,

        /// <summary>
        /// Gateway has same Company as Customer
        /// </summary>
        SameCompany = 2,

        /// <summary>
        /// Target in cache not found
        /// </summary>
        CacheMiss = 4,

        /// <summary>
        /// Customer has no rate
        /// </summary>
        CustomerNoRate = 8,

        /// <summary>
        /// Gateway has no rate
        /// </summary>
        GatewayNoRate = 16,

        /// <summary>
        /// Limit is exceeded
        /// </summary>
        LimitExceeded = 32,

        /// <summary>
        /// Internal routing
        /// </summary>
        SendInternal = 64,

        /// <summary>
        /// Gateway Id Missing on internal routing
        /// </summary>
        GatewayIdNotTransmitted = 128,

        /// <summary>
        /// Routing failed
        /// </summary>
        RoutingFailed = 256,

        /// <summary>
        /// Preroute failed
        /// </summary>
        PrerouteFailed = 512,

        /// <summary>
        /// Called number is blacklisted
        /// </summary>
        Blacklisted = 1024,

        /// <summary>
        /// Dialcode Number is missing
        /// </summary>
        DialcodeMasterMissing = 2048,

        /// <summary>
        /// Number Modification not found in Cache
        /// </summary>
        CacheMissForNumberModification = 4096,

        /// <summary>
        /// Gateway Account not found in Cache
        /// </summary>
        CacheMissGatewayAccount = 8192,

        /// <summary>
        /// Gateway IP not found in Cache
        /// </summary>
        CacheMissGatewayIP = 16384,

        /// <summary>
        /// Sending address is empty
        /// </summary>
        AddressIsEmpty = 32768,

        /// <summary>
        /// Called is incomplete
        /// </summary>
        CalledIsIncomplete = 65536,

        /// <summary>
        /// Sender is unknown
        /// </summary>
        UnknownSender = 131072,

        /// <summary>
        /// Blending
        /// </summary>
        Blending = 262144
    }
}
