# Access NAS with Japanese Character Paths
# 访问包含日文字符的 NAS 路径

# Step 1: Set UTF-8 encoding
[Console]::OutputEncoding = [System.Text.Encoding]::UTF8
$OutputEncoding = [System.Text.Encoding]::UTF8
[Console]::InputEncoding = [System.Text.Encoding]::UTF8
chcp 65001 | Out-Null

Write-Host "=== NAS 访问脚本（支持日文字符）===" -ForegroundColor Cyan
Write-Host ""

# Step 2: Connect to NAS
Write-Host "[步骤 1] 连接 NAS 共享..." -ForegroundColor Yellow
net use * /delete /yes 2>$null | Out-Null
$result = net use \\nas\homes /user:nas\weng 19801502 /persistent:yes 2>&1
if ($LASTEXITCODE -eq 0) {
    Write-Host "✅ 连接成功" -ForegroundColor Green
} else {
    Write-Host "❌ 连接失败: $result" -ForegroundColor Red
    exit 1
}
Write-Host ""

# Wait for connection to stabilize
Start-Sleep -Seconds 2

# Step 3: List weng directory contents
Write-Host "[步骤 2] 列出 \\nas\homes\weng 目录内容..." -ForegroundColor Yellow
$wengPath = "\\nas\homes\weng"
if (Test-Path $wengPath) {
    Write-Host "✅ 路径可访问" -ForegroundColor Green
    Write-Host ""
    
    try {
        $items = Get-ChildItem $wengPath -ErrorAction Stop
        Write-Host "目录内容（共 $($items.Count) 项）:" -ForegroundColor Cyan
        Write-Host ""
        
        foreach ($item in $items) {
            $type = if ($item.PSIsContainer) { "[DIR]" } else { "[FILE]" }
            $size = if (-not $item.PSIsContainer) {
                "{0:N2} KB" -f ($item.Length / 1KB)
            } else {
                ""
            }
            Write-Host "  $type $($item.Name) $size" -ForegroundColor Gray
        }
    } catch {
        Write-Host "❌ 无法列出内容: $($_.Exception.Message)" -ForegroundColor Red
        exit 1
}
} else {
    Write-Host "❌ 路径不可访问: $wengPath" -ForegroundColor Red
    exit 1
}
Write-Host ""

# Step 4: Try to access Japanese character path
Write-Host "[步骤 3] 尝试访问日文字符路径..." -ForegroundColor Yellow
$targetPath = "\\nas\homes\weng\履歴書"

Write-Host "`n测试路径: $targetPath" -ForegroundColor Gray
if (Test-Path $targetPath) {
    Write-Host "✅ 路径存在！" -ForegroundColor Green
    try {
        # 使用反引号转义或直接使用变量（已验证有效）
        $targetItems = Get-ChildItem $targetPath -ErrorAction Stop
        Write-Host "内容（共 $($targetItems.Count) 项）:" -ForegroundColor Cyan
        Write-Host ""
        
        foreach ($item in $targetItems) {
            $type = if ($item.PSIsContainer) { "[DIR]" } else { "[FILE]" }
            $size = if (-not $item.PSIsContainer) {
                "{0:N2} KB" -f ($item.Length / 1KB)
            } else {
                ""
            }
            Write-Host "  $type $($item.Name) $size" -ForegroundColor Gray
        }
    } catch {
        Write-Host "❌ 无法列出内容: $($_.Exception.Message)" -ForegroundColor Red
        Write-Host "   尝试使用 -LiteralPath 参数..." -ForegroundColor Yellow
        try {
            $targetItems = Get-ChildItem -LiteralPath $targetPath -ErrorAction Stop
            Write-Host "✅ 使用 -LiteralPath 成功！" -ForegroundColor Green
            foreach ($item in $targetItems) {
                $type = if ($item.PSIsContainer) { "[DIR]" } else { "[FILE]" }
                Write-Host "  $type $($item.Name)" -ForegroundColor Gray
            }
        } catch {
            Write-Host "❌ -LiteralPath 也失败: $($_.Exception.Message)" -ForegroundColor Red
        }
    }
} else {
    Write-Host "❌ 路径不存在" -ForegroundColor Yellow
    Write-Host "搜索类似的目录..." -ForegroundColor Yellow
}

# Step 5: Search for similar directory names
Write-Host "`n[步骤 4] 搜索包含'履歴'的目录..." -ForegroundColor Yellow
try {
    $matchingDirs = Get-ChildItem $wengPath -Directory | Where-Object { 
        $_.Name -match "履歴|リレキ|レキ" 
    }
    
    if ($matchingDirs) {
        Write-Host "✅ 找到匹配的目录:" -ForegroundColor Green
        foreach ($dir in $matchingDirs) {
            Write-Host "  $($dir.FullName)" -ForegroundColor Cyan
        }
    } else {
        Write-Host "⚠️  未找到包含'履歴'的目录" -ForegroundColor Yellow
    }
} catch {
    Write-Host "❌ 搜索失败: $($_.Exception.Message)" -ForegroundColor Red
}

Write-Host "`n=== 完成 ===" -ForegroundColor Cyan
