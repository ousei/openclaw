# Query Notion To-Do Items with Debug Output
# This script includes detailed error messages and debugging

# Set API key from environment variable
$apiKey = $env:NOTION_API_KEY
if (-not $apiKey) {
    Write-Host "ERROR: NOTION_API_KEY not found in environment" -ForegroundColor Red
    Write-Host "Current environment variables containing 'NOTION':" -ForegroundColor Yellow
    Get-ChildItem Env: | Where-Object { $_.Name -like '*NOTION*' } | ForEach-Object {
        Write-Host "  $($_.Name) = $($_.Value.Substring(0, [Math]::Min(20, $_.Value.Length)))..." -ForegroundColor Gray
    }
    Write-Host "`nPlease set it:" -ForegroundColor Yellow
    Write-Host '  $env:NOTION_API_KEY = "ntn_xxx..."' -ForegroundColor Yellow
    exit 1
}

Write-Host "API Key found: $($apiKey.Substring(0, [Math]::Min(20, $apiKey.Length)))..." -ForegroundColor Green

$databaseId = "2e29fe12-e0aa-816e-9366-dae1fbe6fd20"
Write-Host "Database ID: $databaseId" -ForegroundColor Cyan
Write-Host ""

# Create headers hashtable
$headers = @{
    "Authorization"   = "Bearer $apiKey"
    "Notion-Version"  = "2022-06-28"
    "Content-Type"    = "application/json"
}

Write-Host "Querying Notion API..." -ForegroundColor Cyan

try {
    # Query all tasks first, then filter in PowerShell (more reliable)
    $uri = "https://api.notion.com/v1/databases/$databaseId/query"
    Write-Host "Request URI: $uri" -ForegroundColor Gray
    
    $response = Invoke-RestMethod `
        -Uri $uri `
        -Method POST `
        -Headers $headers `
        -ContentType "application/json"
    
    Write-Host "API call successful!" -ForegroundColor Green
    Write-Host "Total tasks returned: $($response.results.Count)" -ForegroundColor Green
    Write-Host ""
    
    # Filter for tasks with status "not-started" (未着手)
    $filteredResults = @()
    foreach ($page in $response.results) {
        $statusProp = $page.properties.PSObject.Properties | Where-Object { 
            $_.Value.status 
        } | Select-Object -First 1
        
        if ($statusProp -and $statusProp.Value.status.id -eq "not-started") {
            $filteredResults += $page
        }
    }
    
    Write-Host "=== Found $($filteredResults.Count) tasks with status '未着手' (not-started) ===`n" -ForegroundColor Green
    
    if ($filteredResults.Count -eq 0) {
        Write-Host "No tasks found with status '未着手'" -ForegroundColor Yellow
        Write-Host "`nStatus breakdown:" -ForegroundColor Cyan
        $statusCounts = @{}
        foreach ($page in $response.results) {
            $statusProp = $page.properties.PSObject.Properties | Where-Object { $_.Value.status } | Select-Object -First 1
            if ($statusProp) {
                $statusId = $statusProp.Value.status.id
                if (-not $statusCounts[$statusId]) {
                    $statusCounts[$statusId] = 0
                }
                $statusCounts[$statusId]++
            }
        }
        foreach ($statusId in $statusCounts.Keys) {
            Write-Host "  $statusId : $($statusCounts[$statusId]) tasks" -ForegroundColor Gray
        }
    } else {
        # Display formatted task list
        $taskNumber = 1
        foreach ($page in $filteredResults) {
            # Find title property
            $title = "Untitled"
            foreach ($propName in $page.properties.PSObject.Properties.Name) {
                $prop = $page.properties.$propName
                if ($prop.title -and $prop.title.Count -gt 0 -and $prop.title[0].text) {
                    $title = $prop.title[0].text.content
                    break
                }
            }
            
            # Find status
            $status = "Unknown"
            $statusProp = $page.properties.PSObject.Properties | Where-Object { 
                $_.Value.status 
            } | Select-Object -First 1
            
            if ($statusProp -and $statusProp.Value.status) {
                $status = $statusProp.Value.status.name
            }
            
            # Find due date
            $dueDate = $null
            foreach ($propName in $page.properties.PSObject.Properties.Name) {
                $prop = $page.properties.$propName
                if ($prop.date -and $prop.date.start) {
                    $dueDate = $prop.date.start
                    break
                }
            }
            
            # Find priority
            $priority = $null
            foreach ($propName in $page.properties.PSObject.Properties.Name) {
                if ($propName -like '*優先度*' -or $propName -like '*Priority*') {
                    $priorityProp = $page.properties.$propName
                    if ($priorityProp.select) {
                        $priority = $priorityProp.select.name
                    }
                    break
                }
            }
            
            # Display task
            Write-Host "$taskNumber. $title" -ForegroundColor Cyan
            Write-Host "   Status: $status" -ForegroundColor Gray
            if ($dueDate) {
                Write-Host "   Due: $dueDate" -ForegroundColor Gray
            }
            if ($priority) {
                Write-Host "   Priority: $priority" -ForegroundColor Gray
            }
            Write-Host "   ID: $($page.id)" -ForegroundColor DarkGray
            Write-Host ""
            
            $taskNumber++
        }
    }
    
    # Output raw JSON for further processing
    Write-Host "`n=== Raw JSON (copy this to share) ===" -ForegroundColor Yellow
    $jsonOutput = @{
        object = "list"
        results = $filteredResults
    }
    Write-Host ($jsonOutput | ConvertTo-Json -Depth 10)
    
} catch {
    Write-Host "`n=== ERROR OCCURRED ===" -ForegroundColor Red
    Write-Host "Error Message: $($_.Exception.Message)" -ForegroundColor Red
    
    if ($_.Exception.Response) {
        Write-Host "`nHTTP Status: $($_.Exception.Response.StatusCode.value__)" -ForegroundColor Yellow
        Write-Host "Status Description: $($_.Exception.Response.StatusDescription)" -ForegroundColor Yellow
        
        try {
            $stream = $_.Exception.Response.GetResponseStream()
            $reader = New-Object System.IO.StreamReader($stream)
            $errorBody = $reader.ReadToEnd()
            $reader.Close()
            $stream.Close()
            
            Write-Host "`nError Response Body:" -ForegroundColor Yellow
            Write-Host $errorBody -ForegroundColor Yellow
            
            # Try to parse JSON error
            try {
                $errorJson = $errorBody | ConvertFrom-Json
                if ($errorJson.message) {
                    Write-Host "`nParsed Error Message: $($errorJson.message)" -ForegroundColor Red
                }
                if ($errorJson.code) {
                    Write-Host "Error Code: $($errorJson.code)" -ForegroundColor Red
                }
            } catch {
                Write-Host "Could not parse error as JSON" -ForegroundColor Gray
            }
        } catch {
            Write-Host "Could not read error response: $_" -ForegroundColor Yellow
        }
    } else {
        Write-Host "`nFull Exception Details:" -ForegroundColor Yellow
        $_.Exception | Format-List -Force | Out-String | Write-Host
    }
    
    Write-Host "`nDebugging Info:" -ForegroundColor Cyan
    Write-Host "  API Key length: $($apiKey.Length)" -ForegroundColor Gray
    Write-Host "  API Key starts with: $($apiKey.Substring(0, [Math]::Min(10, $apiKey.Length)))" -ForegroundColor Gray
    Write-Host "  Database ID: $databaseId" -ForegroundColor Gray
    Write-Host "  Request URI: https://api.notion.com/v1/databases/$databaseId/query" -ForegroundColor Gray
    
    exit 1
}
