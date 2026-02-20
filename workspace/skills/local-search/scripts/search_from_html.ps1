# Universal SearXNG Search Script - Extracts results from HTML
# Usage: .\search_from_html.ps1 "your search query"
# Returns: JSON formatted search results
# This script works around SearXNG bot detection by extracting results from HTML page

param(
    [Parameter(Mandatory=$true)]
    [string]$Query
)

# SearXNG instance URL (port 18888)
$SEARXNG_URL = if ($env:SEARXNG_URL) { $env:SEARXNG_URL } else { "http://localhost:18888" }

# URL encoding
try {
    Add-Type -AssemblyName System.Web
    $encodedQuery = [System.Web.HttpUtility]::UrlEncode($Query)
} catch {
    $encodedQuery = $Query -replace ' ', '%20' -replace '&', '%26'
}

# Build search URL
$SearchUrl = "${SEARXNG_URL}/search?q=${encodedQuery}"

try {
    # Fetch HTML page using curl (more reliable in non-interactive mode)
    $htmlContent = curl.exe -s -L -H "User-Agent: Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36" -H "Accept: text/html" "$SearchUrl" 2>&1
    
    if ($LASTEXITCODE -ne 0) {
        throw "curl failed with exit code $LASTEXITCODE"
    }
    
    # Extract result links from HTML (SearXNG structure)
    $resultLinks = [regex]::Matches($htmlContent, '<h3[^>]*class="[^"]*result[^"]*"[^>]*><a[^>]*href="([^"]+)"[^>]*>([^<]+)</a></h3>', [System.Text.RegularExpressions.RegexOptions]::IgnoreCase)
    
    # Alternative pattern if above doesn't match
    if ($resultLinks.Count -eq 0) {
        $resultLinks = [regex]::Matches($htmlContent, 'href="(https?://[^"]+)"[^>]*>([^<]{10,100})</a>', [System.Text.RegularExpressions.RegexOptions]::IgnoreCase)
    }
    
    if ($resultLinks.Count -gt 0) {
        $Results = @()
        $addedCount = 0
        $maxResults = 10
        
        for ($i = 0; $i -lt $resultLinks.Count -and $addedCount -lt $maxResults; $i++) {
            $match = $resultLinks[$i]
            $url = $match.Groups[1].Value
            $title = $match.Groups[2].Value
            
            # Filter out SearXNG internal links
            if ($url -match "github.com/searxng|searx.space|searxng.org") {
                continue
            }
            
            # Extract snippet if available
            $snippet = ""
            $linkPos = $match.Index
            $remainingLength = $htmlContent.Length - $linkPos
            if ($remainingLength -gt 0) {
                $searchLength = [Math]::Min(800, $remainingLength)
                $searchArea = $htmlContent.Substring($linkPos, $searchLength)
                
                # Try multiple patterns for snippet extraction
                $snippetMatch = [regex]::Match($searchArea, '<p[^>]*class="[^"]*content[^"]*"[^>]*>([^<]{50,300})</p>', [System.Text.RegularExpressions.RegexOptions]::IgnoreCase)
                if (-not $snippetMatch.Success) {
                    $snippetMatch = [regex]::Match($searchArea, '<span[^>]*class="[^"]*content[^"]*"[^>]*>([^<]{50,300})</span>', [System.Text.RegularExpressions.RegexOptions]::IgnoreCase)
                }
                if ($snippetMatch.Success) {
                    $snippet = $snippetMatch.Groups[1].Value.Trim()
                }
            }
            
            $Results += [PSCustomObject]@{
                Title = $title
                URL = $url
                Snippet = $snippet
            }
            $addedCount++
        }
        
        # Output as JSON
        $Results | ConvertTo-Json -Depth 3
        exit 0
    } else {
        Write-Output ('{"error": "No results found in HTML", "webUrl": "' + $SearchUrl + '", "query": "' + $Query + '"}')
        exit 1
    }
    
} catch {
    $ErrorMessage = $_.Exception.Message
    Write-Output ('{"error": "' + $ErrorMessage + '", "webUrl": "' + $SearchUrl + '", "query": "' + $Query + '"}')
    exit 1
}
