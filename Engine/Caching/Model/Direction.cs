namespace CarrierLink.Controller.Engine.Caching.Model
{
    /// <summary>
    /// Direction of call
    /// </summary>
    internal enum Direction
    {
        /// <summary>
        /// Call comes from customer
        /// </summary>
        Incoming,

        /// <summary>
        /// Call goes to gateway
        /// </summary>
        Outgoing
    }
}