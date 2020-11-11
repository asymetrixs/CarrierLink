namespace CarrierLink.Controller.Yate
{
    using Messaging;
    using Model;
    using System;
    using System.Collections.Generic;
    using System.Net;
    using System.Threading.Tasks;

    /// <summary>
    /// Node interface
    /// </summary>
    public interface INode
    {
        #region Properties

        /// <summary>
        /// Id of Node in Database
        /// </summary>
        int Id { get; }

        /// <summary>
        /// Amount of outgoing messages in buffer
        /// </summary>
        int OutgoingBufferQueueLength { get; }

        /// <summary>
        /// Shows if node is connected
        /// </summary>
        bool IsConnected { get; }

        /// <summary>
        /// Returns local IP Address
        /// </summary>
        IPAddress IPAddress { get; }

        /// <summary>
        /// Time of last received message
        /// </summary>
        DateTime LastMessageReceived { get; }

        /// <summary>
        /// Time of latest Engine Time
        /// </summary>
        DateTime LatestEngineTime { get; }

        /// <summary>
        /// Stores Performance Information
        /// </summary>
        List<PerformanceInformation> PerformanceInformation { get; }

        /// <summary>
        /// Returns a value between 10 and 100% indicating how many of the call.route message are being processed
        /// </summary>
        int ProcessingPercentage { get; }

        #endregion

        #region Methods

        /// <summary>
        /// Sends a message to Yate node
        /// </summary>
        /// <param name="message">Message to send to Yate</param>
        void Send(Message message);

        /// <summary>
        /// Disconnects node
        /// </summary>
        /// <returns></returns>
        Task Disconnect();

        /// <summary>
        /// Disposes node
        /// </summary>
        void Dispose();

        /// <summary>
        /// Adds Load Information to Node
        /// </summary>
        /// <param name="loadInformation">See <see cref="PerformanceInformation"/></param>
        void AddPerformance(PerformanceInformation loadInformation);

        /// <summary>
        /// Sets latest Engine Time
        /// </summary>
        /// <param name="latest">Datetime of engine.timer message</param>
        void SetLatestEngineTime(DateTime latest);

        /// <summary>
        /// Sets a new value for the critical load property
        /// </summary>
        /// <param name="load"></param>
        void SetCriticalLoad(int load);

        #endregion
    }
}