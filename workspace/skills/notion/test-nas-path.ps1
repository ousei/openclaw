# Test NAS Path Access
# 测试正确的 NAS 路径访问方式

Write-Host "=== 测试 NAS 路径访问 ===" -ForegroundColor Cyan
Write-Host ""

# 正确的 UNC 路径格式
$nasPath = "\\nas\homes\weng"

Write-Host "测试路径: $nasPath" -ForegroundColor Yellow
Write-Host ""

# 测试 1: 检查路径是否存在
Write-Host "[1/3] 检查路径是否存在..." -ForegroundColor Yellow
if (Test-Path $nasPath) {
    Write-Host "✅ 路径可访问" -ForegroundColor Green
    
    # 测试 2: 列出内容
    Write-Host "`n[2/3] 列出目录内容（前5项）..." -ForegroundColor Yellow
    try {
        $items = Get-ChildItem $nasPath -ErrorAction Stop | Select-Object -First 5
        foreach ($item in $items) {
            $type = if ($item.PSIsContainer) { "[DIR]" } else { "[FILE]" }
            Write-Host "  $type $($item.Name)" -ForegroundColor Gray
        }
        Write-Host "✅ 可以列出内容" -ForegroundColor Green
    } catch {
        Write-Host "❌ 错误: $($_.Exception.Message)" -ForegroundColor Red
    }
    
    # 测试 3: 检查网络连接
    Write-Host "`n[3/3] 检查网络连接..." -ForegroundColor Yellow
    $connections = net use 2>$null | Select-String "\\\\nas"
    if ($connections) {
        Write-Host "✅ 找到 NAS 连接:" -ForegroundColor Green
        $connections | ForEach-Object { Write-Host "  $_" -ForegroundColor Gray }
    } else {
        Write-Host "⚠️  未找到已保存的 NAS 连接" -ForegroundColor Yellow
        Write-Host "   如果需要，可以运行:" -ForegroundColor Gray
        Write-Host "   net use \\nas\homes /user:nas\weng 19801502 /persistent:yes" -ForegroundColor DarkGray
    }
    
} else {
    Write-Host "❌ 路径不可访问" -ForegroundColor Red
    Write-Host "`n可能的解决方案:" -ForegroundColor Yellow
    Write-Host "1. 检查网络连接" -ForegroundColor Gray
    Write-Host "2. 使用资源管理器手动连接一次:" -ForegroundColor Gray
    Write-Host "   地址栏输入: $nasPath" -ForegroundColor DarkGray
    Write-Host "3. 或使用命令连接:" -ForegroundColor Gray
    Write-Host "   net use \\nas\homes /user:nas\weng 19801502 /persistent:yes" -ForegroundColor DarkGray
}

Write-Host "`n=== 测试完成 ===" -ForegroundColor Cyan
