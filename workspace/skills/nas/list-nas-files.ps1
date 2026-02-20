# List NAS Files - 列出 NAS 路径下的文件
# 使用变量代替直接路径，避免 OpenClaw 识别错误

# Step 1: Set UTF-8 encoding
[Console]::OutputEncoding = [System.Text.Encoding]::UTF8
$OutputEncoding = [System.Text.Encoding]::UTF8
[Console]::InputEncoding = [System.Text.Encoding]::UTF8
chcp 65001 | Out-Null

# Step 2: Define NAS paths using variables (avoid OpenClaw misidentification)
$Nas = "\\nas"
$NasHomes = "\\nas\homes"
$NasHomesWeng = "\\nas\homes\weng"

# Step 3: Connect to NAS
Write-Host "=== 连接 NAS ===" -ForegroundColor Cyan
net use * /delete /yes 2>$null | Out-Null
$result = net use $NasHomes /user:nas\weng 19801502 /persistent:yes 2>&1
if ($LASTEXITCODE -eq 0) {
    Write-Host "✅ NAS 连接成功" -ForegroundColor Green
} else {
    Write-Host "❌ NAS 连接失败: $result" -ForegroundColor Red
    exit 1
}
Write-Host ""

# Wait for connection to stabilize
Start-Sleep -Seconds 2

# Step 4: Define target path using variable
$targetPath = "$NasHomesWeng\履歴書"

Write-Host "=== 检查路径 ===" -ForegroundColor Cyan
Write-Host "目标路径: $targetPath" -ForegroundColor Gray

# Step 5: Check if path exists
if (Test-Path $targetPath) {
    Write-Host "✅ 路径存在" -ForegroundColor Green
    Write-Host ""
    
    try {
        # Step 6: Get file list with UTF-8 encoding
        Write-Host "=== 文件列表 ===" -ForegroundColor Cyan
        Write-Host ""
        
        $files = Get-ChildItem -Path $targetPath -Force -ErrorAction Stop -Recurse | 
            Select-Object @{
                Name='FileName'
                Expression={$_.Name}
            }, @{
                Name='FilePath'
                Expression={$_.FullName}
            }, @{
                Name='Type'
                Expression={if ($_.PSIsContainer) { "目录" } else { "文件" }}
            }, @{
                Name='Size'
                Expression={if (-not $_.PSIsContainer) { "{0:N2} KB" -f ($_.Length / 1KB) } else { "-" }}
            }, @{
                Name='CreationTime'
                Expression={$_.CreationTime.ToString("yyyy-MM-dd HH:mm:ss")}
            }, @{
                Name='LastWriteTime'
                Expression={$_.LastWriteTime.ToString("yyyy-MM-dd HH:mm:ss")}
            }
        
        # Output files
        $fileCount = ($files | Where-Object { $_.Type -eq "文件" }).Count
        $dirCount = ($files | Where-Object { $_.Type -eq "目录" }).Count
        
        Write-Host "统计: 文件 $fileCount 个, 目录 $dirCount 个" -ForegroundColor Yellow
        Write-Host ""
        
        # Display files
        foreach ($file in $files) {
            $typeIcon = if ($file.Type -eq "目录") { "[DIR]" } else { "[FILE]" }
            [Console]::WriteLine("$typeIcon $($file.FileName)")
            [Console]::WriteLine("    路径: $($file.FilePath)")
            [Console]::WriteLine("    大小: $($file.Size)")
            [Console]::WriteLine("    创建: $($file.CreationTime)")
            [Console]::WriteLine("    修改: $($file.LastWriteTime)")
            [Console]::WriteLine("")
        }
        
        # Also output as JSON for OpenClaw parsing
        Write-Host "=== JSON 输出（供 OpenClaw 解析）===" -ForegroundColor Yellow
        $files | ConvertTo-Json -Depth 3 | ForEach-Object { [Console]::WriteLine($_) }
        
    } catch {
        Write-Host "❌ 错误: $($_.Exception.Message)" -ForegroundColor Red
        Write-Host "   错误类型: $($_.Exception.GetType().FullName)" -ForegroundColor DarkYellow
        exit 1
    }
} else {
    Write-Host "❌ 路径不存在或无法访问: $targetPath" -ForegroundColor Red
    Write-Host ""
    Write-Host "尝试列出父目录内容..." -ForegroundColor Yellow
    try {
        $parentItems = Get-ChildItem $NasHomesWeng -ErrorAction Stop | Select-Object -First 20
        Write-Host "父目录内容:" -ForegroundColor Cyan
        foreach ($item in $parentItems) {
            $type = if ($item.PSIsContainer) { "[DIR]" } else { "[FILE]" }
            [Console]::WriteLine("$type $($item.Name)")
        }
    } catch {
        Write-Host "无法列出父目录: $($_.Exception.Message)" -ForegroundColor Red
    }
    exit 1
}

Write-Host ""
Write-Host "=== 完成 ===" -ForegroundColor Cyan
