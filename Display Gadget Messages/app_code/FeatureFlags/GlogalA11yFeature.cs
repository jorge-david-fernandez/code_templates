using System;
using UltimateSoftware.Security;

public static class GlobalA11YFeature
{
    public static FeatureFlag ForClient(string clientID){
        return new FeatureFlag(clientID, "A11y", "A11yGlobalPageTitleEnabled");
    }
}