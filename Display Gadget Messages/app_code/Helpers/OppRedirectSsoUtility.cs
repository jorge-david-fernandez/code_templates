using System;
using System.Collections.Specialized;
using System.Text;
using UltimateSoftware.DataAccess.Wcf;
using UltimateSoftware.Diagnostics.Common;
using UltimateSoftware.Security;
using UltimateSoftware.Security.OIDC;
using UltimateSoftware.SSO.Partners;
using UltimateSoftware.WcfTypes.OutboundSsoClaimStore;
using UltimateSoftware.WebSite.AppCode.FlatFiles.Helpers;

/// <summary>
/// Name: OppRedirectSsoUtility
/// </summary>
public class OppRedirectSsoUtility
{

    public static string CreateSsoUrl(string url, UserContext userContext, NameValueCollection queryString)
    {
        Guid partnerGuid;
        string partnerId = string.IsNullOrWhiteSpace(queryString["partner_id"]) ? string.Empty : queryString["partner_id"];
        bool isValidPartnerIdFormat = Guid.TryParse(partnerId, out partnerGuid);
        
        if (!isValidPartnerIdFormat)
        {
            string errorMessage = string.Format("Invalid Partner GUID Format : {0}, Guid should contain 32 digits with 4 dashes (xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx).", partnerId);
            LogDebugMessage(errorMessage);
            throw new FormatException(errorMessage);
        }
        
        try
        {
            SSOEntityApplicationMapping mappingDetails = GetSsoEntityApplicationMappingDetails(userContext, partnerGuid);
            bool isOppSSOEnabled = mappingDetails == null ? false : mappingDetails.OPPSSOEnabled;
            bool isADFSDisabled = IsADFSDisabled();

            if (isADFSDisabled || isOppSSOEnabled)
            {
                var authorityUrl = GetSsoAuthorityUrl(FoundationFacade.Instance);
                var tenantAlias = GetTenantAlias(userContext.ClientID);
                ClaimCollection claimDetails = GetClaimDetails(mappingDetails.ApplicationId);
                var relayState = GetRelayStateFromQueryParams(claimDetails, queryString);
                return PrepareUrl(authorityUrl, tenantAlias, mappingDetails, relayState);
            }
            return url;
        }
        catch (Exception e)
        {
            LogDebugMessage(string.Format("Error occurred for Partner GUID: {0} while creating opp redirect sso url: {1}", partnerId, e.Message));
            throw e;
        }
    }

    private static string PrepareUrl(string authorityUrl, string tenantAlias, SSOEntityApplicationMapping mappingDetails, string relayState)
    {

        StringBuilder builder = new StringBuilder();
        builder.Append(authorityUrl)
               .Append("/idpssoinit?realm=/t/")
               .Append(tenantAlias)
               .Append("&metaAlias=")
               .Append(mappingDetails.Metaalias.Replace("[TENANT_ALIAS]", tenantAlias))
               .Append("&spEntityID=")
               .Append(mappingDetails.EntityId);

        if (!string.IsNullOrWhiteSpace(relayState))
        {
            builder.Append("&relaystate=")
                   .Append(relayState);
        }

        return builder.ToString();
    }

    private static string GetRelayStateFromQueryParams(ClaimCollection claims, NameValueCollection queryString)
    {
        foreach (Claim claim in claims)
        {
            if (queryString[claim.LookupName] != null && (claim.Type.EndsWith("_relaystate") || claim.Type.EndsWith("_next")))
            {
                return queryString[claim.LookupName];
            }
        }
        return string.Empty;
    }

    private static bool IsADFSDisabled()
    {
        try
        {
            return FoundationFacade.Instance.GetSiteConfigSetting("ADFSDisabled").Trim() == "1";
        }
        catch (Exception e)
        {
            return false;
        }
    }

    private static string GetSsoAuthorityUrl(FoundationFacade facade)
    {
        var routerEndpointUri = facade.GetSiteConfigSetting("RouterEndpointUri") + "/Configuration";
        var runtimeConfig = OidcFactory.GetRuntimeConfigurationAsync(routerEndpointUri).Result;
        if (runtimeConfig.AuthorityUrl.EndsWith("/oauth2"))
        {
           return runtimeConfig.AuthorityUrl.Substring(0, runtimeConfig.AuthorityUrl.LastIndexOf("/oauth2"));
        }
        return runtimeConfig.AuthorityUrl;
    }

    private static string GetTenantAlias(string clientId)
    {
        var tmsHelper = new TmsServiceHelper();
        var tenant = tmsHelper.GetTenant(clientId);
        return tenant.Alias;
    }

    private static SSOEntityApplicationMapping GetSsoEntityApplicationMappingDetails(UserContext userContext, Guid partnerId)
    {
        ISsoEntityApplicationMapping entityMapping = new SiteSSOEntityApplicationMappingRepository(userContext);
        return entityMapping.GetEntityMapping(partnerId);
    }

    private static ClaimCollection GetClaimDetails(string applicationId)
    {
        Uri superSiteUri = new UriHelper().GetSuperSiteUri("OutboundSsoClaims");
        IOutboundSsoClaimStore claimStore = new WcfOutboundSsoClaimStore(superSiteUri);
        var claimDetails = claimStore.GetApplicationClaims(applicationId);
        return claimDetails;
    }

    private static void LogDebugMessage(string format, params object[] args)
    {
        Log.WriteLogEntry("00000", new LogEntryData(String.Format(format, args)));
    }
}