# Query Notion Real Estate Database
# This script queries Notion API for real estate information

# Fix encoding issues - Set console output to UTF-8
[Console]::OutputEncoding = [System.Text.Encoding]::UTF8
$OutputEncoding = [System.Text.Encoding]::UTF8
[Console]::InputEncoding = [System.Text.Encoding]::UTF8
$PSDefaultParameterValues['*:Encoding'] = 'utf8'

# Set API key from environment variable
$apiKey = $env:NOTION_API_KEY
if (-not $apiKey) {
    Write-Host "Error: NOTION_API_KEY not found in environment" -ForegroundColor Red
    Write-Host "Please set it first:" -ForegroundColor Yellow
    Write-Host '  $env:NOTION_API_KEY = "ntn_xxx..."' -ForegroundColor Yellow
    exit 1
}

# 不动产数据库 ID
$databaseId = "2e39fe12-e0aa-814b-88b6-e33aa4afe2f5"

# Create headers hashtable
$headers = @{
    "Authorization"   = "Bearer $apiKey"
    "Notion-Version"  = "2022-06-28"
    "ContentType"     = "application/json"
}

# Output with UTF-8 encoding
[Console]::WriteLine("正在查询 Notion 不动产数据库...")
[Console]::WriteLine("")

try {
    # Query all real estate entries
    $uri = "https://api.notion.com/v1/databases/$databaseId/query"
    [Console]::WriteLine("请求 URL: $uri")
    
    $response = Invoke-RestMethod `
        -Uri $uri `
        -Method POST `
        -Headers $headers `
        -ContentType "application/json"
    
    $entryCount = $response.results.Count
    [Console]::WriteLine("=== 找到 $entryCount 条不动产记录 ===")
    [Console]::WriteLine("")
    
    # Prepare output file path
    $outputFile = Join-Path $PSScriptRoot "real-estate-latest.txt"
    $jsonFile = Join-Path $PSScriptRoot "real-estate-latest.json"
    $utf8NoBom = New-Object System.Text.UTF8Encoding $false
    
    if ($entryCount -eq 0) {
        $noRecordMessage = "未找到不动产记录。"
        [Console]::WriteLine($noRecordMessage)
        [System.IO.File]::WriteAllText($outputFile, $noRecordMessage, $utf8NoBom)
    } else {
        # Build output text with UTF-8 encoding
        $output = New-Object System.Text.StringBuilder
        $output.AppendLine("=== Notion 不动产数据库 ===") | Out-Null
        $output.AppendLine("") | Out-Null
        $output.AppendLine("总计: $entryCount 条记录") | Out-Null
        $output.AppendLine("生成时间: $(Get-Date -Format 'yyyy-MM-dd HH:mm:ss')") | Out-Null
        $output.AppendLine("") | Out-Null
        $output.AppendLine("---") | Out-Null
        $output.AppendLine("") | Out-Null
        
        # Display formatted entries
        $entryNumber = 1
        foreach ($page in $response.results) {
            # Extract title
            $titleProp = $page.properties.PSObject.Properties | Where-Object { 
                $_.Value.title 
            } | Select-Object -First 1
            
            $title = if ($titleProp -and $titleProp.Value.title[0].plain_text) {
                $titleProp.Value.title[0].plain_text
            } else {
                "未命名"
            }
            
            # Extract all properties
            $properties = @{}
            foreach ($propName in $page.properties.PSObject.Properties.Name) {
                $prop = $page.properties.$propName
                
                # Handle different property types
                if ($prop.title) {
                    $properties[$propName] = $prop.title[0].plain_text
                } elseif ($prop.rich_text -and $prop.rich_text.Count -gt 0) {
                    $properties[$propName] = $prop.rich_text[0].plain_text
                } elseif ($prop.select) {
                    $properties[$propName] = $prop.select.name
                } elseif ($prop.number) {
                    $properties[$propName] = $prop.number
                } elseif ($prop.date) {
                    $properties[$propName] = $prop.date.start
                } elseif ($prop.checkbox) {
                    $properties[$propName] = $prop.checkbox
                } elseif ($prop.relation) {
                    $properties[$propName] = "关联对象 (ID: $($prop.relation[0].id))"
                }
            }
            
            # Console output (UTF-8 encoded)
            # Use [Console]::WriteLine for better UTF-8 support
            [Console]::WriteLine("记录 #$entryNumber: $title")
            foreach ($key in $properties.Keys) {
                [Console]::WriteLine("   $key : $($properties[$key])")
            }
            [Console]::WriteLine("   ID: $($page.id)")
            [Console]::WriteLine("")
            
            # File output
            $output.AppendLine("记录 #$entryNumber") | Out-Null
            $output.AppendLine("标题: $title") | Out-Null
            foreach ($key in $properties.Keys) {
                $output.AppendLine("$key : $($properties[$key])") | Out-Null
            }
            $output.AppendLine("创建时间: $($page.created_time)") | Out-Null
            $output.AppendLine("最后编辑: $($page.last_edited_time)") | Out-Null
            $output.AppendLine("ID: $($page.id)") | Out-Null
            $output.AppendLine("URL: $($page.url)") | Out-Null
            $output.AppendLine("") | Out-Null
            $output.AppendLine("---") | Out-Null
            $output.AppendLine("") | Out-Null
            
            $entryNumber++
        }
        
        # Save to UTF-8 file
        [System.IO.File]::WriteAllText($outputFile, $output.ToString(), $utf8NoBom)
        
        [Console]::WriteLine("")
        [Console]::WriteLine("=== 结果已保存到 UTF-8 文件 ===")
        [Console]::WriteLine("文件: $outputFile")
        [Console]::WriteLine("")
        
        # Also save JSON
        $jsonText = $response | ConvertTo-Json -Depth 10
        [System.IO.File]::WriteAllText($jsonFile, $jsonText, $utf8NoBom)
        [Console]::WriteLine("JSON 已保存到: $jsonFile")
        
        # Also output JSON to console for OpenClaw to parse (UTF-8 encoded)
        [Console]::WriteLine("")
        [Console]::WriteLine("=== JSON 输出（供 OpenClaw 解析）===")
        # Output JSON directly to stdout with UTF-8 encoding
        [Console]::Out.Flush()
        $jsonText | Out-String -Width 4096 | ForEach-Object { [Console]::WriteLine($_) }
    }
    
} catch {
    [Console]::WriteLine("")
    [Console]::WriteLine("发生错误:")
    [Console]::WriteLine($_.Exception.Message)
    
    if ($_.Exception.Response) {
        try {
            $stream = $_.Exception.Response.GetResponseStream()
            $reader = New-Object System.IO.StreamReader($stream)
            $errorBody = $reader.ReadToEnd()
            $reader.Close()
            $stream.Close()
            [Console]::WriteLine("")
            [Console]::WriteLine("错误响应:")
            [Console]::WriteLine($errorBody)
            
            # Try to parse JSON error
            try {
                $errorJson = $errorBody | ConvertFrom-Json
                if ($errorJson.message) {
                    [Console]::WriteLine("")
                    [Console]::WriteLine("错误消息: $($errorJson.message)")
                }
                if ($errorJson.code) {
                    [Console]::WriteLine("错误代码: $($errorJson.code)")
                }
            } catch {
                # Not JSON, just show raw response
            }
        } catch {
            [Console]::WriteLine("无法读取错误响应: $_")
        }
    } else {
        [Console]::WriteLine("完整错误详情:")
        $_.Exception | Format-List -Force | Out-String | ForEach-Object { [Console]::WriteLine($_) }
    }
    
    exit 1
}