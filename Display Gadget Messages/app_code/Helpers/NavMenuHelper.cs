using System;
using System.Net.Http;
using System.Threading.Tasks;
using UltimateSoftware.Security;
using UltimateSoftware.UltiproNet.HttpMessageHandlers;

/// <summary>
/// Represents Nav menu helper
/// </summary>
public class NavMenuHelper
{
    private UserContext _userContext;
    private string _loginToken;
    private NavMenuAndThemingHttpClientHandler _navMenuAndThemingHttpClientHandler;

    public NavMenuHelper(UserContext userContext, string loginToken)
    {
        _userContext = userContext;
        _loginToken = loginToken;
    }

    /// <summary>
    /// Returns menu data
    /// </summary>
    /// <returns></returns>
    public Task<string> GetMenuDataAsync()
    {
        var client = new HttpClient(new RetryHandler(new HttpClientHandler(), CommonConfig.HttpRequestRetryCount, CommonConfig.HttpRequestDelayInMiliseconds ));

        var menuRequest = new HttpRequestMessage()
        {
            RequestUri = new Uri(string.Format("{0}{1}",Common.GetServiceUrl(), ApplicationConstant.Navigation)),
            Method = HttpMethod.Get
        };

        _navMenuAndThemingHttpClientHandler = new NavMenuAndThemingHttpClientHandler(_userContext, _loginToken);
        return  _navMenuAndThemingHttpClientHandler.ProcessRequestAsync(client, menuRequest);
    }
}