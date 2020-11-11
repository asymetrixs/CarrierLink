namespace CarrierLink.Controller.YateSimulator
{
    using CarrierLink.Controller.YateSimulator.Models;
    using System;
    using System.Collections.Generic;
    using System.Diagnostics;
    using System.Linq;
    using System.Net.Sockets;
    using System.Text;
    using System.Threading;
    using System.Threading.Tasks;

    class Handler
    {
        #region Fields
        private string _connectionString;

        private int _handlerCount = 0;
        private int _routingMessagesAnswered = 0;
        private int _routingMessagesSent = 0;
        private int _elapsed = 0;
        private readonly int _totalMessagesToSend;
        private readonly int _delay;
        private readonly int _messageBatchSize;
        private int _old = 0;

        private double _waitingTime = 0;
        private double _processingTime = 0;

        private bool _disposed = false;

        private string _error = string.Empty;
        private string _mode = string.Empty;
        private string _priority = string.Empty;

        private TcpClient _client;

        private Stopwatch _stopWatch = new Stopwatch();

        private System.Timers.Timer _timer;

        private Task _feeder;
        private Task _receiver;

        private readonly CancellationTokenSource _feederCTS = new CancellationTokenSource();
        private readonly CancellationTokenSource _receiverCTS = new CancellationTokenSource();

        private readonly NetworkStream _stream;

        private readonly List<int> _queriesPerSecond = new List<int>();
        private readonly List<double> _waitingTimePerQuery = new List<double>();
        private readonly List<double> _processingTimePerQuery = new List<double>();

        private readonly Dictionary<string, Message> _messages = new Dictionary<string, Message>(20000);

        private SemaphoreSlim _allMessagesReturned = new SemaphoreSlim(0, 1);

        #endregion

        #region Constructor

        /// <summary>
        /// Initializes a new instance of the <see cref="Handler"/> class.
        /// </summary>
        /// <param name="client"></param>
        public Handler(TcpClient client, int totalMessages, int delay, int messageBatchSize, string connectionString)
        {
            this._totalMessagesToSend = totalMessages;
            this._delay = delay;
            this._messageBatchSize = messageBatchSize;
            this._connectionString = connectionString;

            this._client = client;
            this._stream = this._client.GetStream();
            this._receiver = Task.Run(() => ReceiveAsync());

            this._timer = new System.Timers.Timer
            {
                AutoReset = true,
                Interval = 1000
            };
            this._timer.Elapsed += this.Timer_Elapsed;
        }

        #endregion

        #region Methods

        /// <summary>
        /// Displays results
        /// </summary>
        /// <returns></returns>
        public async Task WaitForResultsAsync()
        {
            Console.WriteLine("Endpoint connected");

            await this._allMessagesReturned.WaitAsync();

            Timer_Elapsed(this, null);

            // time to finish
            await Task.Delay(2000);

            Console.WriteLine();
            Console.WriteLine("==== DONE ====");
            Console.WriteLine();
            Console.WriteLine($"Queries performed:    {this._routingMessagesSent} #");
            Console.WriteLine($"Total Duration:       {((decimal)this._stopWatch.ElapsedMilliseconds) / 1000} s");
            Console.WriteLine($"Avg. Processing Time: {Math.Round(this._processingTimePerQuery.Average(), 4)} ms/msg");
            Console.WriteLine($"Avg. Waiting Time:    {Math.Round(this._waitingTimePerQuery.Average(), 4)} ms/msg");
            Console.WriteLine($"Avg. Queries:         {Math.Round(this._routingMessagesSent / this._stopWatch.Elapsed.TotalSeconds, 1)} msg/s");
            Console.WriteLine();
        }

        /// <summary>
        /// Timer to display statistical processing information
        /// </summary>
        /// <param name="sender"></param>
        /// <param name="e"></param>
        private void Timer_Elapsed(object sender, System.Timers.ElapsedEventArgs e)
        {
            Console.Clear();
            Console.WriteLine($"Messages sent:     {this._routingMessagesSent} # ({Math.Round((double)this._routingMessagesSent * 100 / this._totalMessagesToSend)}%)");
            Console.WriteLine($"Messages awaited:  {this._routingMessagesSent - this._routingMessagesAnswered} #");
            Console.WriteLine($"Messages returned: {this._routingMessagesAnswered} #");
            Console.WriteLine($"Messages returned: {this._routingMessagesAnswered - this._old} msg/s");
            Console.WriteLine($"Waiting Time:      {this._waitingTime} ms/msg");
            Console.WriteLine($"Processing Time:   {this._processingTime} ms/msg");

            this._queriesPerSecond.Add(this._routingMessagesAnswered - this._old);
            this._old = this._routingMessagesAnswered;
            this._elapsed++;
        }

        /// <summary>
        /// Creates a new cache of call.route messages
        /// </summary>
        private async Task CreateNewCacheAsync()
        {
            var billId = (DateTime.Now - new DateTime(1970, 1, 1)).Ticks;

            var customers = await GetIPs();

            var random = new Random((int)DateTime.Now.Ticks);

            int messages = 20000;
            for (int i = 0; i < messages; i++)
            {
                var customer = customers.OrderBy(s => random.Next()).First();

                var totalSeconds = Math.Round((DateTime.Now - new DateTime(1970, 1, 1)).TotalSeconds);

                string called = customer.Prefix + GetCalled();

                if (i.ToString().StartsWith("5555"))
                {
                    continue;
                }

                if (i * 100 % messages == 0)
                {
                    Console.Write($"\rCreating messages...{Math.Round((double)i * 100 / messages)}%");
                }

                this._messages.Add((i + 10000000).ToString(), new Message()
                {
                    Id = (i + 10000000).ToString(),
                    Route = $"%%>message:{i + 10000000}:{totalSeconds}:call.route:id=sip/{i}:module=sip:status=incoming:address={customer.IP}%z5060:billid={billId}-{i}:" +
                            $"answered=false:direction=incoming:caller=anonymous:called={called}:callername=anonymous"
                });
            }
        }

        /// <summary>
        /// Starts message feeding
        /// </summary>
        /// <returns></returns>
        private async Task FeedAsync()
        {
            Console.WriteLine("Feeding");

            Console.WriteLine();

            this._stopWatch.Start();
            this._timer.Start();

            while (this._routingMessagesSent < this._totalMessagesToSend && !this._feederCTS.IsCancellationRequested)
            {
                foreach (var c in _messages)
                {
                    this.Write(c.Value.Route);
                    this._routingMessagesSent++;

                    if (_routingMessagesSent % _messageBatchSize == 0)
                    {
                        await Task.Delay(_delay);
                    }
                }
            }
        }

        /// <summary>
        /// Returns a random called number
        /// </summary>
        /// <returns></returns>
        private string GetCalled()
        {
            var rand = new Random((int)DateTime.Now.Ticks);
            var length = rand.Next(7, 14);

            string number = string.Empty;
            for (int i = 0; i < length; i++)
            {
                number += rand.Next(0, 9).ToString();
            }

            return number;
        }

        /// <summary>
        /// Returns usable and unusable IP addresses for call.route messages
        /// </summary>
        /// <returns></returns>
        private async Task<List<Customer>> GetIPs()
        {
            var list = new List<Customer>();

            using (Npgsql.NpgsqlConnection con = new Npgsql.NpgsqlConnection(this._connectionString))
            {
                using (Npgsql.NpgsqlCommand com = new Npgsql.NpgsqlCommand(@"SELECT HOST(address) AS ip, prefix FROM domain.customer_ip
                                                                            INNER JOIN customer ON customer.id = customer_ip.customer_id
                                                                            WHERE customer.enabled = TRUE AND customer_ip.enabled = TRUE
	                                                                            AND customer_id IN (SELECT DISTINCT customer_id FROM customer_price WHERE NOW() 
                                                                                                        BETWEEN valid_from AND valid_to);", con))
                {
                    try
                    {
                        com.CommandType = System.Data.CommandType.Text;

                        await con.OpenAsync();

                        using (var reader = await com.ExecuteReaderAsync(System.Data.CommandBehavior.SingleResult))
                        {
                            while (await reader.ReadAsync())
                            {
                                list.Add(new Customer()
                                {
                                    IP = reader.GetString(0),
                                    Prefix = reader.IsDBNull(1) ? string.Empty : reader.GetString(1)
                                });
                            }
                        }
                    }
                    catch (Exception ex)
                    {
                        Debug.WriteLine(ex);
                    }
                    finally
                    {
                        con.Close();
                    }
                }
            }

            return list;
        }

        /// <summary>
        /// Receives a message and processes it
        /// </summary>
        /// <param name="message"></param>
        /// <returns></returns>
        private async Task ProcessAsync(string message)
        {
            if (string.IsNullOrEmpty(message))
            {
                return;
            }

            string inOut = message.Substring(0, 3);
            string answer = string.Empty;
            string[] messages = message.Substring(3).Split(':');

            // Controller Request
            if (inOut == "%%>")
            {
                if (messages[0].StartsWith("install"))
                {
                    answer = "%%<" + message.Substring(3) + ":true";
                    this._priority = messages[1];
                    _handlerCount++;
                    this.Write(answer);

                    if (messages[2] == "call.route")
                    {
                        _mode = "route";

                        Console.Write("Creating new Cache...");

                        await CreateNewCacheAsync();

                        Console.WriteLine("done.");

                        this._feeder = Task.Run(async () =>
                        {
                            while (_handlerCount < 9)
                            {
                                await Task.Delay(500);
                            }

                            await FeedAsync().ConfigureAwait(false);
                        }
                        , this._feederCTS.Token);
                    }
                }
                else if (messages[0].StartsWith("watch"))
                {
                    answer = "%%<" + message.Substring(3) + ":true";
                    _handlerCount++;
                    this.Write(answer);
                }
                else if (messages[0].StartsWith("uninstall"))
                {
                    answer = "%%<uninstall:" + _priority + ":" + message.Split(':')[1] + ":true";
                    this.Write(answer);
                }
                else if (messages[0].StartsWith("unwatch"))
                {
                    answer = "%%<" + message.Substring(3) + ":true";
                    this.Write(answer);
                }
                else if (messages[0].StartsWith("message") && messages[3] == "cali.node")
                {
                    answer = $"%%<message:{messages[1]}:true:cali.node::name=performance:test=1";
                    this.Write(answer);
                }
            }
            else
            {
                var splitted = message.Split(':');
                if (_mode == "route")
                {
                    try
                    {
                        var pt = splitted.First(c => c.StartsWith("clprocessingtime="));
                        this._processingTime = double.Parse(pt.Substring(17));
                        var wt = splitted.First(c => c.StartsWith("clwaitingtime="));
                        this._waitingTime = double.Parse(wt.Substring(14));
                        this._processingTimePerQuery.Add(_processingTime);
                        this._waitingTimePerQuery.Add(_waitingTime);
                    }
                    catch { }
                }

                if (splitted.Count() > 5 && splitted[5].StartsWith("error"))
                {
                    this._error = splitted[5].Substring(6);
                }

                this._routingMessagesAnswered++;

                if (this._routingMessagesAnswered == this._totalMessagesToSend)
                {
                    this._allMessagesReturned.Release();
                    this._timer.Stop();
                    this._stopWatch.Stop();
                }
            }
        }

        /// <summary>
        /// Receives messages from Controller
        /// </summary>
        /// <returns></returns>
        private async Task ReceiveAsync()
        {
            var receiveByte = new byte[256];
            var receivedText = new StringBuilder();
            string message = String.Empty;
            int newLinePos = 0;
            int bufferRead;

            while (this._client.Connected && !this._receiverCTS.IsCancellationRequested)
            {
                try
                {
                    bufferRead = await this._stream.ReadAsync(receiveByte, 0, receiveByte.Length, this._receiverCTS.Token).ConfigureAwait(false);
                    receivedText.Append(Encoding.ASCII.GetString(receiveByte, 0, bufferRead));
                    message = receivedText.ToString();
                    this._receiverCTS.Token.ThrowIfCancellationRequested();

                    while ((newLinePos = message.IndexOf("\n")) > -1)
                    {
                        await this.ProcessAsync(message.Substring(0, newLinePos));

                        receivedText = receivedText.Remove(0, newLinePos + 1);
                        message = receivedText.ToString();
                    }
                }
                catch (ThreadStateException)
                {
                    // do nothing
                }
                catch (ThreadAbortException)
                {
                    // do nothing
                }
                catch
                {
                    this._feederCTS.Cancel();
                    this._timer.Stop();
                    this._stopWatch.Stop();
                    this._allMessagesReturned.Release();
                }
            }


        }


        /// <summary>
        /// Writes messages to Controller
        /// </summary>
        /// <param name="message"></param>
        /// <returns></returns>
        private void Write(string message)
        {
            var bytes = UTF8Encoding.UTF8.GetBytes(message + "\n");
            try
            {
                lock (this._stream)
                {
                    if (this._stream.CanWrite && !this._feederCTS.IsCancellationRequested)
                    {
                        this._feederCTS.Token.ThrowIfCancellationRequested();
                        this._stream.Write(bytes, 0, bytes.Length);
                    }
                }
            }
            catch (ThreadStateException)
            {
                // do nothing
            }
            catch (ThreadAbortException)
            {
                // do nothing
            }
            catch
            {
                this._receiverCTS.Cancel();
                this._timer.Stop();
                this._stopWatch.Stop();
                this._allMessagesReturned.Release();
            }
        }

        /// <summary>
        /// Cancel the feeding to exit the handler
        /// </summary>
        internal void Cancel()
        {
            if (!this._feederCTS.IsCancellationRequested)
            {
                this._feederCTS.Cancel();
            }
        }

        #endregion

        #region Disposing

        ~Handler()
        {
            Dispose(false);
        }

        public void Dispose()
        {
            Dispose(true);
            GC.SuppressFinalize(this);
        }

        protected virtual void Dispose(bool disposing)
        {
            if (!_disposed && disposing)
            {
                _timer.Dispose();

                this._receiver.Dispose();
                this._receiver = null;
            }

            _disposed = true;
        }

        #endregion Disposing
    }
}
