namespace CarrierLink.Controller.Utilities.RoutingTree
{
    /// <summary>
    /// This class indicates the targets type
    /// </summary>
    public enum TargetType
    {
        /// <summary>
        /// No route matched
        /// </summary>
        None = 1,

        /// <summary>
        /// Target of route is <see cref="RoutingTree.Gateway"/> 
        /// </summary>
        Gateway = 2,

        /// <summary>
        /// Target of route is <see cref="RoutingTree.Context"/> 
        /// </summary>
        Context = 3
    }
}
