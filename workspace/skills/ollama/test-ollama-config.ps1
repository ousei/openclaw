# Test Ollama Configuration for OpenClaw
# 测试 OpenClaw 的 Ollama 配置

Write-Host "=== Testing Ollama Configuration ===" -ForegroundColor Cyan
Write-Host ""

# Check Ollama service
Write-Host "[1/4] Checking Ollama service..." -ForegroundColor Yellow
try {
    $version = ollama --version 2>&1
    Write-Host "  Ollama version: $version" -ForegroundColor Green
} catch {
    Write-Host "  ERROR: Ollama not found in PATH" -ForegroundColor Red
    exit 1
}
Write-Host ""

# Check API endpoint
Write-Host "[2/4] Testing Ollama API endpoint..." -ForegroundColor Yellow
try {
    $response = Invoke-RestMethod -Uri "http://localhost:11434/api/tags" -Method GET -ErrorAction Stop
    Write-Host "  OK: Ollama API is accessible" -ForegroundColor Green
    Write-Host "  Available models: $($response.models.Count)" -ForegroundColor Gray
} catch {
    Write-Host "  ERROR: Cannot connect to Ollama API at http://localhost:11434" -ForegroundColor Red
    Write-Host "  Make sure Ollama service is running" -ForegroundColor Yellow
    exit 1
}
Write-Host ""

# List configured models
Write-Host "[3/4] Checking configured models..." -ForegroundColor Yellow
$config = Get-Content "C:\Users\wengzheng\.openclaw\openclaw.json" | ConvertFrom-Json
$primary = $config.agents.defaults.model.primary
$fallbacks = $config.agents.defaults.model.fallbacks

Write-Host "  Primary model: $primary" -ForegroundColor Cyan
Write-Host "  Fallback models:" -ForegroundColor Gray
foreach ($fallback in $fallbacks) {
    Write-Host "    - $fallback" -ForegroundColor Gray
}
Write-Host ""

# Test model generation
Write-Host "[4/4] Testing model generation..." -ForegroundColor Yellow
$modelName = $primary -replace "ollama/", ""
Write-Host "  Testing model: $modelName" -ForegroundColor Gray
try {
    $body = @{
        model = $modelName
        prompt = "Say hello in one sentence."
        stream = $false
    } | ConvertTo-Json
    
    $result = Invoke-RestMethod -Uri "http://localhost:11434/api/generate" -Method POST -Body $body -ContentType "application/json" -ErrorAction Stop
    Write-Host "  OK: Model responded successfully" -ForegroundColor Green
    Write-Host "  Response: $($result.response)" -ForegroundColor Gray
} catch {
    Write-Host "  ERROR: Model generation failed" -ForegroundColor Red
    Write-Host "  Error: $($_.Exception.Message)" -ForegroundColor Yellow
}
Write-Host ""

Write-Host "=== Configuration Summary ===" -ForegroundColor Cyan
Write-Host ""
Write-Host "OpenClaw is configured to use:" -ForegroundColor Yellow
Write-Host "  Primary: $primary" -ForegroundColor Green
Write-Host "  Fallbacks: $($fallbacks -join ', ')" -ForegroundColor Gray
Write-Host ""
Write-Host "Restart OpenClaw gateway for changes to take effect:" -ForegroundColor Yellow
Write-Host "  Stop: Ctrl+C (if running)" -ForegroundColor Gray
Write-Host "  Start: gateway.cmd (or your startup command)" -ForegroundColor Gray
Write-Host ""
