# Fix NAS Connection Conflict (Error 1219)
# Fix NAS connection conflict issue

Write-Host "=== Fix NAS Connection Conflict (Error 1219) ===" -ForegroundColor Cyan
Write-Host ""

# Step 1: View all network connections
Write-Host "[1/4] Viewing all network connections..." -ForegroundColor Yellow
$allConnections = net use
Write-Host $allConnections
Write-Host ""

# Step 2: Find all nas connections
Write-Host "[2/4] Finding all nas connections..." -ForegroundColor Yellow
$nasConnections = net use | Select-String "\\\\nas"
if ($nasConnections) {
    Write-Host "Found nas connections:" -ForegroundColor Gray
    $nasConnections | ForEach-Object {
        Write-Host "  $_" -ForegroundColor Gray
    }
} else {
    Write-Host "No nas connections found" -ForegroundColor Gray
}
Write-Host ""

# Step 3: Disconnect all nas connections
Write-Host "[3/4] Disconnecting all nas connections..." -ForegroundColor Yellow
Write-Host "Executing: net use \\nas\* /delete /yes" -ForegroundColor Gray
net use \\nas\* /delete /yes 2>$null
Write-Host "OK: Disconnected all nas connections" -ForegroundColor Green
Write-Host ""

# Step 4: Clear Windows credential cache
Write-Host "[4/4] Clearing Windows credential cache..." -ForegroundColor Yellow
$credList = cmdkey /list 2>$null
$nasCreds = $credList | Select-String -Pattern "nas" -CaseSensitive:$false
if ($nasCreds) {
    Write-Host "Found nas-related credentials:" -ForegroundColor Gray
    foreach ($cred in $nasCreds) {
        Write-Host "  $cred" -ForegroundColor Gray
        if ($cred -match "target=(.+)") {
            $target = $matches[1].Trim()
            Write-Host "    Deleting: $target" -ForegroundColor DarkGray
            cmdkey /delete:"$target" 2>$null | Out-Null
        }
    }
    Write-Host "OK: Credential cache cleared" -ForegroundColor Green
} else {
    Write-Host "No nas-related credentials found" -ForegroundColor Gray
}
Write-Host ""

# Verify
Write-Host "=== Verify Connection Status ===" -ForegroundColor Cyan
$remaining = net use | Select-String "\\\\nas"
if ($remaining) {
    Write-Host "WARNING: Still have nas connections:" -ForegroundColor Yellow
    $remaining | ForEach-Object {
        Write-Host "  $_" -ForegroundColor Gray
    }
    Write-Host ""
    Write-Host "If connections remain, manually disconnect:" -ForegroundColor Yellow
    Write-Host "  net use [drive_or_path] /delete" -ForegroundColor Gray
} else {
    Write-Host "OK: All nas connections cleared" -ForegroundColor Green
}
Write-Host ""

# Provide reconnection commands
Write-Host "=== Now you can reconnect ===" -ForegroundColor Cyan
Write-Host ""
Write-Host "Method 1: Use simple username" -ForegroundColor Green
Write-Host "  net use \\nas\homes /user:weng 19801502 /persistent:yes" -ForegroundColor Gray
Write-Host ""
Write-Host "Method 2: Use full domain username" -ForegroundColor Green
Write-Host "  net use \\nas\homes /user:weng@nas 19801502 /persistent:yes" -ForegroundColor Gray
Write-Host ""
Write-Host "Method 3: Manual connection in File Explorer (Recommended)" -ForegroundColor Green
Write-Host "  1. Open File Explorer" -ForegroundColor Gray
Write-Host "  2. Type in address bar: \\nas\homes" -ForegroundColor Gray
Write-Host "  3. Enter username and password" -ForegroundColor Gray
Write-Host "  4. Check 'Remember my credentials'" -ForegroundColor Gray
Write-Host ""
