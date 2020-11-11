namespace CarrierLink.Controller.YateSimulator
{
    using Microsoft.Extensions.Configuration;
    using System;
    using System.Collections.Generic;
    using System.Net;
    using System.Net.Sockets;
    using System.Runtime.Loader;
    using System.Threading;
    using System.Threading.Tasks;

    class Program
    {
        #region Fields

        /// <summary>
        /// Holds handlers
        /// </summary>
        private static ICollection<Handler> handlers = new List<Handler>();

        private static CancellationTokenSource cancellationTokenSource = new CancellationTokenSource();

        private static TcpListener tcpServer;

        private static Task simulator;

        private static ManualResetEventSlim waiter = new ManualResetEventSlim();

        private static bool unloading = false;

        #endregion

        #region Functions

        private static void Main(string[] args)
        {
            Console.Title = "CarrierLink Yate Simulator";

            // Capture application unloading
            AssemblyLoadContext.Default.Unloading += ctx =>
            {
                Shutdown(null, null);
            };

            Console.CancelKeyPress += (sender, eventArgs) =>
            {
                Shutdown(sender, eventArgs);
                Environment.Exit(0);
            };


            // Configuration
            var configurationBuilder = new ConfigurationBuilder();
            configurationBuilder.AddJsonFile("appsettings.json", optional: false, reloadOnChange: false);
            var config = configurationBuilder.Build();

            // Read configuration
            string ip = config.GetSection("Simulator").GetValue<string>("Ip");
            int port = config.GetSection("Simulator").GetValue<int>("Port");
            tcpServer = new TcpListener(new IPEndPoint(IPAddress.Parse(ip), port));
            tcpServer.Start();


            Console.WriteLine("Running...");
            Console.WriteLine(">>> Running, CTRL+C to exit");

            int totalMessagesToSend = config.GetSection("Simulator").GetValue<int>("TotalMessages");
            int delay = config.GetSection("Simulator").GetValue<int>("Delay");
            int messageBatchSize = config.GetSection("Simulator").GetValue<int>("MessageBatchSize");

            Console.WriteLine($"Total: {totalMessagesToSend} - Delay: {delay} - Message Batch Size: {messageBatchSize}");

            // Start simulating
            simulator = Task.Run(async () =>
            {
                while (!cancellationTokenSource.IsCancellationRequested)
                {
                    Console.Write("\rRunning: {0}", DateTime.Now.Second);
                    // Check for pending connection requests
                    if (tcpServer.Pending())
                    {
                        var tcpClient = tcpServer.AcceptTcpClient();

                        var handler = new Handler(tcpClient, totalMessagesToSend, delay, messageBatchSize, config.GetConnectionString("CarrierLink"));
                        handlers.Add(handler);

#pragma warning disable CS4014 // Because this call is not awaited, execution of the current method continues before the call is completed
                        Task.Run(async () => await handler.WaitForResultsAsync().ConfigureAwait(false));
#pragma warning restore CS4014 // Because this call is not awaited, execution of the current method continues before the call is completed
                    }

                    // Pause loop for a second, then check for pending connection requests again
                    await Task.Delay(1000, cancellationTokenSource.Token);
                }
            }, cancellationTokenSource.Token);

            waiter.Wait();
        }
        
        /// <summary>
        /// Shutdown function with resource cleanup
        /// </summary>
        /// <param name="sender"></param>
        /// <param name="e"></param>
        private static void Shutdown(object sender, ConsoleCancelEventArgs e)
        {
            if(unloading)
            {
                return;
            }

            unloading = true;

            foreach (var handler in handlers)
            {
                handler.Cancel();
            }

            cancellationTokenSource.Cancel();
            
            while (!simulator.IsCompleted)
            {
                Console.WriteLine("Waiting for task to finish.");
                Task.Delay(1000).Wait();
            }

            waiter.Set();

            System.Diagnostics.Debug.WriteLine("Shutdown complete");            
        }

        #endregion
    }
}
