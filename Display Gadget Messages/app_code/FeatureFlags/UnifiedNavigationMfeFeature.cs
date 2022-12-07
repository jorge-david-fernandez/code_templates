using System;
using UltimateSoftware.Security;

public static class UnifiedNavigationMfeFeature
{
    public static FeatureFlag ForClient(string clientID){
        return new FeatureFlag(clientID, "Wayfinding", "UnifiedNavigationMfeFeatureEnabled");
    }
}