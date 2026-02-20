# Get NAS Files - Get NAS file list
# Simple and reliable NAS access script
# Use variables to avoid OpenClaw misidentification

# Step 1: Define NAS path variables (MANDATORY - avoid misidentification)
$Nas = "\\nas"
$NasHomes = "\\nas\homes"
$NasHomesWeng = "\\nas\homes\weng"

# Step 2: Set UTF-8 encoding (required for Japanese paths)
[Console]::OutputEncoding = [System.Text.Encoding]::UTF8
$OutputEncoding = [System.Text.Encoding]::UTF8
chcp 65001 | Out-Null

# Step 3: Connect to NAS share (use variables)
net use * /delete /yes 2>$null | Out-Null
net use $NasHomes /user:nas\weng 19801502 /persistent:yes 2>&1 | Out-Null
Start-Sleep -Seconds 2

# Step 4: Search for target directory (avoid hardcoding Japanese characters)
Write-Host "=== Searching for target directory ===" -ForegroundColor Cyan

try {
    $allDirs = Get-ChildItem $NasHomesWeng -Directory -ErrorAction Stop
    # Search for directory containing resume/history characters
    $targetDir = $allDirs | Where-Object { $_.Name -match "履歴|リレキ|レキ" } | Select-Object -First 1
    
    if ($targetDir) {
        $targetPath = $targetDir.FullName
        Write-Host "Found directory: $($targetDir.Name)" -ForegroundColor Green
        Write-Host "Full path: $targetPath" -ForegroundColor Gray
        Write-Host ""
    } else {
        Write-Host "Directory not found. Available directories:" -ForegroundColor Yellow
        $allDirs | Select-Object -First 20 | ForEach-Object {
            [Console]::WriteLine("  [DIR] $($_.Name)")
        }
        exit 1
    }
} catch {
    Write-Host "Error listing directories: $($_.Exception.Message)" -ForegroundColor Red
    exit 1
}

# Step 5: List files in target directory
if (Test-Path $targetPath) {
    $items = Get-ChildItem $targetPath -Force -ErrorAction Stop | 
        Select-Object Name, FullName, @{
            Name='Type'
            Expression={if ($_.PSIsContainer) { "DIR" } else { "FILE" }}
        }, @{
            Name='Size'
            Expression={if (-not $_.PSIsContainer) { "{0:N2} KB" -f ($_.Length / 1KB) } else { "-" }}
        }, LastWriteTime
    
    Write-Host "=== File List ===" -ForegroundColor Cyan
    Write-Host ""
    
    foreach ($item in $items) {
        [Console]::WriteLine("[$($item.Type)] $($item.Name)")
        [Console]::WriteLine("  Path: $($item.FullName)")
        [Console]::WriteLine("  Size: $($item.Size)")
        [Console]::WriteLine("  Modified: $($item.LastWriteTime)")
        [Console]::WriteLine("")
    }
} else {
    [Console]::WriteLine("Path does not exist: $targetPath")
}
