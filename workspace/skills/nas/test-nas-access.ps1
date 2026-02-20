# Test NAS Access Script
# 测试 OpenClaw 访问 NAS 服务器的能力

$nasPath = "\\nas\home"

Write-Host "Testing NAS access..." -ForegroundColor Cyan
Write-Host "NAS Path: $nasPath" -ForegroundColor Yellow
Write-Host ""

# Test 1: Check if path exists
if (Test-Path $nasPath) {
    Write-Host "✅ NAS path is accessible" -ForegroundColor Green
    
    # Test 2: List contents
    try {
        $items = Get-ChildItem $nasPath -ErrorAction Stop | Select-Object -First 10
        Write-Host "`n📁 Contents (first 10 items):" -ForegroundColor Cyan
        foreach ($item in $items) {
            $type = if ($item.PSIsContainer) { "📁" } else { "📄" }
            Write-Host "  $type $($item.Name)" -ForegroundColor Gray
        }
        
        Write-Host "`n✅ NAS access test successful!" -ForegroundColor Green
        Write-Host "OpenClaw can access files at: $nasPath" -ForegroundColor Yellow
        
    } catch {
        Write-Host "❌ Error listing contents: $($_.Exception.Message)" -ForegroundColor Red
    }
    
} else {
    Write-Host "❌ NAS path is not accessible" -ForegroundColor Red
    Write-Host "Please check:" -ForegroundColor Yellow
    Write-Host "  1. Network connection" -ForegroundColor Gray
    Write-Host "  2. NAS server is online" -ForegroundColor Gray
    Write-Host "  3. Windows credentials are saved" -ForegroundColor Gray
    Write-Host "  4. Firewall settings" -ForegroundColor Gray
}
