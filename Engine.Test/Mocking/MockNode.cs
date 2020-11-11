namespace CarrierLink.Controller.Engine.Test.Mocking
{
    using CarrierLink.Controller.Yate.Model;
    using System;
    using System.Collections.Concurrent;
    using System.Collections.Generic;
    using System.Net;
    using System.Threading.Tasks;
    using Yate;
    using Yate.Messaging;

    public class MockNode : INode
    {
        #region Fields

        /// <summary>
        /// Buffer for outgoing messages
        /// </summary>
        private BlockingCollection<Message> outgoingBuffer = new BlockingCollection<Message>();

        #endregion

        #region Constructor

        /// <summary>
        /// Initializes a new instance of the <see cref="MockNode"/> class
        /// </summary>
        /// <param name="id"></param>
        internal MockNode(int id)
        {
            this.Id = id;
        }

        #endregion Constructor

        #region Properties

        /// <summary>
        /// Node Id in database
        /// </summary>
        public int Id { get; private set; }

        /// <summary>
        /// Amount of outgoing messages in buffer
        /// </summary>
        public int OutgoingBufferQueueLength
        {
            get
            {
                return outgoingBuffer.Count;
            }
        }

        /// <summary>
        /// Shows if Node is connected
        /// </summary>
        public bool IsConnected
        {
            get
            {
                return true;
            }
        }

        /// <summary>
        /// Returns local IP Address
        /// </summary>
        public IPAddress IPAddress
        {
            get
            {
                return IPAddress.Parse("127.0.0.1");
            }
        }

        /// <summary>
        /// Returns always 'UtcNow'
        /// </summary>
        public DateTime LastMessageReceived
        {
            get
            {
                return DateTime.UtcNow;
            }
        }

        public DateTime LatestEngineTime { get; private set; }

        public int ProcessingPercentage
        {
            get
            {
                return 100;
            }
        }

        public List<PerformanceInformation> PerformanceInformation { get; private set; }
        #endregion Properties

        #region Methods

        /// <summary>
        /// Returns messages from Buffer (mocking)
        /// </summary>
        /// <returns></returns>
        internal Message RetrieveMessage() => outgoingBuffer.Take();

        /// <summary>
        /// Provides a reuseable <see cref="Message"/> instance
        /// </summary>
        /// <returns></returns>
        public Message GetMessage() => new Message();

        /// <summary>
        /// Sends a message to Yate node
        /// </summary>
        /// <param name="message">Message to send</param>
        void INode.Send(Message message) => this.outgoingBuffer.Add(message);

        /// <summary>
        /// Returns completed Task
        /// </summary>
        /// <returns></returns>
        public Task Disconnect()
        {
            return Task.CompletedTask;
        }

        /// <summary>
        /// Does nothing
        /// </summary>
        public void Dispose()
        {

        }

        void INode.AddPerformance(PerformanceInformation performanceInformation)
        {
            this.PerformanceInformation.Add(performanceInformation);
        }

        public void SetLatestEngineTime(DateTime latest)
        {
            this.LatestEngineTime = latest;
        }

        public void SetCriticalLoad(int load)
        {
            throw new NotImplementedException();
        }

        #endregion Methods
    }
}
