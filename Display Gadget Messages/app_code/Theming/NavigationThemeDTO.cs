using Newtonsoft.Json;

public class NavigationThemeDTO
{
    [JsonProperty("customLogo")] public CustomLogoDTO CustomLogo { get; set; }

    [JsonProperty("globalColor")] public GlobalColorDTO GlobalColor { get; set; }

    [JsonProperty("globalLogo")] public GlobalLogoDTO GlobalLogo { get; set; }
        
    [JsonProperty("logoSrc")] public string LogoSrc { get; set; }
}