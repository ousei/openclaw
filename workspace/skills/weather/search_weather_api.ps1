# Weather Search Script using SearXNG - API Version
# This script attempts to use SearXNG API to get actual search results
# Usage: .\search_weather_api.ps1 "Tokyo"

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

# Build API URL
$ApiUrl = "${SEARXNG_URL}/search?q=${encodedQuery}&format=json"

# Try multiple methods to access SearXNG API
$success = $false

# Method 1: Try with full browser headers
try {
    $headers = @{
        "User-Agent" = "Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/120.0.0.0 Safari/537.36"
        "Accept" = "application/json, text/html, */*"
        "Accept-Language" = "en-US,en;q=0.9,ja;q=0.8"
        "Accept-Encoding" = "gzip, deflate"
        "Referer" = $SEARXNG_URL
        "X-Forwarded-For" = "127.0.0.1"
        "X-Real-IP" = "127.0.0.1"
    }
    
    $Response = Invoke-RestMethod -Uri $ApiUrl -Headers $headers -Method Get -TimeoutSec 15 -ErrorAction Stop
    
    if ($Response.results -and $Response.results.Count -gt 0) {
        $success = $true
        
        # Format results as JSON
        $Results = $Response.results | Select-Object -First 10 | ForEach-Object {
            [PSCustomObject]@{
                Title = $_.title
                URL = $_.url
                Snippet = if ($_.content) { $_.content.Substring(0, [Math]::Min(300, $_.content.Length)) } else { "" }
                Engine = if ($_.engine) { $_.engine } else { "unknown" }
            }
        }
        
        $Results | ConvertTo-Json -Depth 3
        exit 0
    }
} catch {
    # Continue to next method
}

# Method 2: Try using curl.exe (may work better)
if (-not $success) {
    try {
        $curlOutput = curl.exe -s -H "User-Agent: Mozilla/5.0" -H "Accept: application/json" "${ApiUrl}" 2>&1
        
        if ($curlOutput -and $curlOutput -notmatch "403|Forbidden") {
            $Response = $curlOutput | ConvertFrom-Json
            
            if ($Response.results -and $Response.results.Count -gt 0) {
                $success = $true
                
                $Results = $Response.results | Select-Object -First 10 | ForEach-Object {
                    [PSCustomObject]@{
                        Title = $_.title
                        URL = $_.url
                        Snippet = if ($_.content) { $_.content.Substring(0, [Math]::Min(300, $_.content.Length)) } else { "" }
                        Engine = if ($_.engine) { $_.engine } else { "unknown" }
                    }
                }
                
                $Results | ConvertTo-Json -Depth 3
                exit 0
            }
        }
    } catch {
        # Continue to fallback
    }
}

# Fallback: Return web URL if API access fails
$webUrl = "${SEARXNG_URL}/search?q=${encodedQuery}"
Write-Output ('{"error": "SearXNG API access restricted. Use web interface or configure bot detection", "webUrl": "' + $webUrl + '", "query": "' + $query + '", "suggestion": "Access ' + $webUrl + ' in browser to get results"}')
exit 1
