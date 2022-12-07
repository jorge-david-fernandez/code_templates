using Newtonsoft.Json;
using System;
using System.Net.Http;
using System.Threading.Tasks;
using UltimateSoftware.Data;
using UltimateSoftware.Security;
using UltimateSoftware.UltiproNet.HttpMessageHandlers;

/// <summary>
/// Represents Theme helper
/// </summary>
public class ThemeHelper
{
    public const string DEFAULT_BRAND_BACKGROUND_COLOR = "005151";
    private UserContext _userContext;
    private string _loginToken;
    private NavMenuAndThemingHttpClientHandler _navMenuAndThemingHttpClientHandler;

    public ThemeHelper(UserContext userContext, string loginToken)
    {
        _userContext = userContext;
        _loginToken = loginToken;
    }

    protected bool GetIsAdminPortal()
    {
        return _userContext.ApplicationID == (int)rbsAppType.appAdminPortal;
    }
    
    public CustomLogoDTO GetCompanyUiSettings()
    {
        var companyInfo = new Info(_userContext);
        var masterCompanyCode = companyInfo.Companys.Current.CompmastData.CompanyCode;
        var componentCompanyCode = GetIsAdminPortal() ? _userContext.COID : _userContext.CompanyCode;

        // serialize Style object to Json string
        var jsonSerializedString = JsonConvert.SerializeObject(FoundationFacade.Instance.GetCompanyUISettings(_userContext.CompanyDatabase, masterCompanyCode, componentCompanyCode, true));

        // deserialize json string to CustomLogoDTO object
        return Newtonsoft.Json.JsonConvert.DeserializeObject<CustomLogoDTO>(jsonSerializedString);
    }

    /// <summary>
    /// Uses CustomLogoDTO object to return company UI settings
    /// </summary>
    /// <returns></returns>
    public string GetJsonSerializedCompanyUiSettings()
    {
        return JsonConvert.SerializeObject(GetCompanyUiSettings());
    }

    /// <summary>
    /// Returns logo and color task
    /// </summary>
    /// <param name="logoTask">Asynchornous logo task</param>
    /// <param name="colorTask">Asynchronous color task</param>
    public void GetThemeDataAsync(out Task<string> logoTask, out Task<string> colorTask)
    {
        var client = new HttpClient(new RetryHandler(new HttpClientHandler(), CommonConfig.HttpRequestRetryCount, CommonConfig.HttpRequestDelayInMiliseconds));

        var logoRequest = new HttpRequestMessage()
        {
            RequestUri = new Uri(string.Format("{0}{1}", Common.GetServiceUrl(), ApplicationConstant.ApplicationLogo)),
            Method = HttpMethod.Get
        };

        var colorRequest = new HttpRequestMessage()
        {
            RequestUri = new Uri(string.Format("{0}{1}", Common.GetServiceUrl(), ApplicationConstant.ApplicationColor)),
            Method = HttpMethod.Get
        };

        _navMenuAndThemingHttpClientHandler = new NavMenuAndThemingHttpClientHandler(_userContext, _loginToken);
        logoTask = _navMenuAndThemingHttpClientHandler.ProcessRequestAsync(client, logoRequest);
        colorTask = _navMenuAndThemingHttpClientHandler.ProcessRequestAsync(client, colorRequest);
    }

    /// <summary>
    /// Returns logo and color task
    /// </summary>
    /// <param name="globalColor">Color Data</param>
    /// <param name="globalLogo">Logo Data</param>
    public void GetThemeDataSync(out string globalColor, out string globalLogo)
    {
        string _globalColor = string.Empty;
        string _globalLogo = string.Empty;

        Task.Run(async () =>
        {
            Task<string> logoTask, colorTask;
            GetThemeDataAsync(out logoTask, out colorTask);

            _globalColor = await colorTask;
            _globalLogo = await logoTask;

        }).GetAwaiter().GetResult();

        globalColor = _globalColor;
        globalLogo = _globalLogo;
    }
    
    /// <summary>
    /// Returns NavigationThemeDTO object
    /// </summary>
    public NavigationThemeDTO LoadThemeData()
    {
        string globalColor = string.Empty;
        string globalLogo = string.Empty;

        GetThemeDataSync(out globalColor, out globalLogo);
        
        GlobalLogoDTO logo = Newtonsoft.Json.JsonConvert.DeserializeObject<GlobalLogoDTO>(globalLogo);
        CustomLogoDTO customLogoData = GetCompanyUiSettings();
        
        NavigationThemeDTO NavigationGlobalThemeAndLogoData = new NavigationThemeDTO()
        {
            CustomLogo = customLogoData,
            GlobalColor = Newtonsoft.Json.JsonConvert.DeserializeObject<GlobalColorDTO>(globalColor),
            GlobalLogo = logo
        };

        NavigationGlobalThemeAndLogoData.LogoSrc = (customLogoData.CustomLogoExists == true)
            ? "data:image/" + logo.Extension + ";base64," + logo.Content
            : "";

        NavigationGlobalThemeAndLogoData.CustomLogo.LogoBackgroundColor = MapLogoBackgroundToDLSCodes(NavigationGlobalThemeAndLogoData.CustomLogo.LogoBackgroundColor);

        return NavigationGlobalThemeAndLogoData;
    }

    /// <summary>
    /// Converts the logo background color received from the service call (values: 0, 1, 2) to the value needed by the property of the Ukg-Logo DLS component.
    /// Returns the converted value.
    /// </summary>
    /// <param name="beCode">string</param>
    protected string MapLogoBackgroundToDLSCodes(string beCode) {
        int beCodeNum = int.Parse(beCode);
        string[] BeToDLSCodes = new string[] { null, "light", "dark" };
        return ((beCodeNum >= 0) && (beCodeNum <= 2)) ? BeToDLSCodes[beCodeNum] :  null;
    }
}