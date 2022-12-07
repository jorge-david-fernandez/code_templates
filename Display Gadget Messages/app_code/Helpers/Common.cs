using System;
using UltimateSoftware.Security;

/// <summary>
/// Contains common static methods used in project
/// </summary>
public static class Common
{
   
    /// <summary>
    /// Get base url to fetch menu and theme data.
    /// </summary>
    /// <returns>service url</returns>
    public static string GetServiceUrl()
    {
        var value = FoundationFacade.Instance.GetSiteConfigSetting("ServiceHostHA", "UES");

        if (string.IsNullOrWhiteSpace(value))
        {
            value = FoundationFacade.Instance.GetSiteConfigSetting("ServiceHostInternal", "UES");
        }

        if (string.IsNullOrWhiteSpace(value))
        {
            throw new InvalidOperationException("missing required setting; set either ServiceHostHA or ServiceHostInternal");
        }

        return string.Format("http://{0}:{1}", value, CommonConfig.ServiceUrlPort);
    }

    public static bool IsOidcEnabled()
    {
        return FoundationFacade.Instance.GetSiteConfigSetting("OIDCEnabled") == "1";

    }
}