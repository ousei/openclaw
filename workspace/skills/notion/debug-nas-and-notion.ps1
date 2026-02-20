# Debug NAS Connection and Notion Script
# 调试 NAS 连接和 Notion 脚本执行

Write-Host "=== 步骤 1: 正确连接 \\nas\homes 共享 ===" -ForegroundColor Cyan
Write-Host ""

# 先清理旧连接
Write-Host "[1.1] 清理旧连接..." -ForegroundColor Yellow
try {
    net use * /delete /yes 2>$null
    Write-Host "✅ 已清理旧连接" -ForegroundColor Green
} catch {
    Write-Host "⚠️  清理连接时出现警告（可能没有旧连接）" -ForegroundColor Yellow
}
Write-Host ""

# 连接 NAS homes 共享
Write-Host "[1.2] 连接 \\nas\homes 共享..." -ForegroundColor Yellow
$connectResult = net use \\nas\homes /user:nas\weng 19801502 /persistent:yes 2>&1
if ($LASTEXITCODE -eq 0) {
    Write-Host "✅ 连接成功" -ForegroundColor Green
    Write-Host "   $connectResult" -ForegroundColor Gray
} else {
    Write-Host "❌ 连接失败" -ForegroundColor Red
    Write-Host "   错误信息: $connectResult" -ForegroundColor Yellow
    Write-Host "`n   提示: 如果连接失败，请尝试在资源管理器中手动连接一次" -ForegroundColor Yellow
    Write-Host "   地址栏输入: \\nas\homes" -ForegroundColor Gray
    Write-Host "   用户名: nas\weng" -ForegroundColor Gray
    Write-Host "   密码: 19801502" -ForegroundColor Gray
}
Write-Host ""

Write-Host "=== 步骤 2: 验证 NAS 路径访问 ===" -ForegroundColor Cyan
Write-Host ""

# 检查连接是否成功
$nasPath = "\\nas\homes\weng"
Write-Host "[2.1] 检查路径: $nasPath" -ForegroundColor Yellow
if (Test-Path -Path $nasPath) {
    Write-Host "✅ 路径可访问!" -ForegroundColor Green
} else {
    Write-Host "❌ 路径无法访问: $nasPath" -ForegroundColor Red
    Write-Host "`n   可能的原因:" -ForegroundColor Yellow
    Write-Host "   1. 网络连接问题" -ForegroundColor Gray
    Write-Host "   2. NAS 服务器未启动" -ForegroundColor Gray
    Write-Host "   3. 权限不足" -ForegroundColor Gray
    Write-Host "   4. 路径不存在（homes\weng 目录可能不存在）" -ForegroundColor Gray
    Write-Host "`n   尝试检查 homes 共享根目录..." -ForegroundColor Yellow
    
    # 尝试访问 homes 根目录
    if (Test-Path -Path "\\nas\homes") {
        Write-Host "   ✅ \\nas\homes 可访问，列出内容:" -ForegroundColor Green
        try {
            Get-ChildItem "\\nas\homes" -ErrorAction Stop | Select-Object -First 10 | ForEach-Object {
                $type = if ($_.PSIsContainer) { "[DIR]" } else { "[FILE]" }
                Write-Host "     $type $($_.Name)" -ForegroundColor Gray
            }
        } catch {
            Write-Host "     ❌ 无法列出内容: $($_.Exception.Message)" -ForegroundColor Red
        }
    } else {
        Write-Host "   ❌ \\nas\homes 也无法访问" -ForegroundColor Red
    }
    exit 1
}
Write-Host ""

# 列出目录内容
Write-Host "[2.2] 列出目录内容（查找 Users 目录）..." -ForegroundColor Yellow
try {
    $items = Get-ChildItem "\\nas\homes\weng" -Force -ErrorAction Stop
    $usersDir = $items | Where-Object { $_.Name -like "Users" }
    
    if ($usersDir) {
        Write-Host "✅ 找到 Users 目录:" -ForegroundColor Green
        Write-Host "   $($usersDir.FullName)" -ForegroundColor Gray
    } else {
        Write-Host "⚠️  未找到 Users 目录，当前目录内容:" -ForegroundColor Yellow
        $items | Select-Object -First 10 | ForEach-Object {
            $type = if ($_.PSIsContainer) { "[DIR]" } else { "[FILE]" }
            Write-Host "   $type $($_.Name)" -ForegroundColor Gray
        }
    }
} catch {
    Write-Host "❌ 无法列出目录内容: $($_.Exception.Message)" -ForegroundColor Red
}
Write-Host ""

