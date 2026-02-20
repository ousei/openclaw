# Query All Notion Tasks (no filter)
# This script queries all tasks from Notion database

$apiKey = $env:NOTION_API_KEY
if (-not $apiKey) {
    Write-Host "Error: NOTION_API_KEY not found in environment" -ForegroundColor Red
    Write-Host 'Please set it: $env:NOTION_API_KEY = "ntn_xxx..."' -ForegroundColor Yellow
    exit 1
}

$databaseId = "2e29fe12-e0aa-816e-9366-dae1fbe6fd20"

$headers = @{
    "Authorization"   = "Bearer $apiKey"
    "Notion-Version"  = "2022-06-28"
    "Content-Type"    = "application/json"
}

Write-Host "Querying all tasks from Notion..." -ForegroundColor Cyan
Write-Host ""

try {
    $response = Invoke-RestMethod `
        -Uri "https://api.notion.com/v1/databases/$databaseId/query" `
        -Method POST `
        -Headers $headers `
        -ContentType "application/json"
    
    Write-Host "=== Found $($response.results.Count) total tasks ===`n" -ForegroundColor Green
    
    # Group by status
    $byStatus = @{}
    foreach ($page in $response.results) {
        $status = "Unknown"
        foreach ($propName in $page.properties.PSObject.Properties.Name) {
            if ($propName -like '*ステータス*' -or $propName -like '*Status*') {
                $statusProp = $page.properties.$propName
                if ($statusProp.status) {
                    $status = $statusProp.status.name
                }
                break
            }
        }
        
        if (-not $byStatus[$status]) {
            $byStatus[$status] = @()
        }
        $byStatus[$status] += $page
    }
    
    # Display grouped by status
    foreach ($status in $byStatus.Keys | Sort-Object) {
        Write-Host "`n--- $status ($($byStatus[$status].Count) tasks) ---" -ForegroundColor Yellow
        foreach ($page in $byStatus[$status]) {
            $title = "Untitled"
            foreach ($propName in $page.properties.PSObject.Properties.Name) {
                $prop = $page.properties.$propName
                if ($prop.title -and $prop.title.Count -gt 0 -and $prop.title[0].text) {
                    $title = $prop.title[0].text.content
                    break
                }
            }
            Write-Host "  • $title" -ForegroundColor Cyan
        }
    }
    
    # Output raw JSON
    Write-Host "`n`n=== Raw JSON ===" -ForegroundColor Yellow
    Write-Host ($response | ConvertTo-Json -Depth 10)
    
} catch {
    Write-Host "`nError: $($_.Exception.Message)" -ForegroundColor Red
    exit 1
}
