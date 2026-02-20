# Fix NAS Homes Folder Access Issue
# 修复 NAS homes 文件夹访问问题

Write-Host "=== 诊断 NAS homes 文件夹访问问题 ===" -ForegroundColor Cyan
Write-Host ""

# Step 1: 查看当前所有网络连接
Write-Host "[1/4] 检查当前网络连接..." -ForegroundColor Yellow
$connections = net use
Write-Host $connections
Write-Host ""

# Step 2: 断开所有到 nas 的连接
Write-Host "[2/4] 断开所有到 nas 服务器的连接..." -ForegroundColor Yellow
$nasConnections = net use | Select-String "\\\\nas"
if ($nasConnections) {
    Write-Host "找到以下 nas 连接:" -ForegroundColor Gray
    $nasConnections | ForEach-Object {
        Write-Host "  $_" -ForegroundColor Gray
    }
    
    # 断开所有 nas 连接
    net use \\nas\* /delete /yes 2>$null
    Write-Host "✅ 已断开所有 nas 连接" -ForegroundColor Green
} else {
    Write-Host "未找到 nas 连接" -ForegroundColor Gray
}
Write-Host ""

# Step 3: 测试 homes 路径访问
Write-Host "[3/4] 测试 homes 路径访问..." -ForegroundColor Yellow
$homesPath = "\\nas\homes"
if (Test-Path $homesPath) {
    Write-Host "✅ $homesPath 可访问" -ForegroundColor Green
    try {
        $items = Get-ChildItem $homesPath -ErrorAction Stop | Select-Object -First 5
        Write-Host "`n📁 homes 文件夹内容（前5项）:" -ForegroundColor Cyan
        foreach ($item in $items) {
            $type = if ($item.PSIsContainer) { "📁" } else { "📄" }
            Write-Host "  $type $($item.Name)" -ForegroundColor Gray
        }
    } catch {
        Write-Host "❌ 无法列出内容: $($_.Exception.Message)" -ForegroundColor Red
    }
} else {
    Write-Host "❌ $homesPath 不可访问" -ForegroundColor Red
    Write-Host "`n可能的原因:" -ForegroundColor Yellow
    Write-Host "  1. 权限不足 - 请联系 NAS 管理员" -ForegroundColor Gray
    Write-Host "  2. 需要重新认证 - 尝试在资源管理器中手动访问" -ForegroundColor Gray
}
Write-Host ""

# Step 4: 提供解决方案
Write-Host "[4/4] 建议的解决方案:" -ForegroundColor Yellow
Write-Host ""
Write-Host "如果仍然无法访问，请尝试以下方法:" -ForegroundColor Cyan
Write-Host ""
Write-Host "方法 1: 手动重新连接（推荐）" -ForegroundColor Green
Write-Host "  1. 打开 Windows 资源管理器" -ForegroundColor Gray
Write-Host "  2. 在地址栏输入: \\nas\homes" -ForegroundColor Gray
Write-Host "  3. 输入正确的用户名和密码" -ForegroundColor Gray
Write-Host "  4. 勾选「记住我的凭据」" -ForegroundColor Gray
Write-Host ""
Write-Host "方法 2: 使用 net use 命令连接" -ForegroundColor Green
Write-Host "  net use \\nas\homes /user:你的用户名 你的密码" -ForegroundColor Gray
Write-Host ""
Write-Host "方法 3: 检查 NAS 权限设置" -ForegroundColor Green
Write-Host "  - 登录 NAS 管理界面" -ForegroundColor Gray
Write-Host "  - 检查 homes 共享文件夹的权限设置" -ForegroundColor Gray
Write-Host "  - 确保你的用户账户有访问权限" -ForegroundColor Gray
Write-Host ""