Write-Host "=== 步骤 3: 验证 Notion 脚本路径 ===" -ForegroundColor Cyan
Write-Host ""

# 脚本路径
$scriptPath = "C:\Users\wengzheng\.openclaw\workspace\skills\notion\query-real-estate.ps1"
Write-Host "[3.1] 检查脚本路径: $scriptPath" -ForegroundColor Yellow

if (Test-Path -Path $scriptPath) {
    Write-Host "✅ 脚本找到!" -ForegroundColor Green
    Write-Host "   路径: $scriptPath" -ForegroundColor Gray
    
    # 显示脚本信息
    $scriptInfo = Get-Item $scriptPath
    Write-Host "   大小: $($scriptInfo.Length) 字节" -ForegroundColor Gray
    Write-Host "   修改时间: $($scriptInfo.LastWriteTime)" -ForegroundColor Gray
} else {
    Write-Host "❌ 脚本未找到: $scriptPath" -ForegroundColor Red
    Write-Host "`n   检查可能的路径..." -ForegroundColor Yellow
    
    # 检查脚本目录是否存在
    $scriptDir = Split-Path $scriptPath -Parent
    if (Test-Path $scriptDir) {
        Write-Host "   ✅ 脚本目录存在: $scriptDir" -ForegroundColor Green
        Write-Host "   目录中的脚本文件:" -ForegroundColor Yellow
        Get-ChildItem $scriptDir -Filter "*.ps1" | ForEach-Object {
            Write-Host "     - $($_.Name)" -ForegroundColor Gray
        }
    } else {
        Write-Host "   ❌ 脚本目录不存在: $scriptDir" -ForegroundColor Red
    }
    exit 1
}
Write-Host ""

Write-Host "=== 步骤 4: 设置环境变量并执行脚本 ===" -ForegroundColor Cyan
Write-Host ""

# 检查环境变量（应在 .env 中配置）
Write-Host "[4.1] 检查 NOTION_API_KEY 环境变量..." -ForegroundColor Yellow
if ($env:NOTION_API_KEY) {
    Write-Host "✅ 环境变量已设置" -ForegroundColor Green
    Write-Host "   值: $($env:NOTION_API_KEY.Substring(0, 20))..." -ForegroundColor Gray
} else {
    Write-Host "❌ 环境变量设置失败" -ForegroundColor Red
    exit 1
}
Write-Host ""

# 切换到脚本目录
Write-Host "[4.2] 切换到脚本目录..." -ForegroundColor Yellow
$scriptDir = Split-Path $scriptPath -Parent
Push-Location $scriptDir
Write-Host "   当前目录: $(Get-Location)" -ForegroundColor Gray
Write-Host ""

# 执行脚本
Write-Host "[4.3] 执行 Notion 查询脚本..." -ForegroundColor Yellow
Write-Host "   脚本: query-real-estate.ps1" -ForegroundColor Gray
Write-Host ""

try {
    & $scriptPath
    if ($LASTEXITCODE -eq 0 -or $LASTEXITCODE -eq $null) {
        Write-Host "`n✅ 脚本执行成功!" -ForegroundColor Green
    } else {
        Write-Host "`n⚠️  脚本执行完成，退出代码: $LASTEXITCODE" -ForegroundColor Yellow
    }
} catch {
    Write-Host "`n❌ 脚本执行失败:" -ForegroundColor Red
    Write-Host "   错误: $($_.Exception.Message)" -ForegroundColor Yellow
    Write-Host "   详细信息:" -ForegroundColor Yellow
    Write-Host $_.Exception | Format-List -Force | Out-String
    exit 1
} finally {
    Pop-Location
}

Write-Host "`n=== 调试完成 ===" -ForegroundColor Cyan
