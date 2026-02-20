# Test NAS Direct Access - 直接测试 NAS 访问
# 使用最简单可靠的方法

Write-Host "=== 测试 NAS 直接访问 ===" -ForegroundColor Cyan
Write-Host ""

# 步骤 1: 清理旧连接
Write-Host "[步骤 1] 清理旧的网络连接..." -ForegroundColor Yellow
try {
    net use * /delete /yes 2>$null | Out-Null
    Write-Host "✅ 已清理旧连接" -ForegroundColor Green
} catch {
    Write-Host "⚠️  清理连接时出现警告（可能没有旧连接）" -ForegroundColor Yellow
}
Write-Host ""

# 步骤 2: 连接 NAS homes 共享（不是 homes\weng）
Write-Host "[步骤 2] 连接 \\nas\homes 共享..." -ForegroundColor Yellow
$connectResult = net use \\nas\homes /user:nas\weng 19801502 /persistent:yes 2>&1
if ($LASTEXITCODE -eq 0) {
    Write-Host "✅ 连接成功: \\nas\homes" -ForegroundColor Green
} else {
    Write-Host "❌ 连接失败: $connectResult" -ForegroundColor Red
    Write-Host "`n尝试使用资源管理器手动连接:" -ForegroundColor Yellow
    Write-Host "   1. 打开资源管理器 (Windows + E)" -ForegroundColor Gray
    Write-Host "   2. 地址栏输入: \\nas\homes" -ForegroundColor Gray
    Write-Host "   3. 用户名: nas\weng" -ForegroundColor Gray
    Write-Host "   4. 密码: 19801502" -ForegroundColor Gray
    exit 1
}
Write-Host ""

# 等待一下让连接稳定
Start-Sleep -Seconds 2

# 步骤 3: 测试 homes 根目录
Write-Host "[步骤 3] 测试 \\nas\homes 根目录..." -ForegroundColor Yellow
if (Test-Path "\\nas\homes") {
    Write-Host "✅ \\nas\homes 可访问" -ForegroundColor Green
    
    try {
        Write-Host "`n列出 homes 根目录内容:" -ForegroundColor Cyan
        $rootItems = Get-ChildItem "\\nas\homes" -ErrorAction Stop | Select-Object -First 10
        foreach ($item in $rootItems) {
            $type = if ($item.PSIsContainer) { "[DIR]" } else { "[FILE]" }
            Write-Host "  $type $($item.Name)" -ForegroundColor Gray
        }
    } catch {
        Write-Host "❌ 无法列出内容: $($_.Exception.Message)" -ForegroundColor Red
    }
} else {
    Write-Host "❌ \\nas\homes 不可访问" -ForegroundColor Red
    exit 1
}
Write-Host ""

# 步骤 4: 测试 homes\weng 目录
Write-Host "[步骤 4] 测试 \\nas\homes\weng 目录..." -ForegroundColor Yellow
$wengPath = "\\nas\homes\weng"
if (Test-Path $wengPath) {
    Write-Host "✅ $wengPath 可访问" -ForegroundColor Green
    
    try {
        Write-Host "`n列出 weng 目录内容（前20项）:" -ForegroundColor Cyan
        $wengItems = Get-ChildItem $wengPath -ErrorAction Stop | Select-Object -First 20
        $dirCount = 0
        $fileCount = 0
        
        foreach ($item in $wengItems) {
            $type = if ($item.PSIsContainer) { 
                "[DIR]"
                $dirCount++
            } else { 
                "[FILE]"
                $fileCount++
            }
            $size = if (-not $item.PSIsContainer) {
                "{0:N2} KB" -f ($item.Length / 1KB)
            } else {
                ""
            }
            Write-Host "  $type $($item.Name) $size" -ForegroundColor Gray
        }
        
        Write-Host "`n统计:" -ForegroundColor Cyan
        Write-Host "  目录: $dirCount 个" -ForegroundColor Gray
        Write-Host "  文件: $fileCount 个" -ForegroundColor Gray
        
    } catch {
        Write-Host "❌ 无法列出内容: $($_.Exception.Message)" -ForegroundColor Red
        Write-Host "   错误详情: $($_.Exception.GetType().FullName)" -ForegroundColor DarkYellow
    }
} else {
    Write-Host "❌ $wengPath 不可访问" -ForegroundColor Red
    Write-Host "`n可能的原因:" -ForegroundColor Yellow
    Write-Host "  1. 路径不存在（weng 目录可能不在 homes 下）" -ForegroundColor Gray
    Write-Host "  2. 权限不足" -ForegroundColor Gray
    Write-Host "  3. 需要检查 homes 目录下的实际结构" -ForegroundColor Gray
    
    # 列出 homes 下的所有目录
    Write-Host "`n检查 homes 目录下的所有子目录:" -ForegroundColor Yellow
    try {
        $allDirs = Get-ChildItem "\\nas\homes" -Directory -ErrorAction Stop
        Write-Host "找到以下目录:" -ForegroundColor Cyan
        foreach ($dir in $allDirs) {
            Write-Host "  - $($dir.Name)" -ForegroundColor Gray
        }
    } catch {
        Write-Host "  无法列出目录: $($_.Exception.Message)" -ForegroundColor Red
    }
}
Write-Host ""

# 步骤 5: 检查网络连接状态
Write-Host "[步骤 5] 检查网络连接状态..." -ForegroundColor Yellow
$connections = net use 2>$null | Select-String "\\\\nas"
if ($connections) {
    Write-Host "✅ 找到 NAS 连接:" -ForegroundColor Green
    $connections | ForEach-Object { Write-Host "  $_" -ForegroundColor Gray }
} else {
    Write-Host "⚠️  未找到已保存的 NAS 连接" -ForegroundColor Yellow
}
Write-Host ""

Write-Host "=== 测试完成 ===" -ForegroundColor Cyan
Write-Host ""
Write-Host "推荐方法:" -ForegroundColor Yellow
Write-Host "  1. 使用 Test-Path 测试路径（最可靠）" -ForegroundColor Gray
Write-Host "  2. 使用 Get-ChildItem 列出内容" -ForegroundColor Gray
Write-Host "  3. 避免使用 Invoke-Command（需要 WinRM）" -ForegroundColor Gray
Write-Host "  4. 避免使用 Test-NetConnection（可能不准确）" -ForegroundColor Gray
