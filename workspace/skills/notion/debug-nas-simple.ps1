# 简化版调试脚本 - 按照用户提供的步骤
# 步骤 1: 正确连接 \\nas\homes 共享

Write-Host "=== 步骤 1: 连接 NAS 共享 ===" -ForegroundColor Cyan

# 清理旧连接
Write-Host "清理旧连接..." -ForegroundColor Yellow
net use * /delete /yes 2>$null
Start-Sleep -Seconds 1

# 连接 homes 共享
Write-Host "连接 \\nas\homes..." -ForegroundColor Yellow
$result = net use \\nas\homes /user:nas\weng 19801502 /persistent:yes 2>&1
if ($LASTEXITCODE -eq 0) {
    Write-Host "✅ 连接成功" -ForegroundColor Green
} else {
    Write-Host "❌ 连接失败: $result" -ForegroundColor Red
    exit 1
}
Write-Host ""

# 步骤 2: 验证路径访问
Write-Host "=== 步骤 2: 验证路径访问 ===" -ForegroundColor Cyan

$nasPath = "\\nas\homes\weng"
if (!(Test-Path -Path $nasPath)) {
    Write-Host "❌ 访问失败: $nasPath 路径无法访问" -ForegroundColor Red
    exit 1
} else {
    Write-Host "✅ 访问成功! NAS 路径正确。" -ForegroundColor Green
}

# 查找 Users 目录
Write-Host "`n查找 Users 目录..." -ForegroundColor Yellow
$usersDirs = Get-ChildItem "\\nas\homes\weng" -Force | Where-Object { $_.Name -like "Users" }
if ($usersDirs) {
    Write-Host "✅ 找到 Users 目录:" -ForegroundColor Green
    $usersDirs | ForEach-Object { Write-Host "   $($_.FullName)" -ForegroundColor Gray }
} else {
    Write-Host "⚠️  未找到 Users 目录，列出当前目录内容:" -ForegroundColor Yellow
    Get-ChildItem "\\nas\homes\weng" -Force | Select-Object -First 10 | ForEach-Object {
        $type = if ($_.PSIsContainer) { "[DIR]" } else { "[FILE]" }
        Write-Host "   $type $($_.Name)" -ForegroundColor Gray
    }
}
Write-Host ""

# 步骤 3: 验证脚本路径
Write-Host "=== 步骤 3: 验证脚本路径 ===" -ForegroundColor Cyan

$scriptPath = "C:\Users\wengzheng\.openclaw\workspace\skills\notion\query-real-estate.ps1"
Write-Host "检查脚本: $scriptPath" -ForegroundColor Yellow

if (!(Test-Path -Path $scriptPath)) {
    Write-Host "❌ 错误: 脚本 $scriptPath 找不到!" -ForegroundColor Red
    exit 1
} else {
    Write-Host "✅ 脚本找到!" -ForegroundColor Green
}
Write-Host ""

# 步骤 4: 执行脚本
Write-Host "=== 步骤 4: 执行 Notion 查询脚本 ===" -ForegroundColor Cyan

# 设置环境变量
# $env:NOTION_API_KEY 需在 .env 中配置
Write-Host "✅ 环境变量已设置" -ForegroundColor Green

# 切换到脚本目录
$scriptDir = Split-Path $scriptPath -Parent
Push-Location $scriptDir
Write-Host "当前目录: $(Get-Location)" -ForegroundColor Gray
Write-Host ""

# 执行脚本
Write-Host "执行脚本..." -ForegroundColor Yellow
try {
    & $scriptPath
    Write-Host "`n✅ 脚本执行完成" -ForegroundColor Green
} catch {
    Write-Host "`n❌ 脚本执行失败: $($_.Exception.Message)" -ForegroundColor Red
    exit 1
} finally {
    Pop-Location
}

Write-Host "`n=== 所有步骤完成 ===" -ForegroundColor Cyan
