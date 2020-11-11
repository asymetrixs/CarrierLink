namespace CarrierLink.Controller.Engine.Caching
{
    using System;
    using System.Collections.Concurrent;

    /// <summary>
    /// Pool to avoid heavy initialization of objects by reuse
    /// </summary>
    /// <typeparam name="T">Class of cached instances</typeparam>
    public class ObjectPool<T>
    {
        #region Fields

        /// <summary>
        /// Function to call for creating the object
        /// </summary>
        private Func<T> ctor;

        /// <summary>
        /// Holds the instances
        /// </summary>
        private ConcurrentBag<T> objects;

        #endregion Fields

        #region Constructor

        /// <summary>
        /// Initializes a new instance of the <see cref="ObjectPool{T}"/> class
        /// </summary>
        /// <param name="ctor">Constructor or factory to create new instances</param>
        internal ObjectPool(Func<T> ctor)
        {
            if (ctor == null)
            {
                throw new ArgumentException("Parameter ctor cannot be NULL");
            }

            this.ctor = ctor;
            this.objects = new ConcurrentBag<T>();
        }

        #endregion Constructor

        #region Methods

        /// <summary>
        /// Removes all objects of this pool
        /// </summary>
        internal void ClearUnused()
        {
            while (this.objects.TryTake(out T obj))
            {
            }
        }

        /// <summary>
        /// Returns an object from the pool or creates a new one if pool is empty
        /// </summary>
        /// <returns>Cached or new instance</returns>
        public T Get()
        {
            if (!this.objects.TryTake(out T item))
            {
                item = this.ctor();
            }

            return item;
        }

        /// <summary>
        /// Returns an object to the pool for reuse. Use <c>Clear</c> if class implements method prior to <c>Put</c>!
        /// </summary>
        /// <param name="item">Instance to put back into cache</param>
        public void Put(T item)
        {
            this.objects.Add(item);
        }

        #endregion Methods
    }
}