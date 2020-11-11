namespace CarrierLink.Controller.Utilities.RoutingTree
{
    using Newtonsoft.Json;
    using Newtonsoft.Json.Converters;
    using System.Collections.Generic;

    /// <summary>
    /// This class describes the context as a target
    /// </summary>
    public class Context : Target
    {
        #region Constructor

        /// <summary>
        /// Initializes a new instance of the <see cref="RoutingTree.Context"/> class
        /// </summary>
        /// <param name="id"></param>
        public Context()
            : base(TargetType.Context)
        {
            this.LCRGateways = new List<Gateway>();
        }

        #endregion

        #region Properties

        /// <summary>
        /// Describes the conducted action (Least Cost or Fixed Routing)
        /// </summary>
        [JsonConverter(typeof(StringEnumConverter))]
        public ContextAction RoutingAction { get; private set; }

        /// <summary>
        /// The matched route
        /// </summary>
        public Route Route { get; private set; }

        /// <summary>
        /// Gets a list of LCR gateways
        /// </summary>
        public List<Gateway> LCRGateways { get; private set; }

        /// <summary>
        /// Gets the gateway that was targeted by internal routing
        /// </summary>
        public Gateway InternalRoutedGateway { get; private set; }

        /// <summary>
        /// Gets the context used for blending
        /// </summary>
        public Context BlendingContext { get; private set; }

        #endregion

        #region Methods

        /// <summary>
        /// Die gematchte Route setzen
        /// </summary>
        /// <param name="route"></param>
        public void SetRoute(Route route)
        {
            if (!this.RoutingAction.HasFlag(ContextAction.Fixed))
            {
                return;
            }

            this.Route = route;
        }

        /// <summary>
        /// Adds an action to this context
        /// </summary>
        /// <param name="action">Action to be added</param>
        public void AddRoutingAction(ContextAction action)
        {
            this.RoutingAction |= action;
        }

        /// <summary>
        /// Sets Gateway targeted by internal routing
        /// </summary>
        /// <param name="gateway"></param>
        public void SetInternalRoutedGateway(Gateway gateway)
        {
            this.InternalRoutedGateway = gateway;
        }

        /// <summary>
        /// Sets Context used for blending
        /// </summary>
        /// <param name="context"></param>
        public void SetBlendingContext(Context context)
        {
            this.BlendingContext = context;
        }


        #endregion
    }
}
