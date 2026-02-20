# Simple Notion To-Do Query Script
# Usage: Just run this script - it will use environment variable for API key

$apiKey = $env:NOTION_API_KEY
if (-not $apiKey) {
    Write-Host "Error: NOTION_API_KEY not found in environment" -ForegroundColor Red
    Write-Host "Please set it first: `$env:NOTION_API_KEY = 'your-key'" -ForegroundColor Yellow
    exit 1
}

$databaseId = "2e29fe12-e0aa-816e-9366-dae1fbe6fd20"

# Create headers hashtable
$headers = @{
    "Authorization"   = "Bearer $apiKey"
    "Notion-Version"  = "2022-06-28"
    "Content-Type"    = "application/json"
}

# Create body as here-string to avoid escaping issues
$body = @"
{
  "filter": {
    "property": "ステータス",
    "status": {
      "equals": "未着手"
    }
  }
}
"@

try {
    Write-Host "Querying Notion API..." -ForegroundColor Cyan
    
    $response = Invoke-RestMethod `
        -Uri "https://api.notion.com/v1/databases/$databaseId/query" `
        -Method POST `
        -Headers $headers `
        -Body $body `
        -ContentType "application/json"
    
    Write-Host "`n=== Found $($response.results.Count) tasks ===`n" -ForegroundColor Green
    
    if ($response.results.Count -eq 0) {
        Write-Host "No tasks found with status '未着手'" -ForegroundColor Yellow
    } else {
        foreach ($item in $response.results) {
            # Find title property dynamically
            $titleProp = $null
            foreach ($propName in $item.properties.PSObject.Properties.Name) {
                $prop = $item.properties.$propName
                if ($prop.title -and $prop.title.Count -gt 0) {
                    $titleProp = $prop
                    break
                }
            }
            
            $title = if ($titleProp -and $titleProp.title[0].text.content) {
                $titleProp.title[0].text.content
            } else {
                "Untitled"
            }
            
            # Find status
            $statusProp = $null
            foreach ($propName in $item.properties.PSObject.Properties.Name) {
                if ($propName -like '*ステータス*' -or $propName -like '*Status*') {
                    $statusProp = $item.properties.$propName
                    break
                }
            }
            
            $status = if ($statusProp -and $statusProp.status) {
                $statusProp.status.name
            } else {
                "Unknown"
            }
            
            # Find due date if exists
            $dueDate = $null
            foreach ($propName in $item.properties.PSObject.Properties.Name) {
                $prop = $item.properties.$propName
                if ($prop.date -and $prop.date.start) {
                    $dueDate = $prop.date.start
                    break
                }
            }
            
            Write-Host "• $title" -ForegroundColor Cyan
            Write-Host "  Status: $status" -ForegroundColor Gray
            if ($dueDate) {
                Write-Host "  Due: $dueDate" -ForegroundColor Gray
            }
            Write-Host "  ID: $($item.id)" -ForegroundColor DarkGray
            Write-Host ""
        }
    }
    
    # Also output raw JSON for further processing
    Write-Host "`n=== Raw JSON (for copying) ===" -ForegroundColor Yellow
    $response | ConvertTo-Json -Depth 10
    
} catch {
    Write-Host "`nError occurred:" -ForegroundColor Red
    Write-Host $_.Exception.Message -ForegroundColor Red
    
    if ($_.Exception.Response) {
        try {
            $reader = New-Object System.IO.StreamReader($_.Exception.Response.GetResponseStream())
            $errorBody = $reader.ReadToEnd()
            $reader.Close()
            Write-Host "`nError Response:" -ForegroundColor Yellow
            Write-Host $errorBody -ForegroundColor Yellow
        } catch {
            Write-Host "Could not read error response" -ForegroundColor Yellow
        }
    }
    
    exit 1
}
