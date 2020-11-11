namespace CarrierLink.Controller.Yate.Messaging
{
    /// <summary>
    /// Type of message
    /// </summary>
    public enum MessageDirection
    {
        /// <summary>
        /// Message from yate requesting an action (%%>)
        /// </summary>
        IncomingRequest,

        /// <summary>
        /// Message from yate answering an incoming message (%%<)
        /// </summary>
        IncomingAnswer,

        /// <summary>
        /// Message to yate answering an incoming message (%%<)
        /// </summary>
        OutgoingAnswer,

        /// <summary>
        /// Message to yate requesting an action (%%>)
        /// </summary>
        OutgoingRequest
    }
}