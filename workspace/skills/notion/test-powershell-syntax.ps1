# Test PowerShell Syntax - 验证正确的 PowerShell 语法
# 此脚本演示正确的 PowerShell 命令连接方式

Write-Host "=== PowerShell 语法测试 ===" -ForegroundColor Cyan
Write-Host ""

# 测试 1: 使用分号连接命令（正确）
Write-Host "[测试 1] 使用分号连接命令..." -ForegroundColor Yellow
$env:TEST_VAR = "test"; Write-Host "环境变量已设置: $env:TEST_VAR" -ForegroundColor Green
Write-Host ""

# 测试 2: 使用换行分隔命令（正确）
Write-Host "[测试 2] 使用换行分隔命令..." -ForegroundColor Yellow
$scriptPath = "C:\Users\wengzheng\.openclaw\workspace\skills\notion"
if (Test-Path $scriptPath) {
    Write-Host "路径存在: $scriptPath" -ForegroundColor Green
}
Write-Host ""

# 测试 3: 使用条件判断（正确）
Write-Host "[测试 3] 使用条件判断..." -ForegroundColor Yellow
$testFile = "C:\Users\wengzheng\.openclaw\workspace\skills\notion\query-real-estate.ps1"
if (Test-Path $testFile) {
    Write-Host "✅ 文件存在: $testFile" -ForegroundColor Green
    $fileInfo = Get-Item $testFile
    Write-Host "   大小: $($fileInfo.Length) 字节" -ForegroundColor Gray
} else {
    Write-Host "❌ 文件不存在: $testFile" -ForegroundColor Red
}
Write-Host ""

# 测试 4: 多个命令连续执行（正确）
Write-Host "[测试 4] 多个命令连续执行..." -ForegroundColor Yellow
$env:NOTION_API_KEY = "test"; cd $scriptPath; Write-Host "当前目录: $(Get-Location)" -ForegroundColor Green
Write-Host ""

# 测试 5: 检查命令成功后再执行（正确）
Write-Host "[测试 5] 检查命令成功后再执行..." -ForegroundColor Yellow
$testScript = Join-Path $scriptPath "query-real-estate.ps1"
if (Test-Path $testScript) {
    Write-Host "✅ 脚本存在，可以执行" -ForegroundColor Green
    Write-Host "   脚本路径: $testScript" -ForegroundColor Gray
} else {
    Write-Host "❌ 脚本不存在" -ForegroundColor Red
}
Write-Host ""

Write-Host "=== 所有测试完成 ===" -ForegroundColor Cyan
Write-Host ""
Write-Host "✅ 正确的 PowerShell 语法示例:" -ForegroundColor Green
Write-Host "   - 使用分号 ; 连接命令" -ForegroundColor Gray
Write-Host "   - 使用换行分隔命令" -ForegroundColor Gray
Write-Host "   - 使用 if 条件判断" -ForegroundColor Gray
Write-Host ""
Write-Host "❌ 错误的语法（不要使用）:" -ForegroundColor Red
Write-Host "   - 使用 && 连接命令（PowerShell 不支持）" -ForegroundColor Gray
Write-Host ""
