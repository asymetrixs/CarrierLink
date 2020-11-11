namespace CarrierLink.Controller.Engine.Caching
{
    using System;
    using System.Collections.Concurrent;
    using Utilities;

    /// <summary>
    /// This class maps the TechnicalName-attribute value to String both ways
    /// </summary>
    /// <typeparam name="T">Class using technical names</typeparam>
    internal class TechnicalNameMapper<T>
    {
        #region Fields

        /// <summary>
        /// Conversion from Core to Yate
        /// </summary>
        private ConcurrentDictionary<T, string> coreToYate;

        /// <summary>
        /// Conversion from Yate to Core
        /// </summary>
        private ConcurrentDictionary<string, T> yateToCore;

        #endregion Fields

        #region Constructor

        /// <summary>
        /// Initializes a new instance of the <see cref="TechnicalNameMapper{T}"/> class
        /// </summary>
        internal TechnicalNameMapper()
        {
            this.coreToYate = new ConcurrentDictionary<T, string>();
            this.yateToCore = new ConcurrentDictionary<string, T>();

            Type type = typeof(T);
            try
            {
                foreach (var name in Enum.GetNames(type))
                {
                    var memInfo = type.GetMember(name);
                    var attributes = memInfo[0].GetCustomAttributes(typeof(TechnicalName), false);
                    var yateType = ((TechnicalName)attributes[0]).Name;
                    var handlerType = (T)Enum.Parse(type, name);

                    this.coreToYate.TryAdd(handlerType, yateType);
                    this.yateToCore.TryAdd(yateType, handlerType);
                }
            }
            catch (Exception ex)
            {
                throw new ArgumentException($"{typeof(T).ToString()} does not implement TechnicalName.", ex);
            }
        }

        #endregion Constructor

        #region Methods

        /// <summary>
        /// Converts from Core to Yate
        /// </summary>
        /// <param name="type">Technical type</param>
        /// <returns>Returns technical name</returns>
        internal string ToString(T type)
        {
            string name = string.Empty;

            if (!this.coreToYate.TryGetValue(type, out name))
            {
                throw new InvalidOperationException("Technical mapping problem in ToString(T type) detected");
            }

            return name;
        }

        /// <summary>
        /// Converts from Yate To Core
        /// </summary>
        /// <param name="name">Technical name</param>
        /// <returns>Returns <see cref="{T}"/></returns>
        internal T ToType(string name)
        {

            if (!this.yateToCore.TryGetValue(name, out T type))
            {
                throw new InvalidOperationException("Technical mapping problem in ToType(string name) detected.");
            }

            return type;
        }

        #endregion Methods
    }
}