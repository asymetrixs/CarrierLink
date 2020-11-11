namespace CarrierLink.Controller.EngineConsole
{
    using Microsoft.Extensions.Configuration;
    using NLog;
    using System;
    using System.Threading;
    using System.Threading.Tasks;

    public class Program
    {
        private static void Main(string[] args)
        {
            Console.Title = "CarrierLink Controller";

            // Configure application
            var configurationBuilder = new ConfigurationBuilder();
            configurationBuilder.AddJsonFile("appsettings.json", optional: false, reloadOnChange: false);
            LogManager.LoadConfiguration("nlog.config");

            var logger = LogManager.GetCurrentClassLogger();
            logger.Info(">>> Setup...");

            // Configure cleanup
            var stopped = new ManualResetEventSlim();            
            Console.CancelKeyPress += (sender, eventArgs) =>
            {
                // Shutdown application
                logger.Info(">>> Shutdown initiated.");
                Engine.Core.ShutdownAsync().Wait();
                logger.Info(">>> Shutdown complete.");

                stopped.Set();

                Environment.Exit(0);
            };

            // Start application
            logger.Info(">>> Starting.");
            Engine.Core.StartupAsync(configurationBuilder.Build()).Wait();
            logger.Info(">>> Done Starting.");


            logger.Info(">>> Running, CTRL+C to exit");
            
            while (!stopped.IsSet)
            {
                // TODO: gather statistics
                Task.Delay(1000).Wait();
            }            
        }
    }
}