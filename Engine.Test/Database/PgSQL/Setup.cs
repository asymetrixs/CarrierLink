namespace CarrierLink.Controller.Engine.Test.Database.PgSQL
{
    using Microsoft.Extensions.Configuration;
    using Npgsql;
    using System;
    using System.Data;
    using System.IO;
    using System.Reflection;
    using System.Threading.Tasks;

    internal static class Setup
    {
        #region Fields

        private static string _connectionStringPgSQL;

        internal static string ConnectionStringVoipTest { get; private set; }

        internal static string ConnectionStringController { get; private set; }

        #endregion

        #region Static Constructor

        static Setup()
        {
            // Configure application
            var configurationBuilder = new ConfigurationBuilder();
            configurationBuilder.AddJsonFile("appsettings.json", optional: false, reloadOnChange: false);
            var config = configurationBuilder.Build();

            _connectionStringPgSQL = config.GetConnectionString("PostgreSQL");
            ConnectionStringVoipTest = config.GetConnectionString("CarrierLink");
            ConnectionStringController = config.GetConnectionString("ControllerUser");
        }

        #endregion

        #region Functions

        internal static async Task Startup()
        {
            // Do cleanup
            Shutdown();

            var assembly = Assembly.GetExecutingAssembly();

            string resourceName = "CarrierLink.Controller.Engine.Test.Database.PgSQL.CreateDatabase.sql";
            string createDatabase;

            using (Stream stream = assembly.GetManifestResourceStream(resourceName))
            {
                using (StreamReader reader = new StreamReader(stream))
                {
                    createDatabase = reader.ReadToEnd();
                }
            }

            using (var connection = new NpgsqlConnection(_connectionStringPgSQL))
            {
                using (var command = new NpgsqlCommand(createDatabase, connection))
                {
                    command.CommandType = CommandType.Text;
                    try
                    {
                        await connection.OpenAsync();

                        await command.ExecuteNonQueryAsync();
                    }
                    catch
                    {
                        throw;
                    }
                    finally
                    {
                        connection.Close();
                    }
                }
            }

            // give DB time to process
            await Task.Delay(1000);

            var resources = new string[]
            {
                "CarrierLink.Controller.Engine.Test.Database.PgSQL.CreateSchema.sql",
                "CarrierLink.Controller.Engine.Test.Database.PgSQL.ApplyChanges.sql",
                "CarrierLink.Controller.Engine.Test.Database.PgSQL.AddData.sql"
            };

            // Do post changes
            foreach (var resource in resources)
            {
                string sqlCommands = string.Empty;
                using (Stream stream = assembly.GetManifestResourceStream(resource))
                {
                    using (StreamReader reader = new StreamReader(stream))
                    {
                        sqlCommands = reader.ReadToEnd();
                    }
                }

                var sqlCommandList = sqlCommands.Split(new string[] { "--GO", }, StringSplitOptions.RemoveEmptyEntries);

                foreach (var sqlCommand in sqlCommandList)
                {
                    using (var connection = new NpgsqlConnection(ConnectionStringVoipTest))
                    {
                        using (var command = new NpgsqlCommand(sqlCommand, connection))
                        {
                            command.CommandType = CommandType.Text;
                            try
                            {
                                await connection.OpenAsync();

                                await command.ExecuteNonQueryAsync();

                                await Task.Delay(100);
                            }
                            catch
                            {
                                throw;
                            }
                            finally
                            {
                                connection.Close();
                            }
                        }
                    }
                }
            }
        }

        internal static void Shutdown()
        {
            var assembly = Assembly.GetExecutingAssembly();

            string resourceName = "CarrierLink.Controller.Engine.Test.Database.PgSQL.DropDatabase.sql";

            string dropDatabase = string.Empty;

            using (Stream stream = assembly.GetManifestResourceStream(resourceName))
            {
                using (StreamReader reader = new StreamReader(stream))
                {
                    dropDatabase = reader.ReadToEnd();
                }
            }

            using (var connection = new NpgsqlConnection(_connectionStringPgSQL))
            {
                using (var command = new NpgsqlCommand(dropDatabase, connection))
                {
                    command.CommandType = CommandType.Text;
                    try
                    {
                        connection.Open();

                        command.ExecuteNonQuery();
                    }
                    catch
                    {
                        //
                    }
                    finally
                    {
                        connection.Close();
                    }
                }
            }
        }

        #endregion
    }
}