# Export Notion To-Do Items to UTF-8 File
# This script saves results to a UTF-8 encoded file to avoid PowerShell console encoding issues

$apiKey = $env:NOTION_API_KEY
if (-not $apiKey) {
    Write-Host "Error: NOTION_API_KEY not found in environment" -ForegroundColor Red
    exit 1
}

$databaseId = "2e29fe12-e0aa-816e-9366-dae1fbe6fd20"
$outputFile = Join-Path $PSScriptRoot "notion-todos-utf8.txt"

$headers = @{
    "Authorization"   = "Bearer $apiKey"
    "Notion-Version"  = "2022-06-28"
    "Content-Type"    = "application/json"
}

Write-Host "Querying Notion API..." -ForegroundColor Cyan

try {
    $response = Invoke-RestMethod `
        -Uri "https://api.notion.com/v1/databases/$databaseId/query" `
        -Method POST `
        -Headers $headers `
        -ContentType "application/json"
    
    $notStartedTasks = @()
    foreach ($page in $response.results) {
        $statusProp = $page.properties.PSObject.Properties | Where-Object { 
            $_.Value.status 
        } | Select-Object -First 1
        
        if ($statusProp -and $statusProp.Value.status.id -eq "not-started") {
            $notStartedTasks += $page
        }
    }
    
    Write-Host "Found $($notStartedTasks.Count) tasks" -ForegroundColor Green
    
    $output = New-Object System.Text.StringBuilder
    $output.AppendLine("=== Notion Tasks (Status: Not Started) ===") | Out-Null
    $output.AppendLine("") | Out-Null
    $output.AppendLine("Total: $($notStartedTasks.Count) tasks") | Out-Null
    $output.AppendLine("Generated: $(Get-Date -Format 'yyyy-MM-dd HH:mm:ss')") | Out-Null
    $output.AppendLine("") | Out-Null
    $output.AppendLine("---") | Out-Null
    $output.AppendLine("") | Out-Null
    
    $taskNumber = 1
    foreach ($page in $notStartedTasks) {
        $titleProp = $page.properties.PSObject.Properties | Where-Object { 
            $_.Value.title 
        } | Select-Object -First 1
        
        $title = if ($titleProp -and $titleProp.Value.title[0].plain_text) {
            $titleProp.Value.title[0].plain_text
        } else {
            "Untitled"
        }
        
        $statusProp = $page.properties.PSObject.Properties | Where-Object { 
            $_.Value.status 
        } | Select-Object -First 1
        
        $status = if ($statusProp -and $statusProp.Value.status.name) {
            $statusProp.Value.status.name
        } else {
            "Unknown"
        }
        
        $priorityProp = $page.properties.PSObject.Properties | Where-Object { 
            $_.Value.select -and ($_.Name -like '*優先度*' -or $_.Name -like '*Priority*')
        } | Select-Object -First 1
        
        $priority = if ($priorityProp -and $priorityProp.Value.select.name) {
            $priorityProp.Value.select.name
        } else {
            "Not set"
        }
        
        $dueDateProp = $page.properties.PSObject.Properties | Where-Object { 
            $_.Value.date 
        } | Select-Object -First 1
        
        $dueDate = if ($dueDateProp -and $dueDateProp.Value.date.start) {
            $dueDateProp.Value.date.start
        } else {
            "None"
        }
        
        $output.AppendLine("Task #$taskNumber") | Out-Null
        $output.AppendLine("Title: $title") | Out-Null
        $output.AppendLine("Status: $status") | Out-Null
        $output.AppendLine("Priority: $priority") | Out-Null
        $output.AppendLine("Due Date: $dueDate") | Out-Null
        $output.AppendLine("Created: $($page.created_time)") | Out-Null
        $output.AppendLine("Last Edited: $($page.last_edited_time)") | Out-Null
        $output.AppendLine("ID: $($page.id)") | Out-Null
        $output.AppendLine("URL: $($page.url)") | Out-Null
        $output.AppendLine("") | Out-Null
        $output.AppendLine("---") | Out-Null
        $output.AppendLine("") | Out-Null
        
        $taskNumber++
    }
    
    $utf8NoBom = New-Object System.Text.UTF8Encoding $false
    [System.IO.File]::WriteAllText($outputFile, $output.ToString(), $utf8NoBom)
    
    Write-Host "Results saved to:" -ForegroundColor Green
    Write-Host $outputFile -ForegroundColor Cyan
    Write-Host "Open this file in VS Code or Notepad++ to see correct Japanese text" -ForegroundColor Yellow
    
    $jsonFile = Join-Path $PSScriptRoot "notion-todos-utf8.json"
    $jsonOutput = @{
        object = "list"
        results = $notStartedTasks
    }
    $jsonText = $jsonOutput | ConvertTo-Json -Depth 10
    [System.IO.File]::WriteAllText($jsonFile, $jsonText, $utf8NoBom)
    Write-Host "JSON saved to: $jsonFile" -ForegroundColor Gray
    
} catch {
    Write-Host "Error: $($_.Exception.Message)" -ForegroundColor Red
    if ($_.Exception.Response) {
        try {
            $stream = $_.Exception.Response.GetResponseStream()
            $reader = New-Object System.IO.StreamReader($stream)
            $errorBody = $reader.ReadToEnd()
            $reader.Close()
            $stream.Close()
            Write-Host "Error Response: $errorBody" -ForegroundColor Yellow
        } catch {
            Write-Host "Could not read error response" -ForegroundColor Yellow
        }
    }
    exit 1
}
