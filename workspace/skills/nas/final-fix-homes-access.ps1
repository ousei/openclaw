# Final Fix for homes Access - Alternative Methods
# 最终修复 homes 访问问题 - 替代方法

Write-Host "=== Final Fix for homes Access ===" -ForegroundColor Cyan
Write-Host ""
Write-Host "Since restarting Workstation service failed, let's try alternative methods:" -ForegroundColor Yellow
Write-Host ""

# Method 1: Check what's using the service
Write-Host "[Method 1] Check processes using SMB..." -ForegroundColor Yellow
Write-Host "Run this in Administrator PowerShell:" -ForegroundColor Gray
Write-Host "  Get-Process | Where-Object { `$_.Path -like '*smb*' -or `$_.ProcessName -like '*smb*' }" -ForegroundColor DarkGray
Write-Host ""

# Method 2: Use File Explorer (BEST OPTION)
Write-Host "[Method 2] Use File Explorer (RECOMMENDED):" -ForegroundColor Green
Write-Host ""
Write-Host "This is the most reliable method:" -ForegroundColor Cyan
Write-Host ""
Write-Host "1. Press Windows + E to open File Explorer" -ForegroundColor Gray
Write-Host "2. Click in the address bar (or press Ctrl+L)" -ForegroundColor Gray
Write-Host "3. Type exactly: \\nas\homes" -ForegroundColor Gray
Write-Host "4. Press Enter" -ForegroundColor Gray
Write-Host "5. When login dialog appears:" -ForegroundColor Gray
Write-Host "   - Username: weng" -ForegroundColor DarkGray
Write-Host "   - Password: 19801502" -ForegroundColor DarkGray
Write-Host "   - Check 'Remember my credentials'" -ForegroundColor DarkGray
Write-Host "6. Click OK" -ForegroundColor Gray
Write-Host ""
Write-Host "This method bypasses command-line connection issues." -ForegroundColor Yellow
Write-Host ""

# Method 3: Restart computer
Write-Host "[Method 3] Restart Computer (if Method 2 doesn't work):" -ForegroundColor Yellow
Write-Host ""
Write-Host "A full restart will clear all connection caches:" -ForegroundColor Gray
Write-Host "  shutdown /r /t 0" -ForegroundColor DarkGray
Write-Host ""
Write-Host "After restart, try Method 2 (File Explorer) again." -ForegroundColor Gray
Write-Host ""

# Method 4: Try connecting via different share first
Write-Host "[Method 4] Try accessing via web interface:" -ForegroundColor Yellow
Write-Host ""
Write-Host "Since you can access other shares, try:" -ForegroundColor Gray
Write-Host "1. Open File Explorer" -ForegroundColor Gray
Write-Host "2. Go to: \\nas\home (this works)" -ForegroundColor Gray
Write-Host "3. Then navigate to homes folder if it's visible" -ForegroundColor Gray
Write-Host ""

# Method 5: Check if homes is accessible via home
Write-Host "[Method 5] Check if homes is a subfolder of home:" -ForegroundColor Yellow
Write-Host ""
Write-Host "Testing if homes is accessible via home path..." -ForegroundColor Gray
try {
    $homePath = "\\nas\home"
    if (Test-Path $homePath) {
        $items = Get-ChildItem $homePath -ErrorAction Stop | Select-Object Name
        Write-Host "Contents of \\nas\home:" -ForegroundColor Cyan
        $items | ForEach-Object {
            Write-Host "  $($_.Name)" -ForegroundColor Gray
        }
        Write-Host ""
        if ($items.Name -contains "homes") {
            Write-Host "FOUND: homes is a subfolder!" -ForegroundColor Green
            Write-Host "Try accessing: \\nas\home\homes" -ForegroundColor Yellow
        } else {
            Write-Host "homes is NOT a subfolder of home" -ForegroundColor Gray
        }
    }
} catch {
    Write-Host "Could not check home contents" -ForegroundColor Red
}
Write-Host ""

# Summary
Write-Host "=== SUMMARY ===" -ForegroundColor Cyan
Write-Host ""
Write-Host "BEST SOLUTION: Use File Explorer (Method 2)" -ForegroundColor Green
Write-Host "  - Most reliable" -ForegroundColor Gray
Write-Host "  - Handles credentials automatically" -ForegroundColor Gray
Write-Host "  - Bypasses command-line connection issues" -ForegroundColor Gray
Write-Host ""
Write-Host "If that doesn't work, restart your computer and try again." -ForegroundColor Yellow
Write-Host ""
