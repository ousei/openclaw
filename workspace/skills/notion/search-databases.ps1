# Notion Database Search Script
# Usage: .\search-databases.ps1

$apiKey = $env:NOTION_API_KEY
if (-not $apiKey) {
    Write-Host "Error: NOTION_API_KEY environment variable not found" -ForegroundColor Red
    exit 1
}

$headers = @{
    "Authorization" = "Bearer $apiKey"
    "Notion-Version" = "2022-06-28"
    "Content-Type" = "application/json"
}

$body = @{
    filter = @{
        value = "database"
        property = "object"
    }
} | ConvertTo-Json -Depth 10 -Compress

try {
    $response = Invoke-RestMethod -Uri "https://api.notion.com/v1/search" `
        -Method Post `
        -Headers $headers `
        -Body $body
    
    Write-Host "`nFound $($response.results.Count) databases:`n" -ForegroundColor Green
    
    foreach ($db in $response.results) {
        $title = if ($db.title -and $db.title.Count -gt 0) { 
            $db.title[0].plain_text 
        } else { 
            "Untitled Database" 
        }
        $id = $db.id
        
        Write-Host "• $title" -ForegroundColor Cyan
        Write-Host "  ID: $id" -ForegroundColor Gray
        Write-Host ""
    }
    
    return $response
} catch {
    Write-Host "Error: $_" -ForegroundColor Red
    if ($_.Exception.Response) {
        try {
            $reader = New-Object System.IO.StreamReader($_.Exception.Response.GetResponseStream())
            $responseBody = $reader.ReadToEnd()
            $reader.Close()
            Write-Host "Response: $responseBody" -ForegroundColor Yellow
        } catch {
            Write-Host "Could not read error response" -ForegroundColor Yellow
        }
    }
    exit 1
}
