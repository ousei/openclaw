# NAS Access Template - 标准 NAS 访问模板
# 复制此模板用于所有 NAS 访问操作

# ============================================
# 步骤 1: 定义 NAS 路径变量（必须！避免识别错误）
# ============================================
$Nas = "\\nas"
$NasHomes = "\\nas\homes"
$NasHomesWeng = "\\nas\homes\weng"

# ============================================
# 步骤 2: 设置 UTF-8 编码（访问日文路径时必需）
# ============================================
[Console]::OutputEncoding = [System.Text.Encoding]::UTF8
$OutputEncoding = [System.Text.Encoding]::UTF8
[Console]::InputEncoding = [System.Text.Encoding]::UTF8
chcp 65001 | Out-Null

# ============================================
# 步骤 3: 连接 NAS 共享（使用变量）
# ============================================
Write-Host "=== 连接 NAS ===" -ForegroundColor Cyan
net use * /delete /yes 2>$null | Out-Null
$result = net use $NasHomes /user:nas\weng 19801502 /persistent:yes 2>&1
if ($LASTEXITCODE -eq 0) {
    Write-Host "✅ NAS 连接成功" -ForegroundColor Green
} else {
    Write-Host "❌ NAS 连接失败: $result" -ForegroundColor Red
    exit 1
}
Start-Sleep -Seconds 2

# ============================================
# 步骤 4: 访问 NAS 路径（使用变量）
# ============================================
# 示例：访问履歴書目录
$targetPath = "$NasHomesWeng\履歴書"

Write-Host "`n=== 访问路径 ===" -ForegroundColor Cyan
Write-Host "路径: $targetPath" -ForegroundColor Gray

if (Test-Path $targetPath) {
    Write-Host "✅ 路径存在" -ForegroundColor Green
    Write-Host ""
    
    # 列出文件
    $items = Get-ChildItem $targetPath -Force -ErrorAction Stop
    Write-Host "找到 $($items.Count) 项:" -ForegroundColor Cyan
    Write-Host ""
    
    foreach ($item in $items) {
        $type = if ($item.PSIsContainer) { "[DIR]" } else { "[FILE]" }
        $size = if (-not $item.PSIsContainer) {
            "{0:N2} KB" -f ($item.Length / 1KB)
        } else {
            "-"
        }
        [Console]::WriteLine("$type $($item.Name) ($size)")
        [Console]::WriteLine("  路径: $($item.FullName)")
        [Console]::WriteLine("  修改: $($item.LastWriteTime)")
        [Console]::WriteLine("")
    }
} else {
    Write-Host "❌ 路径不存在: $targetPath" -ForegroundColor Red
    Write-Host "`n列出父目录内容..." -ForegroundColor Yellow
    Get-ChildItem $NasHomesWeng | Select-Object -First 10 | ForEach-Object {
        $type = if ($_.PSIsContainer) { "[DIR]" } else { "[FILE]" }
        [Console]::WriteLine("$type $($_.Name)")
    }
    exit 1
}

Write-Host "=== 完成 ===" -ForegroundColor Cyan
