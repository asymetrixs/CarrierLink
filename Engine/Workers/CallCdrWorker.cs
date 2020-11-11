namespace CarrierLink.Controller.Engine.Workers
{
    using Caching;
    using Caching.Model;
    using Database;
    using Model;
    using Newtonsoft.Json;
    using System;
    using System.Linq;
    using System.Net;
    using System.Threading.Tasks;
    using Yate;
    using Yate.Messaging;

    /// <summary>
    /// This class handles call.cdr messages
    /// </summary>
    internal class CallCdrWorker : AbstractAnswerWorker, IWorker
    {
        #region Fields

        /// <summary>
        /// Holds CDR Data
        /// </summary>
        private CallDataRecord callDataRecord;

        /// <summary>
        /// Tracks the call leg
        /// </summary>
        private Model.CallLegTracking callLegInfo;

        /// <summary>
        /// Holds the Database
        /// </summary>
        private IDatabase database;

        /// <summary>
        /// Indicates whether message is handled or not
        /// </summary>
        private bool isHandled;

        #endregion Fields

        #region Constructor

        /// <summary>
        /// Initializes a new instance of the <see cref="CallCdrWorker"/> class.
        /// </summary>
        internal CallCdrWorker()
        {
            this.database = Pool.Database.Get();
            this.callDataRecord = new CallDataRecord();
        }

        #endregion Constructor

        #region Methods

        /// <summary>
        /// Starts the processing of the Yate-Message
        /// </summary>
        /// <param name="message">Yate Message</param>
        /// <param name="isRunning">Indicator if service is running</param>
        /// <returns>Returns processes message</returns>
        async Task<Message> IWorker.ProcessAsync(Message message, bool isRunning)
        {
            this.Initialize(message, isRunning);
            this.callDataRecord.CLNodeId = message.Node.Id;

            this._Parse();

            if (this.IsRunning)
            {
                await this._Process();
            }
            else
            {
                this.isHandled = false;
                this._Acknowledge();
            }

            this.Reset();

            return this.Message;
        }

        /// <summary>
        /// Resets object fields
        /// </summary>
        internal void Reset()
        {
            this.callDataRecord.Reset();
        }

        /// <summary>
        /// Informs yate about handling
        /// </summary>
        /// <param name="handled">True if message should be acknowledged as handled</param>
        protected override void _Acknowledge()
        {
            this.Message.SetOutgoing(this.Node, MessageDirection.OutgoingAnswer, string.Format(Formats.CultureInfo, MessageTemplates.CALL_DATA_RECORD_ACKNOWLEDGE, this.MessageID, this.isHandled.ToString(Formats.CultureInfo).ToLowerInvariant()));
        }

        /// <summary>
        /// Parses the statements from yate into C# object
        /// </summary>
        private void _Parse()
        {
            var values = Messages.Skip(4).ToArray();

            string rtpAddress = string.Empty;
            string rtpPort = string.Empty;
            string operation = string.Empty;
            string runid = string.Empty;

            int pos = 0;
            string yateParameter = string.Empty;
            string yateValue = string.Empty;

            foreach (var value in values)
            {
                pos = value.IndexOf('=');

                // ignore everything without =
                if (pos == -1)
                {
                    continue;
                }

                yateParameter = value.Substring(0, pos);

                // Check if has value
                if (pos <= value.Length - 1)
                {
                    yateValue = CharacterCoding.Decode(value.Substring(pos + 1));
                }
                else
                {
                    continue;
                }

                switch (yateParameter)
                {
                    case "runid":
                        runid = yateValue;
                        break;

                    case "operation":
                        operation = yateValue;
                        break;

                    case "time":
                        this.callDataRecord.YYateTime = decimal.Parse(yateValue, Formats.CultureInfo);
                        this.callDataRecord.CLSQLTime = new DateTime(1970, 1, 1, 0, 0, 0, 0, System.DateTimeKind.Utc).AddSeconds((double)this.callDataRecord.YYateTime);
                        break;

                    case "billid":
                        this.callDataRecord.YBillId = yateValue;
                        break;

                    case "chan":
                        this.callDataRecord.YChan = yateValue;
                        break;

                    case "address":
                        this.callDataRecord.YAddress = new IPEndPoint(IPAddress.Parse(yateValue.Substring(0, yateValue.IndexOf(':'))), int.Parse(yateValue.Substring(yateValue.IndexOf(':') + 1), Formats.CultureInfo));
                        break;

                    case "caller":
                        this.callDataRecord.YCaller = yateValue;
                        break;

                    case "callername":
                        this.callDataRecord.YCallername = yateValue;
                        break;

                    case "called":
                        this.callDataRecord.YCalled = yateValue;
                        break;

                    case "status":
                        this.callDataRecord.YStatus = yateValue;
                        break;

                    case "reason":
                        this.callDataRecord.YReason = yateValue;
                        break;

                    case "ended":
                        this.callDataRecord.YEnded = bool.Parse(yateValue);
                        break;

                    case "format":
                        this.callDataRecord.YFormat = yateValue;
                        break;

                    case "formats":
                        this.callDataRecord.YFormats = yateValue;
                        break;

                    case "rtp_addr":
                        rtpAddress = yateValue;
                        break;

                    case "rtp_port":
                        rtpPort = yateValue;
                        break;

                    case "rtp_forward":
                        this.callDataRecord.YRTPForward = bool.Parse(yateValue);
                        break;

                    case "billtime":
                        // Convert from Second.Millisecond to Millisecond
                        this.callDataRecord.YBilltime = (long)(decimal.Parse(yateValue, Formats.CultureInfo) * 1000);
                        break;

                    case "ringtime":
                        this.callDataRecord.YRingtime = (long)(decimal.Parse(yateValue, Formats.CultureInfo) * 1000);
                        break;

                    case "duration":
                        this.callDataRecord.YDuration = (long)(decimal.Parse(yateValue, Formats.CultureInfo) * 1000);
                        break;

                    case "direction":
                        if(yateValue == "incoming")
                        {
                            this.callDataRecord.YDirection = Direction.Incoming;
                        }
                        else
                        {
                            this.callDataRecord.YDirection = Direction.Outgoing;
                        }
                        break;

                    case "cause_q391":
                        this.callDataRecord.YCauseQ931 = yateValue;
                        break;

                    case "error":
                        this.callDataRecord.YError = yateValue;
                        break;

                    case "cause_sip":
                        this.callDataRecord.YCauseSIP = yateValue;
                        break;

                    case "sip_user_agent":
                    case "sip_server":
                        // Set value of whatever comes first, if first is empty, second will be used automatically in second run
                        if (string.IsNullOrEmpty(this.callDataRecord.YSIPUserAgent))
                        {
                            this.callDataRecord.YSIPUserAgent = yateValue;
                        }

                        break;

                    case "sip_x_asterisk_hangupcause":
                        this.callDataRecord.YSIPXAsteriskHangupCause = yateValue;
                        break;

                    case "sip_x_asterisk_hangupcausecode":
                        this.callDataRecord.YSIPXAsteriskHangupCode = yateValue;
                        break;

                    case "clgatewayaccountid":
                        if (!string.IsNullOrEmpty(yateValue))
                        {
                            this.callDataRecord.CLGatewayAccountId = int.Parse(yateValue, Formats.CultureInfo);
                        }

                        break;

                    case "clgatewayipid":
                        if (!string.IsNullOrEmpty(yateValue))
                        {
                            this.callDataRecord.CLGatewayIPId = int.Parse(yateValue, Formats.CultureInfo);
                        }

                        break;

                    case "clcustomeripid":
                        if (!string.IsNullOrEmpty(yateValue))
                        {
                            this.callDataRecord.CLCustomerIPId = int.Parse(yateValue, Formats.CultureInfo);
                        }

                        break;

                    case "clgatewayid":
                        if (!string.IsNullOrEmpty(yateValue))
                        {
                            this.callDataRecord.CLGatewayId = int.Parse(yateValue, Formats.CultureInfo);
                        }

                        break;

                    case "clcustomerid":
                        if (!string.IsNullOrEmpty(yateValue))
                        {
                            this.callDataRecord.CLCustomerId = int.Parse(yateValue, Formats.CultureInfo);
                        }

                        break;

                    case "cltrackingid":
                        this.callDataRecord.CLTrackingId = yateValue;
                        break;

                    case "clwaitingtime":
                        if (!string.IsNullOrEmpty(yateValue))
                        {
                            this.callDataRecord.CLWaitingTime = int.Parse(yateValue, Formats.CultureInfo);
                        }

                        break;

                    case "clprocessingtime":
                        if (!string.IsNullOrEmpty(yateValue))
                        {
                            this.callDataRecord.CLProcessingTime = int.Parse(yateValue, Formats.CultureInfo);
                        }

                        break;

                    case "cltechcalled":
                        this.callDataRecord.CLTechCalled = yateValue;
                        break;

                    case "clcustomerpriceid":
                        if (!string.IsNullOrEmpty(yateValue))
                        {
                            this.callDataRecord.CLCustomerRateId = long.Parse(yateValue, Formats.CultureInfo);
                        }

                        break;

                    case "clcustomerpricepermin":
                        if (!string.IsNullOrEmpty(yateValue))
                        {
                            this.callDataRecord.CLCustomerRatePerMin = decimal.Parse(yateValue, Formats.CultureInfo);
                        }

                        break;

                    case "clcustomercurrency":
                        this.callDataRecord.CLCustomerCurrency = yateValue;
                        break;

                    case "clgatewaypriceid":
                        if (!string.IsNullOrEmpty(yateValue))
                        {
                            this.callDataRecord.CLGatewayRateId = long.Parse(yateValue, Formats.CultureInfo);
                        }

                        break;

                    case "clgatewaypricepermin":
                        if (!string.IsNullOrEmpty(yateValue))
                        {
                            this.callDataRecord.CLGatewayRatePerMin = decimal.Parse(yateValue, Formats.CultureInfo);
                        }

                        break;

                    case "clgatewaycurrency":
                        this.callDataRecord.CLGatewayCurrency = yateValue;
                        break;

                    case "cldialcodemasterid":
                        this.callDataRecord.CLDialcodeMasterId = int.Parse(yateValue, Formats.CultureInfo);
                        break;

                    default:
                        break;
                }
            }

            if (!string.IsNullOrEmpty(rtpAddress))
            {
                this.callDataRecord.YRTPAddress = new IPEndPoint(IPAddress.Parse(rtpAddress), int.Parse(rtpPort, Formats.CultureInfo));
            }

            this.callLegInfo = new Model.CallLegTracking()
            {
                Ended = this.callDataRecord.YEnded,
                EndedOn = this.callDataRecord.CLSQLTime.AddMilliseconds(this.callDataRecord.YDuration),
                Identifier = $"{runid}-{this.callDataRecord.YBillId}-{this.callDataRecord.YChan}",
                Operation = operation,
                Status = this.callDataRecord.YStatus,
                Direction = this.callDataRecord.YDirection
            };
        }

        /// <summary>
        /// Processes the CDR
        /// </summary>
        /// <returns>Returns task to wait for</returns>
        private async Task _Process()
        {
            // Calculate Gatway Price
            if (this.callDataRecord.CLGatewayRatePerMin.HasValue)
            {
                this.callDataRecord.CLGatewayRateTotal = this.callDataRecord.CLGatewayRatePerMin * (((decimal)this.callDataRecord.YBilltime) / 1000 / 60);
            }

            // Calculate Customer Price
            if (this.callDataRecord.CLCustomerRatePerMin.HasValue)
            {
                this.callDataRecord.CLCustomerRateTotal = this.callDataRecord.CLCustomerRatePerMin * (((decimal)this.callDataRecord.YBilltime) / 1000 / 60);
            }

            /// Retrieve routing tree prepared in <see cref="CallRouteWorker"/> if CDR is of incoming leg
            Utilities.RoutingTree.Root routingTree = null;

            if (callDataRecord.YDirection == Direction.Incoming)
            {                
                object data;
                string key = $"routingTree-{this.Node.Id}-{this.callDataRecord.YBillId}";

                data = LiveCache.Get(key);
                if (data != null && data is Utilities.RoutingTree.Root)
                {
                    routingTree = data as Utilities.RoutingTree.Root;
                }

                if (this.callDataRecord.YEnded)
                {
                    LiveCache.Remove(key);
                }

                if (routingTree != null)
                {
                    this.callDataRecord.RoutingTree = JsonConvert.SerializeObject(routingTree, Formatting.None);
                }
            }

            this.isHandled = await this.database.WriteCDR(this.callDataRecord).ConfigureAwait(false);
            this._Acknowledge();
        }

        #endregion Methods
    }
}