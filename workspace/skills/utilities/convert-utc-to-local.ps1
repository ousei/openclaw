# Convert UTC Time to Local Time
# 将 UTC 时间转换为本地时间（东京时间）

param(
    [Parameter(Mandatory=$false)]
    [string]$UtcTime = ""
)

Write-Host "=== UTC 时间转换工具 ===" -ForegroundColor Cyan
Write-Host ""

# 如果没有提供时间，使用当前 UTC 时间
if ([string]::IsNullOrEmpty($UtcTime)) {
    $UtcTime = (Get-Date).ToUniversalTime().ToString("yyyy-MM-dd HH:mm:ss")
    Write-Host "使用当前 UTC 时间: $UtcTime" -ForegroundColor Yellow
    Write-Host ""
}

# 解析 UTC 时间
try {
    $utcDateTime = [DateTime]::Parse($UtcTime)
    if ($utcDateTime.Kind -ne [System.DateTimeKind]::Utc) {
        $utcDateTime = [DateTime]::SpecifyKind($utcDateTime, [System.DateTimeKind]::Utc)
    }
    
    # 转换为本地时间
    $localTime = $utcDateTime.ToLocalTime()
    
    # 显示结果
    Write-Host "UTC 时间:     $($utcDateTime.ToString('yyyy-MM-dd HH:mm:ss')) UTC" -ForegroundColor Gray
    Write-Host "本地时间:     $($localTime.ToString('yyyy-MM-dd HH:mm:ss')) $(Get-TimeZone | Select-Object -ExpandProperty Id)" -ForegroundColor Green
    Write-Host "时差:         +$((Get-TimeZone).BaseUtcOffset.TotalHours) 小时" -ForegroundColor Cyan
    Write-Host ""
    
    # 如果是从 OpenClaw 日志复制的时间格式（HH:mm:ss）
    if ($UtcTime -match '^(\d{2}):(\d{2}):(\d{2})$') {
        $hours = [int]$matches[1]
        $minutes = [int]$matches[2]
        $seconds = [int]$matches[3]
        
        $today = Get-Date -Hour 0 -Minute 0 -Second 0
        $utcToday = $today.ToUniversalTime()
        $utcDateTime = $utcToday.AddHours($hours).AddMinutes($minutes).AddSeconds($seconds)
        $localTime = $utcDateTime.ToLocalTime()
        
        Write-Host "快速转换（仅时间）:" -ForegroundColor Yellow
        Write-Host "  UTC:   $UtcTime" -ForegroundColor Gray
        Write-Host "  本地:  $($localTime.ToString('HH:mm:ss'))" -ForegroundColor Green
    }
    
} catch {
    Write-Host "❌ 错误: 无法解析时间格式 '$UtcTime'" -ForegroundColor Red
    Write-Host "   支持的格式:" -ForegroundColor Yellow
    Write-Host "   - yyyy-MM-dd HH:mm:ss (例如: 2026-02-01 03:33:23)" -ForegroundColor Gray
    Write-Host "   - HH:mm:ss (例如: 03:33:23，将使用今天的日期)" -ForegroundColor Gray
    exit 1
}

Write-Host ""
Write-Host "=== 转换完成 ===" -ForegroundColor Cyan
