using System;

/// <summary>
/// Interface for implementing get setting values.
/// </summary>
public interface IConfigProvider
{
    /// <summary>
    /// Gets the setting value.
    /// </summary>
    /// <typeparam name="T">The type of the configuration keys.</typeparam>
    /// <param name="key">The config key.</param>
    /// <returns>The config value.</returns>
    T GetSetting<T>(string key, T defaultValue);
}