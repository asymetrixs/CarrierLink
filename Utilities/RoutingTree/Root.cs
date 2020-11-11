namespace CarrierLink.Controller.Utilities.RoutingTree
{
    using System.Collections.Generic;

    /// <summary>
    /// This class defines the root for the routing tree
    /// </summary>
    public class Root
    {
        #region Constructor

        /// <summary>
        /// Initialzes a new instance of the <see cref="Root"/> class
        /// </summary>
        public Root()
        {
            this.Context = new Context();
            this.GatewayOrder = new List<int>(6);
        }

        #endregion

        #region Properties

        /// <summary>
        /// Base Context
        /// </summary>
        public Context Context { get; set; }

        /// <summary>
        /// 
        /// </summary>
        public List<int> GatewayOrder { get; }

        #endregion

        #region Methods

        /// <summary>
        /// Adds a gateway in the actual order of connecting
        /// </summary>
        /// <param name="gateway"></param>
        public void AddGatewayId(int gatewayId)
        {
            this.GatewayOrder.Add(gatewayId);
        }

        /// <summary>
        /// Returns a value specifiying if the <see cref="GatewayOrder"/> contains the specified Id
        /// </summary>
        /// <param name="id"></param>
        /// <returns></returns>
        public bool Contains(Gateway gateway)
        {
            return this.GatewayOrder.Contains(gateway.Id.Value);
        }

        #endregion
    }
}
