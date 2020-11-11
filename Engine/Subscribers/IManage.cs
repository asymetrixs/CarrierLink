namespace CarrierLink.Controller.Engine.Subscribers
{
    using Yate.Messaging;

    /// <summary>
    /// This interface is used in subscribers that request information from Yate
    /// </summary>
    internal interface IManage
    {
        #region Methods

        /// <summary>
        /// Processes handler messages
        /// </summary>
        /// <param name="message">Yate message to manage</param>
        void Manage(Message message);

        #endregion Methods
    }
}