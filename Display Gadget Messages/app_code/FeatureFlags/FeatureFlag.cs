using System;
using UltimateSoftware.Security;

public class FeatureFlag {
    private string clientID;
    private string settingNamespace;
    private string settingName;

    private Func<string> enabledValueSupplier;

    public FeatureFlag(string clientID, string settingNamespace, string settingName) {
        this.clientID = clientID;
        this.settingNamespace = settingNamespace;
        this.settingName = settingName;
    }

    public static FeatureFlag IdentifiedBy(string clientID, string settingNamespace, string settingName){
        return new FeatureFlag(clientID, settingNamespace, settingName);
    }
    public FeatureFlag WhenEnabled(Func<string> enabledValueSupplier)
    {
        this.enabledValueSupplier = enabledValueSupplier;
        return this;
    }

    public string Otherwise(Func<string> disabledValueSupplier) {
        return this.IsEnabled() ? this.enabledValueSupplier() : disabledValueSupplier();
    }

    public void WhenDisabledDo(Action doIt) {
        if (!this.IsEnabled()) {
            doIt();
        }
    }

    public void WhenEnabledDo(Action doIt) {
        if (this.IsEnabled()) {
            doIt();
        }
    }

    public bool IsEnabled() {
        var resolvedValue = FoundationFacade.Instance.GetCompanySetting(this.clientID, this.settingNamespace, this.settingName);

        if (string.IsNullOrWhiteSpace(resolvedValue))
        {
            return false;
        }

        String[] acceptableTrueValues = { "y", "1", "yes" };
        return Array.IndexOf(acceptableTrueValues, resolvedValue.ToString().ToLowerInvariant()) > -1;
    }
}