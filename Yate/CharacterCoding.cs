namespace CarrierLink.Controller.Yate
{
    using System;
    using System.Collections.Generic;

    /// <summary>
    /// This class provides encoding/decoding of Yate messages
    /// </summary>
    public static class CharacterCoding
    {
        #region Properties

        /// <summary>
        /// Conversion table
        /// </summary>
        private static List<Tuple<char, string>> conversions;

        /// <summary>
        /// Decoding Yate to Core
        /// </summary>
        private static Dictionary<string, char> yateToCore;

        /// <summary>
        /// Encoding Core to Yate
        /// </summary>
        private static Dictionary<char, string> coreToYate;

        #endregion Properties

        #region Constructor

        /// <summary>
        /// Initializes the class
        /// </summary>
        static CharacterCoding()
        {
            conversions = new List<Tuple<char, string>>();
            //AsEncoded.Add(new Tuple<char, string>('!', "%a"));    // 33
            //AsEncoded.Add(new Tuple<char, string>('"', "%b"));    // 34
            //AsEncoded.Add(new Tuple<char, string>('#', "%c"));    // 35
            //AsEncoded.Add(new Tuple<char, string>('$', "%d"));    // 36
            //AsEncoded.Add(new Tuple<char, string>('&', "%f"));    // 38
            //AsEncoded.Add(new Tuple<char, string>(' ', "%`"));    // 39
            //AsEncoded.Add(new Tuple<char, string>('(', "%h"));    // 40
            //AsEncoded.Add(new Tuple<char, string>(')', "%i"));    // 41
            //AsEncoded.Add(new Tuple<char, string>('*', "%j"));    // 42
            //AsEncoded.Add(new Tuple<char, string>('+', "%k"));    // 43
            //AsEncoded.Add(new Tuple<char, string>(',', "%l"));    // 44
            //AsEncoded.Add(new Tuple<char, string>('-', "%m"));    // 45
            //AsEncoded.Add(new Tuple<char, string>('.', "%n"));    // 46
            //AsEncoded.Add(new Tuple<char, string>('/', "%o"));    // 47
            conversions.Add(new Tuple<char, string>(':', "%z"));    // 58 (important)
            //AsEncoded.Add(new Tuple<char, string>(';', "%{"));    // 59 (important)
            //AsEncoded.Add(new Tuple<char, string>('<', "%|"));    // 60
            //AsEncoded.Add(new Tuple<char, string>('=', "%}"));    // 61
            //AsEncoded.Add(new Tuple<char, string>('>', "%~"));    // 62

            // MUST
            conversions.Add(new Tuple<char, string>('%', "%%"));

            yateToCore = new Dictionary<string, char>();
            coreToYate = new Dictionary<char, string>();

            foreach (var conversion in conversions)
            {
                yateToCore.Add(conversion.Item2, conversion.Item1);
                coreToYate.Add(conversion.Item1, conversion.Item2);
            }
        }

        #endregion

        #region Functions

        /// <summary>
        /// Encodes strings for yate
        /// </summary>
        /// <param name="value">String that needs to be encoded</param>
        /// <returns>Encoded string</returns>
        public static string Encode(string value)
        {
            int length = value.Length;
            for (int i = 0; i < length; i++)
            {
                if (coreToYate.TryGetValue(value[i], out string encoded))
                {
                    // Check if last character
                    if (i == length - 1)
                    {
                        value = string.Concat(value.Substring(0, i), encoded);
                        break;
                    }
                    else
                    {
                        value = string.Concat(value.Substring(0, i), encoded, value.Substring(i + 1));
                        length++;
                    }
                }
            }

            return value;
        }

        /// <summary>
        /// Decodes yate-encoded strings
        /// </summary>
        /// <param name="values"></param>
        /// <returns></returns>
        public static string Decode(string value)
        {
            int length = value.Length;
            for (int i = 0; i < length; i++)
            {
                if (value[i] == '%')
                {
                    if (yateToCore.TryGetValue(string.Concat(value[i], value[i + 1]), out char decoded))
                    {
                        // Check if penultimate character
                        if (i == length - 2)
                        {
                            value = string.Concat(value.Substring(0, i), decoded);
                            break;
                        }
                        else
                        {
                            value = string.Concat(value.Substring(0, i), decoded, value.Substring(i + 2));
                            length--;
                        }
                    }
                }
            }

            return value;
        }

        #endregion Functions
    }
}