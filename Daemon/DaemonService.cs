namespace CarrierLink.Controller.Daemon
{
    using Microsoft.Extensions.Configuration;
    using Microsoft.Extensions.Hosting;
    using Microsoft.Extensions.Logging;
    using System.Threading;
    using System.Threading.Tasks;

    public class DaemonService : IHostedService
    {
        #region Fields

        private readonly ILogger _logger;
        private readonly IConfigurationRoot _config;

        #endregion

        #region Constructor

        public DaemonService(ILogger<DaemonService> logger, IConfigurationRoot config)
        {
            this._logger = logger;
            this._config = config;
        }

        #endregion

        #region Methods

        public async Task StartAsync(CancellationToken cancellationToken)
        {
            this._logger.LogInformation("Starting daemon.");

            await Engine.Core.StartupAsync(this._config);

            this._logger.LogInformation("Started daemon.");
        }

        public async Task StopAsync(CancellationToken cancellationToken)
        {
            this._logger.LogInformation("Stopping daemon.");

            await Engine.Core.ShutdownAsync();

            this._logger.LogInformation("Stopped daemon.");
        }

        #endregion
    }
}
