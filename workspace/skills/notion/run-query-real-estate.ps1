# Wrapper script for query-real-estate.ps1
# 包装脚本，确保正确的编码和路径设置

# Fix encoding issues - Set console output to UTF-8
[Console]::OutputEncoding = [System.Text.Encoding]::UTF8
$OutputEncoding = [System.Text.Encoding]::UTF8
[Console]::InputEncoding = [System.Text.Encoding]::UTF8
$PSDefaultParameterValues['*:Encoding'] = 'utf8'

# Set console code page to UTF-8 (Windows)
chcp 65001 | Out-Null

# 需要 NOTION_API_KEY（在 .env 或环境变量中配置）
if (-not $env:NOTION_API_KEY) {
    Write-Error "NOTION_API_KEY 未设置，请在 .env 或环境变量中配置"
    exit 1
}

# Get script directory
$scriptDir = Split-Path -Parent $MyInvocation.MyCommand.Path

# Change to script directory
Set-Location $scriptDir

# Run the actual script
& "$scriptDir\query-real-estate.ps1"
