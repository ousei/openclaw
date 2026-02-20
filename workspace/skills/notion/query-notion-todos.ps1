# Query Notion To-Do Items
# This script queries Notion API for tasks with status "未着手"

# Set API key from environment variable
$apiKey = $env:NOTION_API_KEY
if (-not $apiKey) {
    Write-Host "Error: NOTION_API_KEY not found in environment" -ForegroundColor Red
    Write-Host "Please set it first:" -ForegroundColor Yellow
    Write-Host '  $env:NOTION_API_KEY = "ntn_xxx..."' -ForegroundColor Yellow
    exit 1
}

$databaseId = "2e29fe12-e0aa-816e-9366-dae1fbe6fd20"

# Create headers hashtable
$headers = @{
    "Authorization"   = "Bearer $apiKey"
    "Notion-Version"  = "2022-06-28"
    "Content-Type"    = "application/json"
}

Write-Host "Querying Notion API for tasks with status '未着手' (not-started)..." -ForegroundColor Cyan
Write-Host ""

try {
    # Query all tasks first, then filter in PowerShell (more reliable)
    $response = Invoke-RestMethod `
        -Uri "https://api.notion.com/v1/databases/$databaseId/query" `
        -Method POST `
        -Headers $headers `
        -ContentType "application/json"
    
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
    
    # Replace results with filtered ones
    $response.results = $filteredResults
    
    $taskCount = $response.results.Count
    Write-Host "=== Found $taskCount tasks ===`n" -ForegroundColor Green
    
    # Prepare output file path
    $outputFile = Join-Path $PSScriptRoot "notion-todos-latest.txt"
    $jsonFile = Join-Path $PSScriptRoot "notion-todos-latest.json"
    $utf8NoBom = New-Object System.Text.UTF8Encoding $false
    
    if ($taskCount -eq 0) {
        Write-Host "No tasks found with status '未着手'" -ForegroundColor Yellow
        [System.IO.File]::WriteAllText($outputFile, "No tasks found.", $utf8NoBom)
    } else {
        # Build output text with UTF-8 encoding (to avoid console encoding issues)
        $output = New-Object System.Text.StringBuilder
        $output.AppendLine("=== Notion Tasks (Status: Not Started) ===") | Out-Null
        $output.AppendLine("") | Out-Null
        $output.AppendLine("Total: $taskCount tasks") | Out-Null
        $output.AppendLine("Generated: $(Get-Date -Format 'yyyy-MM-dd HH:mm:ss')") | Out-Null
        $output.AppendLine("") | Out-Null
        $output.AppendLine("---") | Out-Null
        $output.AppendLine("") | Out-Null
        
        # Display formatted task list (console summary)
        $taskNumber = 1
        foreach ($page in $response.results) {
            # Extract title from plain_text (correct UTF-8 text)
            $titleProp = $page.properties.PSObject.Properties | Where-Object { 
                $_.Value.title 
            } | Select-Object -First 1
            
            $title = if ($titleProp -and $titleProp.Value.title[0].plain_text) {
                $titleProp.Value.title[0].plain_text
            } else {
                "Untitled"
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
            
            # Console output (avoid Japanese to prevent encoding issues)
            Write-Host "Task #$taskNumber" -ForegroundColor Cyan
            Write-Host "   Status: $status" -ForegroundColor Gray
            if ($dueDate) {
                Write-Host "   Due: $dueDate" -ForegroundColor Gray
            }
            if ($priority) {
                Write-Host "   Priority: $priority" -ForegroundColor Gray
            }
            Write-Host "   ID: $($page.id)" -ForegroundColor DarkGray
            Write-Host ""
            
            # File output (with correct Japanese)
            $output.AppendLine("Task #$taskNumber") | Out-Null
            $output.AppendLine("Title: $title") | Out-Null
            $output.AppendLine("Status: $status") | Out-Null
            if ($dueDate) {
                $output.AppendLine("Due Date: $dueDate") | Out-Null
            }
            if ($priority) {
                $output.AppendLine("Priority: $priority") | Out-Null
            }
            $output.AppendLine("Created: $($page.created_time)") | Out-Null
            $output.AppendLine("Last Edited: $($page.last_edited_time)") | Out-Null
            $output.AppendLine("ID: $($page.id)") | Out-Null
            $output.AppendLine("URL: $($page.url)") | Out-Null
            $output.AppendLine("") | Out-Null
            $output.AppendLine("---") | Out-Null
            $output.AppendLine("") | Out-Null
            
            $taskNumber++
        }
        
        # Save to UTF-8 file
        [System.IO.File]::WriteAllText($outputFile, $output.ToString(), $utf8NoBom)
        
        Write-Host "`n=== Results saved to UTF-8 file ===" -ForegroundColor Green
        Write-Host "File: $outputFile" -ForegroundColor Cyan
        Write-Host "Open this file in VS Code or Notepad++ to see correct Japanese titles" -ForegroundColor Yellow
        Write-Host ""
        
        # Also save JSON
        $jsonText = $response | ConvertTo-Json -Depth 10
        [System.IO.File]::WriteAllText($jsonFile, $jsonText, $utf8NoBom)
        Write-Host "JSON saved to: $jsonFile" -ForegroundColor Gray
    }
    
} catch {
    Write-Host "`nError occurred:" -ForegroundColor Red
    Write-Host $_.Exception.Message -ForegroundColor Red
    
    if ($_.Exception.Response) {
        try {
            $stream = $_.Exception.Response.GetResponseStream()
            $reader = New-Object System.IO.StreamReader($stream)
            $errorBody = $reader.ReadToEnd()
            $reader.Close()
            $stream.Close()
            Write-Host "`nError Response:" -ForegroundColor Yellow
            Write-Host $errorBody -ForegroundColor Yellow
            
            # Try to parse JSON error
            try {
                $errorJson = $errorBody | ConvertFrom-Json
                if ($errorJson.message) {
                    Write-Host "`nError Message: $($errorJson.message)" -ForegroundColor Yellow
                }
                if ($errorJson.code) {
                    Write-Host "Error Code: $($errorJson.code)" -ForegroundColor Yellow
                }
            } catch {
                # Not JSON, just show raw response
            }
        } catch {
            Write-Host "Could not read error response: $_" -ForegroundColor Yellow
        }
    } else {
        Write-Host "Full Error Details:" -ForegroundColor Yellow
        Write-Host $_.Exception | Format-List -Force | Out-String
    }
    
    exit 1
}
