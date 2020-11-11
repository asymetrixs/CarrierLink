namespace CarrierLink.Controller.YateSimulator
{
    using System;

    internal class Message
    {
        #region Constructor

        internal Message()
        {
            Id = String.Empty;
            Route = String.Empty;
            RouteResult = String.Empty;
        }

        #endregion

        #region Fields

        public string Id;
        public string Route;
        public string RouteResult;

        #endregion
    }
}