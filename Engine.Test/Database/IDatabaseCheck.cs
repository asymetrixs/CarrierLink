namespace CarrierLink.Controller.Engine.Test.Database
{
    using CheckModel;

    /// <summary>
    /// Provides methods to check the actual data in the database after test run
    /// </summary>

    interface IDatabaseCheck
    {
        Cdr GetRecord(int nodeId, string billId, string chanId);
    }
}
