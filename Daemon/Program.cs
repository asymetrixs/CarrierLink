namespace CarrierLink.Controller.Daemon
{
    using Microsoft.Extensions.Configuration;
    using Microsoft.Extensions.DependencyInjection;
    using Microsoft.Extensions.Hosting;
    using Microsoft.Extensions.Logging;
    using NLog;
    using NLog.Extensions.Logging;
    using System.Runtime.Loader;
    using System.Threading.Tasks;
    using LogLevel = Microsoft.Extensions.Logging.LogLevel;

    class Program
    {
        static async Task Main(string[] args)
        {
            var builder = new HostBuilder()
                .ConfigureAppConfiguration((hostContext, appConfig) =>
                {
                    appConfig.AddJsonFile("appsettings.json", optional: false, reloadOnChange: false);
                })
                .ConfigureServices((hostContext, services) =>
                {
                    services.AddOptions();
                    
                    services.AddSingleton<IHostedService, DaemonService>();
                })
                .ConfigureLogging((hostContext, logger) => 
                {
                    // Setup NLog
                    logger.Services.AddSingleton<ILoggerFactory, LoggerFactory>();
                    logger.Services.AddSingleton(typeof(ILogger<>), typeof(Logger<>));
                    logger.Services.AddLogging((configure) => configure.SetMinimumLevel(LogLevel.Trace));

                    //configure NLog
                    var serviceProvider = logger.Services.BuildServiceProvider();
                    var loggerFactory = serviceProvider.GetRequiredService<ILoggerFactory>();
                    
                    loggerFactory.AddNLog(new NLogProviderOptions { CaptureMessageTemplates = true, CaptureMessageProperties = true });
                    LogManager.LoadConfiguration("nlog.config");
                })
                .Build();
            
            // Log startup
            LogManager.GetCurrentClassLogger().Info("Startup initiated.");

            AssemblyLoadContext.Default.Unloading += ctx =>
            {
                // Ensure to flush and stop internal timers/threads before application-exit (Avoid segmentation fault on Linux)
                LogManager.GetCurrentClassLogger().Info("Shutdown initiated.");
                LogManager.Shutdown();
            };

            await builder.RunAsync();
        }
    }
}
