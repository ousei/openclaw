# Weather Search Script - Extract results from SearXNG HTML page
# This script fetches HTML from SearXNG and extracts search results
# Usage: .\search_weather_from_html.ps1 "Tokyo"

param(
    [Parameter(Mandatory=$false, Position=0)]
    [string]$weatherLocation = "Tokyo"
)

# Handle old-style parameter passing
if ($weatherLocation -match '^\$weatherLocation="(.+)"$') {
    $weatherLocation = $matches[1]
}

# Use SearXNG (port 18888)
$SEARXNG_URL = "http://localhost:18888"
$query = "$weatherLocation weather"

# URL encoding
try {
    Add-Type -AssemblyName System.Web
    $encodedQuery = [System.Web.HttpUtility]::UrlEncode($query)
} catch {
    $encodedQuery = $query -replace ' ', '%20' -replace '&', '%26'
}

# Build search URL
$SearchUrl = "${SEARXNG_URL}/search?q=${encodedQuery}"

try {
    # Fetch HTML page using curl (more reliable in non-interactive mode)
    $htmlContent = curl.exe -s -L -H "User-Agent: Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36" -H "Accept: text/html" "$SearchUrl" 2>&1
    
    if ($LASTEXITCODE -ne 0) {
        throw "curl failed with exit code $LASTEXITCODE"
    }
    
    # Try to extract JSON data from HTML (SearXNG embeds results in script tags)
    $jsonMatch = [regex]::Match($htmlContent, 'const\s+results\s*=\s*(\[.*?\]);', [System.Text.RegularExpressions.RegexOptions]::Singleline)
    
    if ($jsonMatch.Success) {
        try {
            $jsonData = $jsonMatch.Groups[1].Value | ConvertFrom-Json
            
            if ($jsonData -and $jsonData.Count -gt 0) {
                $Results = $jsonData | Select-Object -First 10 | ForEach-Object {
                    [PSCustomObject]@{
                        Title = if ($_.title) { $_.title } else { "" }
                        URL = if ($_.url) { $_.url } else { "" }
                        Snippet = if ($_.content) { $_.content.Substring(0, [Math]::Min(300, $_.content.Length)) } else { "" }
                    }
                }
                
                $Results | ConvertTo-Json -Depth 3
                exit 0
            }
        } catch {
            # JSON parsing failed, try HTML parsing
        }
    }
    
    # Fallback: Parse HTML directly
    # Extract result links from HTML (SearXNG uses specific class names)
    $resultLinks = [regex]::Matches($htmlContent, '<h3[^>]*class="[^"]*result[^"]*"[^>]*><a[^>]*href="([^"]+)"[^>]*>([^<]+)</a></h3>', [System.Text.RegularExpressions.RegexOptions]::IgnoreCase)
    
    # Alternative pattern if above doesn't match
    if ($resultLinks.Count -eq 0) {
        $resultLinks = [regex]::Matches($htmlContent, '<article[^>]*class="[^"]*result[^"]*"[^>]*>.*?<h3[^>]*><a[^>]*href="([^"]+)"[^>]*>([^<]+)</a></h3>', [System.Text.RegularExpressions.RegexOptions]::Singleline -bor [System.Text.RegularExpressions.RegexOptions]::IgnoreCase)
    }
    
    # Another pattern: just find links in result containers
    if ($resultLinks.Count -eq 0) {
        $resultLinks = [regex]::Matches($htmlContent, 'href="(https?://[^"]+)"[^>]*>([^<]{10,100})</a>', [System.Text.RegularExpressions.RegexOptions]::IgnoreCase)
    }
    
    if ($resultLinks.Count -gt 0) {
        $Results = @()
        for ($i = 0; $i -lt [Math]::Min(10, $resultLinks.Count); $i++) {
            $match = $resultLinks[$i]
            $Results += [PSCustomObject]@{
                Title = $match.Groups[2].Value
                URL = $match.Groups[1].Value
                Snippet = ""
            }
        }
        
        $Results | ConvertTo-Json -Depth 3
        exit 0
    }
    
    # If no results found, return error with URL
    Write-Output ('{"error": "No results found in HTML", "webUrl": "' + $SearchUrl + '", "query": "' + $query + '"}')
    
} catch {
    $ErrorMessage = $_.Exception.Message
    Write-Output ('{"error": "' + $ErrorMessage + '", "webUrl": "' + $SearchUrl + '", "query": "' + $query + '"}')
    exit 1
}
