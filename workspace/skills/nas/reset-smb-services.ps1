# Reset SMB Services to fix connection conflict
# 重置 SMB 服务以修复连接冲突

Write-Host "=== Reset SMB Services ===" -ForegroundColor Cyan
Write-Host ""

# Check if running as admin
$isAdmin = ([Security.Principal.WindowsPrincipal] [Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)

if (-not $isAdmin) {
    Write-Host "WARNING: This script requires administrator privileges" -ForegroundColor Yellow
    Write-Host "Some operations may fail without admin rights" -ForegroundColor Yellow
    Write-Host ""
}

# Restart Workstation service
Write-Host "[1/3] Restarting Workstation service..." -ForegroundColor Yellow
try {
    if ($isAdmin) {
        Restart-Service -Name LanmanWorkstation -Force -ErrorAction Stop
        Write-Host "OK: Workstation service restarted" -ForegroundColor Green
    } else {
        Write-Host "SKIP: Need admin rights to restart service" -ForegroundColor Yellow
        Write-Host "You can manually restart it:" -ForegroundColor Gray
        Write-Host "  Run PowerShell as Administrator, then:" -ForegroundColor Gray
        Write-Host "  Restart-Service -Name LanmanWorkstation -Force" -ForegroundColor DarkGray
    }
} catch {
    Write-Host "ERROR: $($_.Exception.Message)" -ForegroundColor Red
}
Write-Host ""

# Wait a moment
Start-Sleep -Seconds 2

# Try alternative: Use File Explorer method
Write-Host "[2/3] Alternative solution - Use File Explorer:" -ForegroundColor Yellow
Write-Host ""
Write-Host "Instead of using 'net use', try this:" -ForegroundColor Cyan
Write-Host ""
Write-Host "1. Open File Explorer (Windows + E)" -ForegroundColor Gray
Write-Host "2. In the address bar, type: \\nas\homes" -ForegroundColor Gray
Write-Host "3. Press Enter" -ForegroundColor Gray
Write-Host "4. When prompted, enter:" -ForegroundColor Gray
Write-Host "   Username: weng" -ForegroundColor DarkGray
Write-Host "   Password: 19801502" -ForegroundColor DarkGray
Write-Host "5. Check 'Remember my credentials'" -ForegroundColor Gray
Write-Host "6. Click OK" -ForegroundColor Gray
Write-Host ""

# Try different username formats
Write-Host "[3/3] Try different connection methods:" -ForegroundColor Yellow
Write-Host ""
Write-Host "Method A: Simple username" -ForegroundColor Green
Write-Host "  net use \\nas\homes /user:weng 19801502 /persistent:yes" -ForegroundColor Gray
Write-Host ""
Write-Host "Method B: Domain username" -ForegroundColor Green
Write-Host "  net use \\nas\homes /user:nas\weng 19801502 /persistent:yes" -ForegroundColor Gray
Write-Host ""
Write-Host "Method C: Full domain username" -ForegroundColor Green
Write-Host "  net use \\nas\homes /user:weng@nas 19801502 /persistent:yes" -ForegroundColor Gray
Write-Host ""
Write-Host "Method D: Connect to parent share first" -ForegroundColor Green
Write-Host "  net use \\nas\home /user:weng 19801502 /persistent:yes" -ForegroundColor Gray
Write-Host "  Then try: net use \\nas\homes" -ForegroundColor Gray
Write-Host ""
