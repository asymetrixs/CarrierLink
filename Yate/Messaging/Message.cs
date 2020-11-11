namespace CarrierLink.Controller.Yate.Messaging
{
    using System.Diagnostics;
    using System.Linq;
    using System.Text;
    using System.Threading;

    /// <summary>
    /// This class contains the message for processing by Core and Yate
    /// </summary>
    public class Message
    {
        #region Constructor

        /// <summary>
        /// Constructs the object
        /// </summary>
        public Message()
        {
            WaitingTime = new Stopwatch();
            ProcessingTime = new Stopwatch();
        }

        #endregion Constructor

        #region Properties

        #region Common

        /// <summary>
        /// Gets value indicating if message can be cancelled
        /// </summary>
        public bool CanBeCancelled
        {
            get
            {
                return MessageDirection == MessageDirection.IncomingRequest
                    && !string.IsNullOrEmpty(MessageId)
                    && this.IncomingSplittedMessage[3] == "call.route";
            }
        }

        /// <summary>
        /// Node Endpoint
        /// </summary>
        public INode Node { get; private set; }

        /// <summary>
        /// Type of Message
        /// </summary>
        public MessageType MessageType { get; private set; }

        /// <summary>
        /// Direction of Message
        /// </summary>
        public MessageDirection MessageDirection { get; private set; }

        /// <summary>
        /// Unique message id
        /// </summary>
        public string MessageId { get; private set; }

        /// <summary>
        /// Token until processing of message is cancelled. Yate limits processing to 10s
        /// </summary>
        private CancellationTokenSource CancellationTokenSource { get; set; }

        /// <summary>
        /// Token for cancellation of processing
        /// </summary>
        public virtual CancellationToken CancellationToken
        {
            get { return this.CancellationTokenSource.Token; }
        }

        #endregion

        #region Incoming

        /// <summary>
        /// Yate Message Splitted
        /// </summary>
        public string[] IncomingSplittedMessage { get; private set; }

        /// <summary>
        /// Yate Message as original
        /// </summary>
        public string IncomingOriginalMessage { get; private set; }

        /// <summary>
        /// Id of channel that originates the message
        /// </summary>
        public string ChannelId { get; private set; }

        #endregion Incoming

        #region Outgoing

        /// <summary>
        /// Message which is sent to Yate
        /// </summary>
        public string OutgoingMessage { get; private set; }

        /// <summary>
        /// Byte representation of <paramref name="OutgoingMessage"/>
        /// </summary>
        internal byte[] OutgoingMessageBytes { get; private set; }

        #endregion Outgoing

        #region Diagnostics

        /// <summary>
        /// Time waiting before processing
        /// </summary>
        public Stopwatch WaitingTime { get; private set; }

        /// <summary>
        /// Time processing
        /// </summary>
        public Stopwatch ProcessingTime { get; private set; }

        #endregion Diagnostics

        #endregion Properties

        #region Methods

        /// <summary>
        /// Sets the message received from Yate
        /// </summary>
        /// <param name="node"></param>
        /// <param name="message"></param>
        public void SetIncoming(INode node, string message)
        {
            if (message.Substring(0, 3) == "%%<")
            {
                MessageDirection = MessageDirection.IncomingAnswer;
            }
            else
            {
                MessageDirection = MessageDirection.IncomingRequest;
            }

            Node = node;
            IncomingOriginalMessage = message;
            IncomingSplittedMessage = message.Split(':');
            if (IncomingSplittedMessage[0].Substring(3) == "message")
            {
                MessageId = IncomingSplittedMessage[1];
            }
            WaitingTime.Start();

            ChannelId = GetValue("id");
        }

        /// <summary>
        /// Prepares <see cref="OutgoingMessage"/> with handled-flag as false
        /// </summary>
        /// <returns>True, if cancellation is successful. False, if message needs processing in Controller.</returns>
        public bool CancelCallRouteMessage()
        {
            if (this.CanBeCancelled)
            {
                IncomingSplittedMessage[0] = IncomingSplittedMessage[0].Substring(3);

                this.SetOutgoing(Node, MessageDirection.OutgoingAnswer, $"{IncomingSplittedMessage[0]}:{IncomingSplittedMessage[1]}:false:{IncomingSplittedMessage[3]}::{IncomingSplittedMessage[4]}");

                return true;
            }

            return false;
        }

        /// <summary>
        /// Sets the handler type
        /// </summary>
        /// <param name="messageType"></param>
        public void SetMessageType(MessageType messageType)
        {
            MessageType = messageType;
        }

        /// <summary>
        /// Sets the message send to Yate
        /// </summary>
        /// <param name="node"></param>
        /// <param name="type"></param>
        /// <param name="message"></param>
        public void SetOutgoing(INode node, MessageDirection type, string message)
        {
            Node = node;
            OutgoingMessage = message;
            MessageDirection = type;

            if (message.StartsWith("message"))
            {
                var messageId = message.Substring(message.IndexOf(':') + 1);
                messageId = messageId.Substring(0, messageId.IndexOf(':'));
                MessageId = messageId;
            }

            switch (type)
            {
                case MessageDirection.OutgoingAnswer:
                    OutgoingMessage = string.Concat("%%<", message, "\n");
                    break;

                case MessageDirection.OutgoingRequest:
                    OutgoingMessage = string.Concat("%%>", message, "\n");
                    break;

                default:
                    OutgoingMessage = string.Empty;
                    break;
            }

            OutgoingMessageBytes = Encoding.UTF8.GetBytes(OutgoingMessage);
        }

        /// <summary>
        /// Returns the actual yate command
        /// </summary>
        /// <returns></returns>
        public override string ToString()
        {
            return OutgoingMessage;
        }

        /// <summary>
        /// Returns value of message parameter
        /// </summary>
        /// <param name="message"></param>
        /// <param name="parameter"></param>
        /// <returns></returns>
        public string GetValue(string parameter)
        {
            var values = IncomingSplittedMessage.Skip(4);

            int pos = 0;
            string yateParameter = string.Empty;
            string yateValue = string.Empty;
            foreach (var value in values)
            {
                if (!string.IsNullOrEmpty(value))
                {
                    pos = value.IndexOf('=');

                    yateParameter = value.Substring(0, pos);

                    // Check if current parameter is requested parameter
                    if (yateParameter == parameter)
                    {
                        // Check if has value
                        if (pos <= value.Length - 1)
                        {
                            yateValue = CharacterCoding.Decode(value.Substring(pos + 1));
                        }

                        break;
                    }
                }
            }

            return yateValue;
        }

        /// <summary>
        /// Sets up the Cancellation Token calculating the remaining possible time
        /// </summary>
        /// <param name="yateWaitingTime"></param>
        public void SetupCancellationToken(int yateWaitingTime)
        {
            this.CancellationTokenSource = new CancellationTokenSource(yateWaitingTime - (int)this.WaitingTime.ElapsedMilliseconds);
        }

        #endregion Methods
    }
}