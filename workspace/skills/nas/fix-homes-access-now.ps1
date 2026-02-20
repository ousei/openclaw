# Fix homes Access - Immediate Solution

Write-Host "=== Diagnose and Fix homes Access ===" -ForegroundColor Cyan
Write-Host ""

# Check current connections
Write-Host "[1/5] Checking current connections..." -ForegroundColor Yellow
$connections = net use
$nasConnections = $connections | Select-String "\\\\nas"
if ($nasConnections) {
    Write-Host "Current NAS connections:" -ForegroundColor Gray
    $nasConnections | ForEach-Object { Write-Host "  $_" -ForegroundColor Gray }
} else {
    Write-Host "  No NAS share connections found (only IPC$)" -ForegroundColor Gray
}
Write-Host ""

# Test access
Write-Host "[2/5] Testing access..." -ForegroundColor Yellow
Write-Host "  \\nas\home ... " -NoNewline -ForegroundColor Gray
if (Test-Path "\\nas\home" -ErrorAction SilentlyContinue) {
    Write-Host "OK" -ForegroundColor Green
} else {
    Write-Host "FAILED" -ForegroundColor Red
}

Write-Host "  \\nas\homes ... " -NoNewline -ForegroundColor Gray
try {
    if (Test-Path "\\nas\homes" -ErrorAction Stop) {
        Write-Host "OK" -ForegroundColor Green
    } else {
        Write-Host "FAILED" -ForegroundColor Red
    }
} catch {
    Write-Host "PERMISSION DENIED" -ForegroundColor Red
}
Write-Host ""

# Disconnect all nas connections first
Write-Host "[3/5] Disconnecting all nas connections..." -ForegroundColor Yellow
net use \\nas\* /delete /yes 2>$null
Write-Host "  All connections disconnected" -ForegroundColor Gray
Write-Host ""

# Reconnect homes with correct format
Write-Host "[4/5] Reconnecting homes (using nas\weng format)..." -ForegroundColor Yellow
Write-Host "Command: net use \\nas\homes /user:nas\weng 19801502 /persistent:yes" -ForegroundColor Gray
$result = net use \\nas\homes /user:nas\weng 19801502 /persistent:yes 2>&1
if ($LASTEXITCODE -eq 0) {
    Write-Host "  OK: Connection successful" -ForegroundColor Green
} else {
    Write-Host "  ERROR: Connection failed" -ForegroundColor Red
    Write-Host "  $result" -ForegroundColor Yellow
}
Write-Host ""

# Verify access
Write-Host "[5/5] Verifying access..." -ForegroundColor Yellow
Start-Sleep -Seconds 2
try {
    if (Test-Path "\\nas\homes" -ErrorAction Stop) {
        Write-Host "  OK: \\nas\homes is now accessible" -ForegroundColor Green
        try {
            $items = Get-ChildItem "\\nas\homes" -ErrorAction Stop | Select-Object -First 3
            Write-Host "`n  Folder contents (first 3 items):" -ForegroundColor Cyan
            foreach ($item in $items) {
                $type = if ($item.PSIsContainer) { "[DIR]" } else { "[FILE]" }
                Write-Host "    $type $($item.Name)" -ForegroundColor Gray
            }
        } catch {
            Write-Host "  WARNING: Can access path but cannot list contents" -ForegroundColor Yellow
            Write-Host "  Error: $($_.Exception.Message)" -ForegroundColor DarkYellow
        }
    } else {
        Write-Host "  FAILED: Still cannot access" -ForegroundColor Red
    }
} catch {
    Write-Host "  ERROR: $($_.Exception.Message)" -ForegroundColor Red
}
Write-Host ""

# Alternative solutions
Write-Host "=== If still cannot access, try these methods ===" -ForegroundColor Cyan
Write-Host ""
Write-Host "Method 1: Manual connection in File Explorer (MOST RELIABLE)" -ForegroundColor Green
Write-Host "  1. Press Windows + E to open File Explorer" -ForegroundColor Gray
Write-Host "  2. Type in address bar: \\nas\homes" -ForegroundColor Gray
Write-Host "  3. Enter username: nas\weng" -ForegroundColor Gray
Write-Host "  4. Enter password: 19801502" -ForegroundColor Gray
Write-Host "  5. Check 'Remember my credentials'" -ForegroundColor Gray
Write-Host "  6. Click OK" -ForegroundColor Gray
Write-Host ""
Write-Host "Method 2: Check NAS permission settings" -ForegroundColor Green
Write-Host "  - Login to Synology DSM" -ForegroundColor Gray
Write-Host "  - File Station -> Right-click homes -> Properties -> Permissions" -ForegroundColor Gray
Write-Host "  - Make sure 'Apply to subfolders' is checked" -ForegroundColor Gray
Write-Host ""
Write-Host "Method 3: Restart computer" -ForegroundColor Green
Write-Host "  - Restart clears all connection caches" -ForegroundColor Gray
Write-Host "  - After restart, use File Explorer method" -ForegroundColor Gray
Write-Host ""
