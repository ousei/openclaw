# Simple NAS File List - 简化版 NAS 文件列表
# 使用变量避免 OpenClaw 识别错误

# Set UTF-8 encoding
[Console]::OutputEncoding = [System.Text.Encoding]::UTF8
$OutputEncoding = [System.Text.Encoding]::UTF8
chcp 65001 | Out-Null

# Define NAS paths using variables (avoid \\nas misidentification)
$Nas = "\\nas"
$NasHomes = "\\nas\homes"
$NasHomesWeng = "\\nas\homes\weng"

# Connect NAS
net use * /delete /yes 2>$null | Out-Null
net use $NasHomes /user:nas\weng 19801502 /persistent:yes 2>&1 | Out-Null
Start-Sleep -Seconds 2

# Target path using variable
$targetPath = "$NasHomesWeng\履歴書"

# Check and list files
if (Test-Path $targetPath) {
    $files = Get-ChildItem -Path $targetPath -Force -ErrorAction Stop | 
        Select-Object Name, FullName, @{Name='Size';Expression={if (-not $_.PSIsContainer) { "{0:N2} KB" -f ($_.Length / 1KB) } else { "-" }}}, LastWriteTime
    
    foreach ($file in $files) {
        $type = if (Test-Path $file.FullName -PathType Container) { "[DIR]" } else { "[FILE]" }
        [Console]::WriteLine("$type $($file.Name)")
        [Console]::WriteLine("  路径: $($file.FullName)")
        [Console]::WriteLine("  大小: $($file.Size)")
        [Console]::WriteLine("  修改: $($file.LastWriteTime)")
        [Console]::WriteLine("")
    }
} else {
    [Console]::WriteLine("路径不存在: $targetPath")
}
