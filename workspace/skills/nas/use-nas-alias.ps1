# Use NAS Alias - 使用 Nas 代替 \\nas
# 这个脚本演示如何使用 Nas 作为 \\nas 的别名

# 设置 UTF-8 编码
[Console]::OutputEncoding = [System.Text.Encoding]::UTF8
$OutputEncoding = [System.Text.Encoding]::UTF8
chcp 65001 | Out-Null

# 定义 NAS 路径变量（使用 Nas 作为前缀，避免 \\nas 识别错误）
$Nas = "\\nas"
$NasHomes = "\\nas\homes"
$NasHomesWeng = "\\nas\homes\weng"

Write-Host "=== 使用 Nas 别名访问 NAS ===" -ForegroundColor Cyan
Write-Host ""

# 连接 NAS
Write-Host "[1] 连接 NAS..." -ForegroundColor Yellow
net use $NasHomes /user:nas\weng 19801502 /persistent:yes 2>&1 | Out-Null
if ($LASTEXITCODE -eq 0) {
    Write-Host "✅ 连接成功" -ForegroundColor Green
} else {
    Write-Host "❌ 连接失败" -ForegroundColor Red
    exit 1
}
Write-Host ""

# 使用 Nas 变量访问路径
Write-Host "[2] 访问路径（使用 Nas 变量）..." -ForegroundColor Yellow

# 示例：访问履歴書目录
$targetPath = "$NasHomesWeng\履歴書"
Write-Host "路径: $targetPath" -ForegroundColor Gray

if (Test-Path $targetPath) {
    Write-Host "✅ 路径存在" -ForegroundColor Green
    Write-Host ""
    Write-Host "目录内容:" -ForegroundColor Cyan
    Get-ChildItem $targetPath | Select-Object Name, Length, LastWriteTime | Format-Table -AutoSize
} else {
    Write-Host "❌ 路径不存在" -ForegroundColor Red
}

Write-Host ""
Write-Host "=== 完成 ===" -ForegroundColor Cyan
