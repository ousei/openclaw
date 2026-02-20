# Local Search Script for SearXNG - Uses HTML extraction method
# Usage: .\search.ps1 "your search query"
# Returns: JSON formatted search results extracted from HTML page

param(
    [Parameter(Mandatory=$true)]
    [string]$Query
)

# Use the HTML extraction method (works around bot detection)
$scriptPath = Split-Path -Parent $MyInvocation.MyCommand.Path
$htmlSearchScript = Join-Path $scriptPath "search_from_html.ps1"

if (Test-Path $htmlSearchScript) {
    & $htmlSearchScript -Query $Query
} else {
    # Fallback: direct implementation
    $SEARXNG_URL = if ($env:SEARXNG_URL) { $env:SEARXNG_URL } else { "http://localhost:18888" }
    
    try {
        Add-Type -AssemblyName System.Web
        $encodedQuery = [System.Web.HttpUtility]::UrlEncode($Query)
    } catch {
        $encodedQuery = $Query -replace ' ', '%20' -replace '&', '%26'
    }
    
    $SearchUrl = "${SEARXNG_URL}/search?q=${encodedQuery}"
    $htmlContent = curl.exe -s -L -H "User-Agent: Mozilla/5.0" "$SearchUrl" 2>&1
    
    $resultLinks = [regex]::Matches($htmlContent, '<h3[^>]*class="[^"]*result[^"]*"[^>]*><a[^>]*href="([^"]+)"[^>]*>([^<]+)</a></h3>', [System.Text.RegularExpressions.RegexOptions]::IgnoreCase)
    
    if ($resultLinks.Count -eq 0) {
        $resultLinks = [regex]::Matches($htmlContent, 'href="(https?://[^"]+)"[^>]*>([^<]{10,100})</a>', [System.Text.RegularExpressions.RegexOptions]::IgnoreCase)
    }
    
    if ($resultLinks.Count -gt 0) {
        $Results = @()
        for ($i = 0; $i -lt [Math]::Min(10, $resultLinks.Count); $i++) {
            $match = $resultLinks[$i]
            if ($match.Groups[1].Value -notmatch "github.com/searxng|searx.space") {
                $Results += [PSCustomObject]@{
                    Title = $match.Groups[2].Value
                    URL = $match.Groups[1].Value
                    Snippet = ""
                }
            }
        }
        $Results | ConvertTo-Json -Depth 3
    } else {
        Write-Output ('{"error": "No results found", "query": "' + $Query + '"}')
        exit 1
    }
}
