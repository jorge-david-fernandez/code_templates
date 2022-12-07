using Newtonsoft.Json;

public class CustomLogoDTO
{
    [JsonProperty("backgroundColor")]
    public string BackgroundColor { get; set; }

    [JsonProperty("customColorExists")]
    public bool CustomColorExists { get; set; }

    [JsonProperty("customLogoExists")]
    public bool CustomLogoExists { get; set; }

    [JsonProperty("drawerColor")]
    public string DrawerColor { get; set; }

    [JsonProperty("logoFileName")]
    public string LogoFileName { get; set; }

    [JsonProperty("logoPath")]
    public string LogoPath { get; set; }

    [JsonProperty("menuTextColor")]
    public string MenuTextColor { get; set; }

    [JsonProperty("subMenuBackgroundColor")]
    public string SubMenuBackgroundColor { get; set; }

    [JsonProperty("subMenuTextColor")]
    public string SubMenuTextColor { get; set; }
    
    [JsonProperty("logoBackgroundColor")]
    public string LogoBackgroundColor { get; set; }
}