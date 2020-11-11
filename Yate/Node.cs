namespace CarrierLink.Controller.Yate
{
    using Messaging;
    using Model;
    using NLog;
    using System;
    using System.Collections.Generic;
    using System.Linq;
    using System.Threading.Tasks;
    using System.Threading.Tasks.Dataflow;

    /// <summary>
    /// This class represents the Yate server and manages the connection to it
    /// </summary>
    public class Node : IDisposable, INode
    {
        #region Fields

        /// <summary>
        /// Dispose
        /// </summary>
        private bool disposed = false;

        /// <summary>
        /// Connection to Yate
        /// </summary>
        private Connection connection;

        /// <summary>
        /// Logger
        /// </summary>
        private static Logger logger = LogManager.GetCurrentClassLogger();

        #endregion Fields

        #region Constructor

        /// <summary>
        /// Initializes a new instance of the <see cref="Node"/> class
        /// </summary>
        /// <param name="ipAddress">Yate Node IP Address</param>
        /// <param name="port">Yate Node Port</param>
        /// <param name="nodeId">Internal Yate Node Id</param>
        /// <param name="criticalLoadThreshold">Critical load threshold</param>
        public Node(System.Net.IPAddress ipAddress, int port, int nodeId, int criticalLoadThreshold)
        {
            this.PerformanceInformation = new List<Model.PerformanceInformation>();

            this.IPAddress = ipAddress;
            this.Port = port;
            this.CriticalLoadThreshold = criticalLoadThreshold;

            if (port < 1 || port > 65536)
            {
                throw new ArgumentOutOfRangeException("port", "Port must be between 1 and 65535!");
            }

            this.Id = nodeId;
            this.LatestEngineTime = DateTime.Now;
        }

        #endregion Constructor

        #region Properties

        /// <summary>
        /// Gets critical load threshold
        /// </summary>
        public int CriticalLoadThreshold { get; private set; }

        /// <summary>
        /// Yate DB ID
        /// </summary>
        public int Id { get; }

        /// <summary>
        /// Yate Node IP
        /// </summary>
        public System.Net.IPAddress IPAddress { get; }

        /// <summary>
        /// Yate Port
        /// </summary>
        internal int Port { get; }

        /// <summary>
        /// Returns if connection is connected
        /// </summary>
        public bool IsConnected
        {
            get
            {
                return connection != null && connection.IsConnected && connection.State == ConnectionState.Connected;
            }
        }

        /// <summary>
        /// Returns time when last message was received
        /// </summary>
        public DateTime LastMessageReceived
        {
            get
            {
                return this.connection.LastMessageReceived;
            }
        }

        /// <summary>
        /// Amount of outgoing messages in buffer
        /// </summary>
        int INode.OutgoingBufferQueueLength
        {
            get
            {
                return this.connection.OutputBufferLength;
            }
        }

        /// <summary>
        /// Time of latest Engine Time
        /// </summary>
        public DateTime LatestEngineTime { get; private set; }

        /// <summary>
        /// Stores Performance Information
        /// </summary>
        public List<PerformanceInformation> PerformanceInformation { get; private set; }

        /// <summary>
        /// Returns a value between 10 and 100% indicating how many of the call.route message are being processed
        /// </summary>
        int INode.ProcessingPercentage
        {
            get
            {
                return this.connection.ProcessingPercentage;
            }
        }

        #endregion Properties

        #region Methods

        /// <summary>
        /// Connects Yate Node
        /// </summary>
        /// <param name="targetBuffer">Buffer to write messages into</param>
        /// <returns>Returns value indicating whether connection was successful or not</returns>
        public async Task<bool> Connect(ActionBlock<Message> targetBuffer)
        {
            logger.Debug("Opening new connection");

            this.connection = new Connection(this, targetBuffer);

            var connected = await this.connection.Connect();
            if (connected)
            {
                logger.Debug("Connected to: {0}", IPAddress.ToString());
            }
            else
            {
                logger.Debug("Connecting failed");
            }

            return connected;
        }

        /// <summary>
        /// Disconnects Yate Node
        /// </summary>
        /// <returns>Returns Task to wait for until disconnect finished</returns>
        async Task INode.Disconnect()
        {

            if (this.connection == null)
            {
                return;
            }

            await this.connection.Disconnect(true);

            this.PerformanceInformation = null;
        }

        /// <summary>
        /// Sends a message to Yate node
        /// </summary>
        /// <param name="message">Message to send</param>
        void INode.Send(Message message)
        {
            // Directly publish to yate
            if (this.IsConnected)
            {
                this.connection.Send(message);
            }
        }

        /// <summary>
        /// Sets latest Engine Time
        /// </summary>
        /// <param name="latest">Datetime of engine.timer message</param>
        public void SetLatestEngineTime(DateTime latest)
        {
            this.LatestEngineTime = latest;
        }

        /// <summary>
        /// Adds Load Information to Node
        /// </summary>
        /// <param name="loadInformation">See <see cref="Model.PerformanceInformation"/></param>
        void INode.AddPerformance(PerformanceInformation loadInformation)
        {
            this.PerformanceInformation.ForEach((item) =>
            {
                if (item.RecordedOn < DateTime.UtcNow.AddDays(-7))
                {
                    this.PerformanceInformation.Remove(item);
                }
            });

            this.PerformanceInformation.Add(loadInformation);
        }

        /// <summary>
        /// Returns true, if load is above threshold in 1m and 5m average and CpuIdle is less then 100 - threshold
        /// </summary>
        /// <returns>True, if <see cref="CriticalLoadThreshold"/> is hit, else false</returns>
        internal bool IsLoadCritical()
        {
            // calculate average load fpr 1 and 5 minutes
            var loadAverage1Data = this.PerformanceInformation.Where(pi => pi.RecordedOn > DateTime.UtcNow.AddMinutes(-1));
            var loadAverage5Data = this.PerformanceInformation.Where(pi => pi.RecordedOn > DateTime.UtcNow.AddMinutes(-5));

            // check if values exist or use pseudo values
            decimal sum1 = loadAverage1Data.Sum(pi => pi.CpuUsage);
            int count1 = loadAverage1Data.Count();
            if (sum1 == 0)
            {
                sum1 = 1;
            }
            decimal total1 = count1 == 0 ? sum1 : count1;

            decimal sum5 = loadAverage5Data.Sum(pi => pi.CpuUsage);
            int count5 = loadAverage5Data.Count();
            if (sum5 == 0)
            {
                sum5 = 1;
            }
            decimal total5 = count5 == 0 ? sum5 : count5;

            decimal loadAverage1 = sum1 / total1;
            decimal loadAverage5 = sum5 / total5;

            // evaluate
            return loadAverage1 > this.CriticalLoadThreshold && loadAverage5 > this.CriticalLoadThreshold;
        }

        /// <summary>
        /// Sets a new value for the critical load property
        /// </summary>
        /// <param name="load"></param>
        public void SetCriticalLoad(int load)
        {
            if (this.CriticalLoadThreshold != load)
            {
                logger.Info($"Node {this.Id} changed critical load threshold from {this.CriticalLoadThreshold} to {load}.");
                this.CriticalLoadThreshold = load;
            }
        }


        #region Overrides

        /// <summary>
        /// Returns Endoint information in form IP:PORT
        /// </summary>
        /// <returns></returns>
        public override string ToString()
        {
            return String.Concat(IPAddress.ToString(), ";", Port);
        }

        /// <summary>
        /// Compares two Nodes by comparing their ID
        /// </summary>
        /// <param name="obj"></param>
        /// <returns></returns>
        public override bool Equals(object obj)
        {
            return (Id == (obj as Node).Id);
        }

        /// <summary>
        /// Serves as comparism of Nodes by using their hashcoded ID
        /// </summary>
        /// <returns></returns>
        public override int GetHashCode()
        {
            return Id.GetHashCode();
        }

        #endregion Overrides

        #region Disposing

        ~Node()
        {
            // Finalizer calls Dispose(false)
            Dispose(false);
        }

        public void Dispose()
        {
            Dispose(true);
            GC.SuppressFinalize(this);
        }

        protected virtual void Dispose(bool disposing)
        {
            if (!this.disposed && disposing)
            {
                // free managed resources
                if (this.connection != null)
                {
                    if (this.connection.IsConnected)
                    {
                        this.connection.Disconnect(false).Wait();
                    }
                }

                this.connection.Dispose();
                this.connection = null;

                this.PerformanceInformation = null;
            }

            this.disposed = true;
        }

        #endregion Disposing

        #endregion Methods
    }
}