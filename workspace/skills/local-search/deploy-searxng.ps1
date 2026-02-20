# SearXNG 快速部署脚本
# 用于在本地部署 SearXNG 搜索引擎

Write-Host "🔍 SearXNG 本地搜索部署脚本" -ForegroundColor Cyan
Write-Host ""

# 检查 Docker 是否安装
Write-Host "检查 Docker..." -ForegroundColor Yellow
try {
    $dockerVersion = docker --version
    Write-Host "✓ Docker 已安装: $dockerVersion" -ForegroundColor Green
} catch {
    Write-Host "✗ Docker 未安装！" -ForegroundColor Red
    Write-Host "请先安装 Docker Desktop: https://www.docker.com/products/docker-desktop" -ForegroundColor Yellow
    exit 1
}

# 检查 Docker 是否运行
Write-Host "检查 Docker 服务状态..." -ForegroundColor Yellow
try {
    docker ps | Out-Null
    Write-Host "✓ Docker 服务正在运行" -ForegroundColor Green
} catch {
    Write-Host "✗ Docker 服务未运行！" -ForegroundColor Red
    Write-Host "请启动 Docker Desktop" -ForegroundColor Yellow
    exit 1
}

# 创建目录
$SearXNGDir = "C:\searxng"
Write-Host "创建目录: $SearXNGDir" -ForegroundColor Yellow
if (-not (Test-Path $SearXNGDir)) {
    New-Item -ItemType Directory -Path $SearXNGDir | Out-Null
    Write-Host "✓ 目录已创建" -ForegroundColor Green
} else {
    Write-Host "✓ 目录已存在" -ForegroundColor Green
}

# 创建 docker-compose.yml
$ComposeFile = Join-Path $SearXNGDir "docker-compose.yml"
Write-Host "创建 docker-compose.yml..." -ForegroundColor Yellow

$ComposeContent = @"
version: '3.8'

services:
  searxng:
    image: searxng/searxng:latest
    container_name: searxng
    ports:
      - "8888:8080"
    volumes:
      - ./searxng:/etc/searxng:rw
    environment:
      - SEARXNG_HOSTNAME=http://localhost:8888/
    restart: unless-stopped

  redis:
    image: redis:alpine
    container_name: searxng-redis
    volumes:
      - redis-data:/data
    restart: unless-stopped

volumes:
  redis-data:
"@

$ComposeContent | Out-File -FilePath $ComposeFile -Encoding UTF8
Write-Host "✓ docker-compose.yml 已创建" -ForegroundColor Green

# 启动服务
Write-Host ""
Write-Host "启动 SearXNG 服务..." -ForegroundColor Yellow
Set-Location $SearXNGDir

try {
    docker-compose up -d
    Write-Host "✓ SearXNG 服务已启动" -ForegroundColor Green
} catch {
    Write-Host "✗ 启动失败！" -ForegroundColor Red
    Write-Host "错误: $_" -ForegroundColor Red
    exit 1
}

# 等待服务启动
Write-Host "等待服务启动（10秒）..." -ForegroundColor Yellow
Start-Sleep -Seconds 10

# 测试服务
Write-Host ""
Write-Host "测试 SearXNG API..." -ForegroundColor Yellow
try {
    $TestUrl = "http://localhost:8888/search?q=test&format=json"
    $Response = Invoke-RestMethod -Uri $TestUrl -Method Get -TimeoutSec 5
    Write-Host "✓ SearXNG 运行正常！" -ForegroundColor Green
} catch {
    Write-Host "⚠ SearXNG 可能还在启动中，请稍后测试" -ForegroundColor Yellow
    Write-Host "测试命令: curl http://localhost:8888/search?q=test&format=json" -ForegroundColor Cyan
}

# 显示信息
Write-Host ""
Write-Host "═══════════════════════════════════════" -ForegroundColor Cyan
Write-Host "✅ 部署完成！" -ForegroundColor Green
Write-Host ""
Write-Host "Web 界面: http://localhost:8888" -ForegroundColor Cyan
Write-Host "API 端点: http://localhost:8888/search?q=QUERY&format=json" -ForegroundColor Cyan
Write-Host ""
Write-Host "管理命令:" -ForegroundColor Yellow
Write-Host "  查看日志: docker logs searxng" -ForegroundColor White
Write-Host "  停止服务: docker-compose stop" -ForegroundColor White
Write-Host "  启动服务: docker-compose start" -ForegroundColor White
Write-Host "  重启服务: docker-compose restart" -ForegroundColor White
Write-Host "  删除服务: docker-compose down" -ForegroundColor White
Write-Host "═══════════════════════════════════════" -ForegroundColor Cyan
