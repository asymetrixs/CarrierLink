namespace CarrierLink.Controller.Utilities.RoutingTree
{
    using System.Collections.Generic;

    /// <summary>
    /// This class describes the matched route
    /// </summary>
    public class Route
    {
        #region Constructor

        /// <summary>
        /// Initializes a new instance of the <see cref="Route"/> class
        /// </summary>
        /// <param name="id"></param>
        public Route(int id)
        {
            this.Targets = new List<Target>();
            this.BlendingContext = new List<Context>();
            this.Id = id;
        }

        #endregion

        #region Properties

        /// <summary>
        /// Id
        /// </summary>
        public int Id { get; private set; }

        /// <summary>
        /// Targets, also Contexts oder Gateways
        /// </summary>
        public List<Target> Targets { get; private set; }

        /// <summary>
        /// Gets value indicating if fallback to LCR is activated
        /// </summary>
        public bool IsFallbackToLCR { get; set; }

        /// <summary>
        /// Context used to blend call
        /// </summary>
        public List<Context> BlendingContext { get; private set; }

        #endregion

        #region Methods

        /// <summary>
        /// Sets the blending context
        /// </summary>
        /// <param name="context"></param>
        public void AddBlendingContext(Context context)
        {
            this.BlendingContext.Add(context);
        }

        #endregion
    }
}
