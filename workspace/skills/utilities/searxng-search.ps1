# Universal SearXNG Search Function
# This script can be sourced by other PowerShell scripts to use SearXNG search
# Usage in other scripts:
#   . .\searxng-search.ps1
#   $results = Search-SearXNG "your query"

function Search-SearXNG {
    param(
        [Parameter(Mandatory=$true)]
        [string]$Query,
        
        [Parameter(Mandatory=$false)]
        [int]$MaxResults = 10,
        
        [Parameter(Mandatory=$false)]
        [string]$SearXNG_URL = "http://localhost:18888"
    )
    
    # URL encoding
    try {
        Add-Type -AssemblyName System.Web
        $encodedQuery = [System.Web.HttpUtility]::UrlEncode($Query)
    } catch {
        $encodedQuery = $Query -replace ' ', '%20' -replace '&', '%26'
    }
    
    # Build search URL
    $SearchUrl = "${SearXNG_URL}/search?q=${encodedQuery}"
    
    try {
        # Fetch HTML page using curl
        $htmlContent = curl.exe -s -L -H "User-Agent: Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36" -H "Accept: text/html" "$SearchUrl" 2>&1
        
        if ($LASTEXITCODE -ne 0) {
            throw "curl failed with exit code $LASTEXITCODE"
        }
        
        # Extract result links from HTML
        $resultLinks = [regex]::Matches($htmlContent, '<h3[^>]*class="[^"]*result[^"]*"[^>]*><a[^>]*href="([^"]+)"[^>]*>([^<]+)</a></h3>', [System.Text.RegularExpressions.RegexOptions]::IgnoreCase)
        
        if ($resultLinks.Count -eq 0) {
            $resultLinks = [regex]::Matches($htmlContent, 'href="(https?://[^"]+)"[^>]*>([^<]{10,100})</a>', [System.Text.RegularExpressions.RegexOptions]::IgnoreCase)
        }
        
        if ($resultLinks.Count -gt 0) {
            $Results = @()
            $addedCount = 0
            
            for ($i = 0; $i -lt $resultLinks.Count -and $addedCount -lt $MaxResults; $i++) {
                $match = $resultLinks[$i]
                $url = $match.Groups[1].Value
                $title = $match.Groups[2].Value
                
                # Filter out SearXNG internal links
                if ($url -match "github.com/searxng|searx.space|searxng.org") {
                    continue
                }
                
                # Extract snippet
                $snippet = ""
                $linkPos = $match.Index
                $remainingLength = $htmlContent.Length - $linkPos
                if ($remainingLength -gt 0) {
                    $searchLength = [Math]::Min(800, $remainingLength)
                    $searchArea = $htmlContent.Substring($linkPos, $searchLength)
                    
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
            
            return $Results
        } else {
            return @()
        }
        
    } catch {
        Write-Error "Search failed: $($_.Exception.Message)"
        return @()
    }
}

# Export function
Export-ModuleMember -Function Search-SearXNG
