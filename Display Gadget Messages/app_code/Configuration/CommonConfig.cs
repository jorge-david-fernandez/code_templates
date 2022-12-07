using System;

/// <summary>
/// Summary description for CommonConfig
/// </summary>
public static class CommonConfig
{
    private static LazyWithExpiration<int> _httpRequestRetryCount;
    private static LazyWithExpiration<int> _httpRequestDelayInMiliseconds;
    private static LazyWithExpiration<int> _serviceUrlPort;
    private static TimeSpan expirationTime = new TimeSpan(0, 5, 0);

    static CommonConfig()
    {
        ConfigProvider configProvider = new ConfigProvider(); // TODO: Inject in constructor

        _httpRequestRetryCount = new LazyWithExpiration<int>(() =>
        {
            return configProvider.GetSetting("HttpRequestRetryCount", 5);
        }, expirationTime);

        _httpRequestDelayInMiliseconds = new LazyWithExpiration<int>(() =>
        {
            return configProvider.GetSetting("HttpRequestDelayInMiliseconds", 100);
        }, expirationTime);

        _serviceUrlPort = new LazyWithExpiration<int>(() =>
        {
            return configProvider.GetSetting("ServiceUrlPort", 9000);
        }, expirationTime);
    }

    /// <summary>
    ///  Http request retry count.
    /// </summary>
    public static int HttpRequestRetryCount { get { return _httpRequestRetryCount.Value; } }

    /// <summary>
    /// Http request retry delay
    /// </summary>
    public static int HttpRequestDelayInMiliseconds { get { return _httpRequestDelayInMiliseconds.Value; } }

    /// <summary>
    /// Port number for UES service
    /// </summary>
    public static int ServiceUrlPort { get { return _serviceUrlPort.Value; } }

}