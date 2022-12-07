using Newtonsoft.Json;

public class GlobalColorDTO
{
    [JsonProperty("drawerColor")]
    public string DrawerColor { get; set; }

    [JsonProperty("primaryBackground")]
    public string PrimaryBackground { get; set; }

    [JsonProperty("primaryText")]
    public string PrimaryText { get; set; }

    [JsonProperty("secondaryBackground")]
    public string SecondaryBackground { get; set; }

    [JsonProperty("secondaryText")]
    public string SecondaryText { get; set; }
}