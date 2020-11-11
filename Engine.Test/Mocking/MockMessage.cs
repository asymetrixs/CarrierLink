namespace CarrierLink.Controller.Engine.Test.Mocking
{
    using CarrierLink.Controller.Yate.Messaging;
    using System.Threading;

    /// <summary>
    /// This class mocks class <see cref="Message"/>
    /// </summary>
    internal class MockMessage : Message
    {
        #region Properties

        /// <summary>
        /// Returns a new Cancellation Token every time
        /// </summary>
        public override CancellationToken CancellationToken
        {
            get
            {
                return new CancellationTokenSource().Token;
            }
        }

        #endregion
    }
}
