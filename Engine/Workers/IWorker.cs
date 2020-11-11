namespace CarrierLink.Controller.Engine.Workers
{
    using System.Threading.Tasks;
    using Yate.Messaging;

    /// <summary>
    /// This interface needs to be implemented to process a message
    /// </summary>
    internal interface IWorker
    {
        #region Methods

        /// <summary>
        /// Processes messages in Cores MessageBuffer
        /// </summary>
        /// <param name="message">Message to process</param>
        /// <param name="isRunning">Indicates if service is running</param>
        /// <returns>Returns task to wait for until message was processed</returns>
        Task<Message> ProcessAsync(Message message, bool isRunning);

        #endregion Methods
    }
}