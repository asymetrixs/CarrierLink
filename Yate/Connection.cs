namespace CarrierLink.Controller.Yate
{
    using Messaging;
    using NLog;
    using System;
    using System.Collections.Concurrent;
    using System.IO;
    using System.Net.Sockets;
    using System.Text;
    using System.Threading;
    using System.Threading.Tasks;
    using System.Threading.Tasks.Dataflow;

    /// <summary>
    /// This class established the connection to Yate
    /// </summary>
    internal class Connection : IDisposable
    {
        #region Fields

        /// <summary>
        /// Processes messaging from yate
        /// </summary>
        private Task receiverTask;

        /// <summary>
        /// Processes messaging from yate
        /// </summary>
        private Task senderTask;

        /// <summary>
        /// Controls Receiver Thread
        /// </summary>
        private CancellationTokenSource receiveCTS;

        /// <summary>
        /// Controls Sender Thread
        /// </summary>
        private CancellationTokenSource sendCTS;

        /// <summary>
        /// State of disposal
        /// </summary>
        private bool disposed;

        /// <summary>
        /// TCP Client
        /// </summary>
        private TcpClient client;

        /// <summary>
        /// Logger
        /// </summary>
        private Logger logger;

        /// <summary>
        /// Incoming messages buffer
        /// </summary>
        private ITargetBlock<Message> processingMessageBuffer;

        /// <summary>
        /// Connected node
        /// </summary>
        private Node node;

        /// <summary>
        /// The stream to yate
        /// </summary>
        private NetworkStream networkStream;


        /// <summary>
        /// Counts messages going to Yate
        /// </summary>
        private long outMessageCounter;

        /// <summary>
        /// Countes messages coming from Yate
        /// </summary>
        private long inMessageCounter;

        /// <summary>
        /// Buffer for Messages that need to be send to yate
        /// </summary>
        private BlockingCollection<Message> outgoingBuffer;

        /// <summary>
        /// Indicates how many of the incoming messages are being processed (11 = 100%)
        /// </summary>
        private bool[] processPercentage = new bool[] { true, true, true, true, true, true, true, true, true, true };

        /// <summary>
        /// Index to resolv value if message needs to be processed or not
        /// </summary>
        private int processingIndex = 10;

        #endregion Fields

        #region Constructor

        /// <summary>
        /// Constructs the object
        /// </summary>
        /// <param name="node">Yate node information</param>
        /// <param name="messageBuffer">Buffer block to send incoming messages to</param>
        internal Connection(Node node, ITargetBlock<Message> messageBuffer)
        {
            logger = LogManager.GetLogger(GetType().FullName);
            logger.Debug("Setup connector");

            State = ConnectionState.None;
            disposed = false;
            processingMessageBuffer = messageBuffer;
            this.node = node;
            logger.Debug("Setup connector done");
            outgoingBuffer = new BlockingCollection<Message>();

            outMessageCounter = 0;
            inMessageCounter = 0;
        }

        #endregion Constructor

        #region Properties

        /// <summary>
        /// Connection State
        /// </summary>
        internal ConnectionState State { get; private set; }

        /// <summary>
        /// Exposes the TCP connection state
        /// </summary>
        internal bool IsConnected
        {
            get
            {
                return client == null ? false : (client.Connected && this.networkStream.CanRead && this.networkStream.CanWrite);
            }
        }

        /// <summary>
        /// Returns time when last message was received
        /// </summary>
        internal DateTime LastMessageReceived { get; private set; }

        /// <summary>
        /// Returns number of queued messages
        /// </summary>
        internal int OutputBufferLength
        {
            get
            {
                return outgoingBuffer.Count;
            }
        }

        /// <summary>
        /// Returns a value between 10 and 100% indicating how many of the call.route message are being processed
        /// </summary>
        internal int ProcessingPercentage
        {
            get
            {
                return this.processingIndex * 10;
            }
        }

        #endregion Properties

        #region Methods

        #region Connect / Disconnect

        /// <summary>
        /// Connects to yate
        /// </summary>
        internal async Task<bool> Connect()
        {
            logger.Debug("Connecting");

            State = ConnectionState.ConnectRequested;

            try
            {
                client = new TcpClient();

                await client.ConnectAsync(node.IPAddress, node.Port);

                networkStream = client.GetStream();

                // Set timeout so that Read() returns regulary
                networkStream.ReadTimeout = 5000;

                LastMessageReceived = DateTime.UtcNow;
            }
            catch (Exception ex)
            {
                State = ConnectionState.Disconnected;
                logger.Debug(ex);

                return false;
            }

            logger.Debug("Connected");

            State = ConnectionState.Connected;

            // Cancellation tokens for send/receive tasks
            receiveCTS = new CancellationTokenSource();
            receiverTask = Task.Run(() => _Receive(), receiveCTS.Token);

            sendCTS = new CancellationTokenSource();
            senderTask = Task.Run(() => _Send(), sendCTS.Token);

            return true;
        }

        /// <summary>
        /// Disconnects from yate
        /// </summary>
        internal async Task Disconnect(bool clean)
        {
            logger.Debug("Disconnecting");

            State = ConnectionState.DisconnectRequested;

            // Cancel reception of messages, handlers are uninstalled
            if (!receiveCTS.IsCancellationRequested)
            {
                receiveCTS.Cancel();
            }

            // Wait until is empty
            int waitSpin = 0;
            while ((outgoingBuffer.Count > 0 || (inMessageCounter != outMessageCounter)) && client.Connected)
            {
                await Task.Delay(100);

                // Wait 11 Seconds till break, messages older than 10s are being discarded anyway
                if (++waitSpin > 110)
                {
                    break;
                }
            }

            // Signal that adding is complete
            outgoingBuffer.CompleteAdding();

            // Time to process messages in queue
            if (!sendCTS.IsCancellationRequested)
            {
                sendCTS.CancelAfter(5000);
                sendCTS.Token.WaitHandle.WaitOne();
            }

            try
            {
                Task.WaitAll(senderTask);
                Task.WaitAll(receiverTask);
            }
            catch
            {
            }

            try { receiveCTS.Dispose(); } catch { }

            try { sendCTS.Dispose(); } catch { }

            receiverTask = null;
            senderTask = null;


            if (client.Connected)
            {
                networkStream.Close();
                client.Close();
            }

            networkStream = null;
            client = null;

            State = ConnectionState.Disconnected;

            logger.Debug("Disconnected");
        }

        #endregion

        #region Send / Receive

        /// <summary>
        /// Receives a message and queues it for sending to Yate
        /// </summary>
        /// <param name="message">Message to send</param>
        internal void Send(Message message)
        {
            if (outgoingBuffer != null && !outgoingBuffer.IsAddingCompleted)
            {
                outgoingBuffer.Add(message);
            }
        }

        /// <summary>
        /// Sends message data to yate
        /// </summary>
        /// <param name="message"></param>
        /// <returns></returns>
        private void _Send()
        {
            Message message;
            while (networkStream.CanWrite && !sendCTS.IsCancellationRequested && !outgoingBuffer.IsCompleted)
            {
                try
                {
                    message = outgoingBuffer.Take(sendCTS.Token);
                    networkStream.Write(message.OutgoingMessageBytes, 0, message.OutgoingMessageBytes.Length);

                    outMessageCounter++;

#if DEBUG
                    if (outMessageCounter % 10000 == 0)
                    {
                        logger.Debug($"Message Counter for {node.Id} (S): in {inMessageCounter} / out {outMessageCounter}");
                    }
#endif

                    logger.ConditionalTrace("SEND >> " + message.OutgoingMessage.Substring(0, message.OutgoingMessage.Length - 1));
                }
                catch (Exception ex) when (ex is TaskCanceledException || ex is InvalidOperationException || ex is OperationCanceledException)
                {
                    break;
                }
                catch
                {
                    continue;
                }
            }

#if DEBUG
            logger.Debug($"Message Counter for {node.Id} (S): in {inMessageCounter} / out {outMessageCounter}");
#endif
        }

        /// <summary>
        /// Receives messages from yate
        /// </summary>
        private void _Receive()
        {
            var receiveByte = new byte[256];
            var receivedText = new StringBuilder();
            Message incomingMessage;
            string message = String.Empty;
            int newLinePos = 0;
            int bufferRead;

            while (!receiveCTS.IsCancellationRequested && networkStream.CanRead && !outgoingBuffer.IsCompleted)
            {
                try
                {
                    bufferRead = this.networkStream.Read(receiveByte, 0, receiveByte.Length);
                    receivedText.Append(Encoding.ASCII.GetString(receiveByte, 0, bufferRead));
                    message = receivedText.ToString();

                    this.LastMessageReceived = DateTime.UtcNow;

                    while ((newLinePos = message.IndexOf("\n")) > -1)
                    {
                        inMessageCounter++;

                        incomingMessage = new Message();
                        incomingMessage.SetIncoming(node, message.Substring(0, newLinePos));

                        // Check load every 100 messages
                        if (inMessageCounter % 100 == 0)
                        {
                            if (this.node.IsLoadCritical())
                            {
                                if (this.processingIndex > 1)
                                {
                                    this.processingIndex--;
                                    this.processPercentage[this.processingIndex] = false;                                    
                                }
                            }
                            else
                            {
                                if (this.processingIndex < 10)
                                {
                                    this.processPercentage[this.processingIndex] = true;
                                    this.processingIndex++;
                                }
                            }
                        }

                        // if message can be cancelled, check if limited processing is active
                        if (incomingMessage.CanBeCancelled)
                        {
                            // if true, message is processed, if false, message is returned (see else)
                            if (this.processPercentage[inMessageCounter % 10])
                            {
                                processingMessageBuffer.Post(incomingMessage);
                            }
                            else
                            {
                                // Cancel call.route message and push back to yate
                                incomingMessage.CancelCallRouteMessage();
                                this.Send(incomingMessage);
                            }
                        }
                        else
                        {
                            processingMessageBuffer.Post(incomingMessage);
                        }

#if DEBUG
                        if (inMessageCounter % 10000 == 0)
                        {
                            logger.Debug($"Message Counter for {node.Id} (R): in {inMessageCounter} / out {outMessageCounter}");
                        }
#endif

                        logger.ConditionalTrace("RECV << " + incomingMessage.IncomingOriginalMessage);

                        receivedText = receivedText.Remove(0, newLinePos + 1);
                        message = receivedText.ToString();
                    }
                }
                catch (IOException)
                {
                    if (receiveCTS.IsCancellationRequested)
                    {
                        break;
                    }
                    else
                    {
                        continue;
                    }
                }
                catch (TimeoutException)
                {
                    continue;
                }
                catch (TaskCanceledException)
                {
                    break;
                }
                catch
                {
                    if (!receiveCTS.IsCancellationRequested)
                    {
                        break;
                    }
                }
            }
#if DEBUG
            logger.Debug($"Message Counter for {node.Id} (R): in {inMessageCounter} / out {outMessageCounter}");
#endif
        }

        #endregion Send / Receive

        #region Disposing

        ~Connection()
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
            if (!disposed && disposing)
            {
                // free managed resources
                if (client != null)
                {
                    if (client.Connected)
                    {
                        networkStream.Close();
                        client.Close();
                    }

                    networkStream.Dispose();
                    client.Dispose();

                    networkStream = null;
                    client = null;
                }
            }

            outgoingBuffer.Dispose();
            outgoingBuffer = null;
            disposed = true;
        }

        #endregion Disposing

        #endregion Methods
    }
}