# Test NAS Connection - Safe Version
# 安全地测试 NAS 连接，兼容不同 PowerShell 版本

Write-Host "=== 测试 NAS 连接 ===" -ForegroundColor Cyan
Write-Host ""

$nasHost = "nas"
$smbPort = 445

# 方法 1: 使用 Test-NetConnection（兼容不同版本）
Write-Host "[方法 1] 使用 Test-NetConnection 测试端口 $smbPort..." -ForegroundColor Yellow
try {
    # PowerShell 5.1+ 的正确用法
    $testResult = Test-NetConnection -ComputerName $nasHost -Port $smbPort -InformationLevel Quiet -WarningAction SilentlyContinue -ErrorAction Stop
    
    # 检查结果（不同版本返回格式可能不同）
    if ($testResult -is [bool]) {
        # PowerShell 5.1 返回布尔值
        if ($testResult) {
            Write-Host "✅ 端口 $smbPort 可访问" -ForegroundColor Green
        } else {
            Write-Host "❌ 端口 $smbPort 不可访问" -ForegroundColor Red
        }
    } elseif ($testResult.PSObject.Properties.Name -contains 'TcpTestSucceeded') {
        # PowerShell 5.1+ 返回对象，有 TcpTestSucceeded 属性
        if ($testResult.TcpTestSucceeded) {
            Write-Host "✅ 端口 $smbPort 可访问" -ForegroundColor Green
        } else {
            Write-Host "❌ 端口 $smbPort 不可访问" -ForegroundColor Red
        }
    } else {
        # 其他格式，尝试直接访问属性
        Write-Host "⚠️  无法确定连接状态，尝试其他方法..." -ForegroundColor Yellow
    }
} catch {
    Write-Host "❌ Test-NetConnection 失败: $($_.Exception.Message)" -ForegroundColor Red
    Write-Host "   尝试使用替代方法..." -ForegroundColor Yellow
}

Write-Host ""

# 方法 2: 使用 Test-Path（最可靠）
Write-Host "[方法 2] 使用 Test-Path 测试 NAS 路径..." -ForegroundColor Yellow
$testPaths = @(
    "\\nas\homes\weng",
    "\\nas\homes",
    "\\nas\home"
)

foreach ($path in $testPaths) {
    Write-Host "  测试: $path ... " -NoNewline -ForegroundColor Gray
    if (Test-Path $path -ErrorAction SilentlyContinue) {
        Write-Host "✅ 可访问" -ForegroundColor Green
    } else {
        Write-Host "❌ 不可访问" -ForegroundColor Red
    }
}
Write-Host ""

# 方法 3: 使用 net use 检查连接
Write-Host "[方法 3] 检查已保存的网络连接..." -ForegroundColor Yellow
try {
    $connections = net use 2>$null | Select-String "\\\\nas"
    if ($connections) {
        Write-Host "✅ 找到 NAS 连接:" -ForegroundColor Green
        $connections | ForEach-Object { Write-Host "   $_" -ForegroundColor Gray }
    } else {
        Write-Host "⚠️  未找到已保存的 NAS 连接" -ForegroundColor Yellow
    }
} catch {
    Write-Host "❌ 无法检查网络连接: $($_.Exception.Message)" -ForegroundColor Red
}
Write-Host ""

# 方法 4: 使用 Test-Connection（ICMP ping）
Write-Host "[方法 4] 使用 Test-Connection (Ping) 测试主机..." -ForegroundColor Yellow
try {
    $pingResult = Test-Connection -ComputerName $nasHost -Count 1 -Quiet -ErrorAction Stop
    if ($pingResult) {
        Write-Host "✅ NAS 主机可达（ICMP）" -ForegroundColor Green
    } else {
        Write-Host "❌ NAS 主机不可达（ICMP）" -ForegroundColor Red
        Write-Host "   注意：某些防火墙可能阻止 ICMP，这不意味着 SMB 不可用" -ForegroundColor Yellow
    }
} catch {
    Write-Host "⚠️  Ping 测试失败: $($_.Exception.Message)" -ForegroundColor Yellow
    Write-Host "   这可能是正常的（防火墙阻止 ICMP）" -ForegroundColor Gray
}
Write-Host ""

Write-Host "=== 测试完成 ===" -ForegroundColor Cyan
Write-Host ""
Write-Host "推荐方法：" -ForegroundColor Yellow
Write-Host "  - 使用 Test-Path 测试 UNC 路径（最可靠）" -ForegroundColor Gray
Write-Host "  - 使用 net use 检查已保存的连接" -ForegroundColor Gray
Write-Host "  - Test-NetConnection 在不同 PowerShell 版本中行为可能不同" -ForegroundColor Gray
