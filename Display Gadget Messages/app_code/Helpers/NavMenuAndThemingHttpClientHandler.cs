using System;
using System.Net.Http;
using System.Threading.Tasks;
using UltimateSoftware.Security;
using UltimateSoftware.Diagnostics.Common;

/// <summary>
/// Http client wrapper for Nav menu and theme
/// </summary>
public class NavMenuAndThemingHttpClientHandler
{
    private UserContext _userContext;
    private string _loginToken;

    public NavMenuAndThemingHttpClientHandler(UserContext userContext, string loginToken)
    {
        _userContext = userContext;
        _loginToken = loginToken;
    }

    public async Task<string> ProcessRequestAsync(HttpClient client, HttpRequestMessage request)
    {
        request.Headers.Add("loginToken", this._loginToken);
        request.Headers.Add("Accept-Language", FoundationFacade.Instance.GetLanguage(this._userContext.Language).CultureIsoCode);
        HttpResponseMessage response;

        try
        {
            response = await client.SendAsync(request);
        }
        catch (Exception e)
        {
            Log.WriteLogEntry("00000", new ExceptionData(e, string.Format("exception in api request to {0}", request.RequestUri)));
            throw new Exception("Could not retrieve menu and theme data.");
        }

        if (response.IsSuccessStatusCode)
        {
            var responseContent = response.Content;

            return responseContent.ReadAsStringAsync().Result;
        }

        Log.WriteLogEntry("00000", new LogEntryData(string.Format("error response {0} from api request to {1}", response.StatusCode, request.RequestUri)));

        return "null";
    }
}