namespace CarrierLink.Controller.Engine.Test.Tests
{
    using Engine.Database;
    using Microsoft.VisualStudio.TestTools.UnitTesting;
    using System.Collections.Concurrent;
    using Yate;

    /// <summary>
    /// This class sets up the testing environment
    /// </summary>
    [TestClass]
    public class SetupTest
    {
        internal static ConcurrentDictionary<int, INode> RegisteredNodes;

        #region Initialize / Cleanup

        [AssemblyInitialize]
        public static void Initialize(TestContext context)
        {
            RegisteredNodes = new ConcurrentDictionary<int, INode>();

            Database.PgSQL.Setup.Startup().Wait();
            Caching.Pool.Initialize(() => new PgSQL(Database.PgSQL.Setup.ConnectionStringController));

            Caching.Cache.Initialize();

            Caching.Cache.Update(false).Wait();

            // Set Core to run
            typeof(Core).GetProperty("State", System.Reflection.BindingFlags.Static | System.Reflection.BindingFlags.NonPublic).SetValue("State", EngineState.Running);
            typeof(Core).GetField("nodeConnections", System.Reflection.BindingFlags.Static | System.Reflection.BindingFlags.NonPublic).SetValue("nodeConnections", RegisteredNodes);
        }

        [AssemblyCleanup]
        public static void Cleanup()
        {
            Caching.Cache.Shutdown();

            Database.PgSQL.Setup.Shutdown();
        }

        #endregion Initialize / Cleanup
    }
}
