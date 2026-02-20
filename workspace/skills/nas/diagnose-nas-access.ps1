# Diagnose NAS Access - Full NAS access diagnosis
# Check user access to \\nas

Write-Host "=== NAS Access Diagnosis ===" -ForegroundColor Cyan
Write-Host ""

# Test root path
$nasRoot = "\\nas"
Write-Host "[1/5] Testing NAS root path..." -ForegroundColor Yellow
if (Test-Path $nasRoot) {
    Write-Host "OK: $nasRoot is accessible" -ForegroundColor Green
    
    try {
        $shares = Get-ChildItem $nasRoot -ErrorAction Stop | Select-Object Name, FullName, PSIsContainer
        Write-Host "`nAvailable shares:" -ForegroundColor Cyan
        foreach ($share in $shares) {
            $icon = if ($share.PSIsContainer) { "[DIR]" } else { "[FILE]" }
            Write-Host "  OK $icon $($share.Name)" -ForegroundColor Gray
        }
    } catch {
        Write-Host "ERROR: Cannot list shares: $($_.Exception.Message)" -ForegroundColor Red
    }
} else {
    Write-Host "ERROR: $nasRoot is not accessible" -ForegroundColor Red
}
Write-Host ""

# Test individual shares
Write-Host "[2/5] Testing individual shares..." -ForegroundColor Yellow
$testShares = @("home", "homes", "downloads", "photo", "video", "music", "works")
foreach ($share in $testShares) {
    $path = "\\nas\$share"
    Write-Host -NoNewline "  Testing $share ... " -ForegroundColor Gray
    try {
        if (Test-Path $path -ErrorAction Stop) {
            $items = Get-ChildItem $path -ErrorAction Stop | Select-Object -First 1
            Write-Host "OK" -ForegroundColor Green
        } else {
            Write-Host "FAILED" -ForegroundColor Red
        }
    } catch {
        $errorMsg = $_.Exception.Message
        if ($errorMsg -like "*UnauthorizedAccessException*" -or $errorMsg -like "*Permission*") {
            Write-Host "PERMISSION DENIED" -ForegroundColor Red
        } else {
            Write-Host "ERROR: $errorMsg" -ForegroundColor Red
        }
    }
}
Write-Host ""

# Check network connections
Write-Host "[3/5] Checking network connections..." -ForegroundColor Yellow
$connections = net use 2>$null
if ($connections) {
    $nasConnections = $connections | Select-String "\\\\nas"
    if ($nasConnections) {
        Write-Host "Current NAS connections:" -ForegroundColor Gray
        $nasConnections | ForEach-Object {
            Write-Host "  $_" -ForegroundColor Gray
        }
    } else {
        Write-Host "  No persistent NAS connections found" -ForegroundColor Gray
    }
} else {
    Write-Host "  No network drive mappings" -ForegroundColor Gray
}
Write-Host ""

# Detailed homes diagnosis
Write-Host "[4/5] Detailed homes folder diagnosis..." -ForegroundColor Yellow
$homesPath = "\\nas\homes"
Write-Host "Path: $homesPath" -ForegroundColor Gray

Write-Host "`nTesting access methods:" -ForegroundColor Cyan

# Method 1: Test-Path
Write-Host "  1. Test-Path ... " -NoNewline -ForegroundColor Gray
try {
    $result = Test-Path $homesPath -ErrorAction Stop
    if ($result) {
        Write-Host "PASSED" -ForegroundColor Green
    } else {
        Write-Host "FAILED" -ForegroundColor Red
    }
} catch {
    Write-Host "EXCEPTION: $($_.Exception.GetType().Name)" -ForegroundColor Red
}

# Method 2: Get-Item
Write-Host "  2. Get-Item ... " -NoNewline -ForegroundColor Gray
try {
    $item = Get-Item $homesPath -ErrorAction Stop
    Write-Host "PASSED - Type: $($item.GetType().Name)" -ForegroundColor Green
} catch {
    Write-Host "EXCEPTION: $($_.Exception.GetType().Name)" -ForegroundColor Red
    Write-Host "          Message: $($_.Exception.Message)" -ForegroundColor DarkYellow
}

# Method 3: Get-ChildItem
Write-Host "  3. Get-ChildItem ... " -NoNewline -ForegroundColor Gray
try {
    $items = Get-ChildItem $homesPath -ErrorAction Stop | Select-Object -First 1
    Write-Host "PASSED - Can list contents" -ForegroundColor Green
} catch {
    Write-Host "EXCEPTION: $($_.Exception.GetType().Name)" -ForegroundColor Red
    Write-Host "          Message: $($_.Exception.Message)" -ForegroundColor DarkYellow
}

Write-Host ""

# Solutions
Write-Host "[5/5] Suggested solutions:" -ForegroundColor Yellow
Write-Host ""
Write-Host "If homes cannot be accessed but other folders can:" -ForegroundColor Cyan
Write-Host ""
Write-Host "1. homes folder has special permission restrictions" -ForegroundColor Green
Write-Host "   - Even if you have access to \\nas, homes may have independent permissions" -ForegroundColor Gray
Write-Host "   - Solution: Check homes permission settings in Synology DSM" -ForegroundColor Gray
Write-Host ""
Write-Host "2. Windows credential cache issue" -ForegroundColor Green
Write-Host "   - Clear old credentials:" -ForegroundColor Gray
Write-Host "     cmdkey /list | findstr nas" -ForegroundColor DarkGray
Write-Host "     cmdkey /delete:target:nas" -ForegroundColor DarkGray
Write-Host ""
Write-Host "3. Connection conflict" -ForegroundColor Green
Write-Host "   - Disconnect all connections and reconnect:" -ForegroundColor Gray
Write-Host "     net use \\nas\* /delete /yes" -ForegroundColor DarkGray
Write-Host "     Then access \\nas\homes in File Explorer" -ForegroundColor DarkGray
Write-Host ""
Write-Host "4. Use different username format" -ForegroundColor Green
Write-Host "   - Try using full domain username:" -ForegroundColor Gray
Write-Host "     net use \\nas\homes /user:weng@nas your_password" -ForegroundColor DarkGray
Write-Host ""
