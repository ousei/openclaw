# Notion To-Do Query Script
# Usage: .\query-todos.ps1 -DatabaseId "your-database-id"

param(
    [Parameter(Mandatory=$true)]
    [string]$DatabaseId,
    
    [string]$Status = "未着手"
)

$apiKey = $env:NOTION_API_KEY
if (-not $apiKey) {
    Write-Host "Error: NOTION_API_KEY environment variable not found" -ForegroundColor Red
    Write-Host "Please set NOTION_API_KEY in .env file" -ForegroundColor Yellow
    exit 1
}

$headers = @{
    "Authorization" = "Bearer $apiKey"
    "Notion-Version" = "2022-06-28"
    "Content-Type" = "application/json"
}

$body = @{
    filter = @{
        property = "ステータス"
        status = @{
            equals = $Status
        }
    }
} | ConvertTo-Json -Depth 10 -Compress

try {
    $response = Invoke-RestMethod -Uri "https://api.notion.com/v1/databases/$DatabaseId/query" `
        -Method Post `
        -Headers $headers `
        -Body $body
    
    Write-Host "`nFound $($response.results.Count) items:`n" -ForegroundColor Green
    
    foreach ($item in $response.results) {
        # Find title property (could be "タスク名", "Name", or title type)
        $titleProp = $item.properties.PSObject.Properties | Where-Object { 
            $_.Value.title -or ($_.Value.PSObject.Properties.Name -contains 'title')
        } | Select-Object -First 1
        
        if ($titleProp -and $titleProp.Value.title -and $titleProp.Value.title.Count -gt 0) {
            $title = $titleProp.Value.title[0].text.content
        } else {
            $title = "Untitled"
        }
        
        # Find status property
        $statusProp = $item.properties.PSObject.Properties | Where-Object { 
            $_.Name -like '*ステータス*' -or $_.Name -like '*Status*'
        } | Select-Object -First 1
        
        if ($statusProp -and $statusProp.Value.status) {
            $status = $statusProp.Value.status.name
        } else {
            $status = "Unknown"
        }
        
        $id = $item.id
        
        Write-Host "• $title" -ForegroundColor Cyan
        Write-Host "  Status: $status | ID: $id" -ForegroundColor Gray
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
