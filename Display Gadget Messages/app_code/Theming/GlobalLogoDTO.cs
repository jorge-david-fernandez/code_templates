using Newtonsoft.Json;

public class GlobalLogoDTO
{
    [JsonProperty("content")]
    public string Content { get; set; }

    [JsonProperty("extension")]
    public string Extension { get; set; }
}