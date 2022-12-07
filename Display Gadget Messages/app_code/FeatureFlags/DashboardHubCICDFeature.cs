using System;
using UltimateSoftware.Security;

public static class DashboardHubCICDFeature
{
    public static FeatureFlag ForClient(string clientID){
        return new FeatureFlag(clientID, "Wayfinding", "SmartDashboardHubCICDEnabled");
    }
}