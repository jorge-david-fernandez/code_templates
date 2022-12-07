using System;
using System.Configuration;
using UltimateSoftware.Diagnostics.Common;

/// <summary>
/// Provides configuration that are stored in web confg.
/// </summary>
/// <seealso cref="IConfigProvider" />
[Serializable]
public class ConfigProvider : IConfigProvider
{
    /// <summary>
    /// Gets the setting value.
    /// </summary>
    /// <typeparam name="T">The type of the configuration value</typeparam>
    /// <param name="key">config key</param>
    /// <param name="defaultValue"> default value</param>
    /// <returns></returns>

    public T GetSetting<T>(string key, T defaultValue)
    {
        string value = string.Empty;
        try
        {
            value = ConfigurationManager.AppSettings[key.ToString()];

            if (value == null)
            {
                Log.WriteLogEntry("00000", string.Format("key - '{0}', not found or invalid type in web config. Using default value '{1}'", key, value));
                return defaultValue;
            }
            return (T)Convert.ChangeType(value, typeof(T));
        }
        catch (Exception e)
        {
            Log.WriteLogEntry("00000", new ExceptionData(e, string.Format("key - '{0}', not found or invalid type in web config. Using default value '{1}'", key, value)));
            return defaultValue;
        }
    }
}