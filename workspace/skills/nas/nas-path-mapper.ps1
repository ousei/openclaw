# NAS Path Mapper
# 将 Nas 映射为 \\nas，避免 OpenClaw 识别错误

# 定义 NAS 路径映射
$script:NasRoot = "\\nas"
$script:NasHomes = "\\nas\homes"
$script:NasHomesWeng = "\\nas\homes\weng"

# 函数：将 Nas 路径转换为实际路径
function Convert-NasPath {
    param(
        [Parameter(Mandatory=$true)]
        [string]$Path
    )
    
    # 替换 Nas 为 \\nas（不区分大小写）
    $convertedPath = $Path -replace '^Nas\\', '\\nas\' -replace '^Nas/', '\\nas\' -replace '^Nas', '\\nas'
    
    return $convertedPath
}

# 函数：快速访问 NAS 路径
function Get-NasPath {
    param(
        [Parameter(Mandatory=$false)]
        [string]$SubPath = ""
    )
    
    $basePath = $script:NasHomesWeng
    
    if ($SubPath) {
        # 如果 SubPath 以 \ 开头，去掉它
        if ($SubPath.StartsWith('\')) {
            $SubPath = $SubPath.Substring(1)
        }
        return Join-Path $basePath $SubPath
    }
    
    return $basePath
}

# 导出函数
Export-ModuleMember -Function Convert-NasPath, Get-NasPath

# 示例用法
Write-Host "=== NAS 路径映射工具 ===" -ForegroundColor Cyan
Write-Host ""
Write-Host "使用方法:" -ForegroundColor Yellow
Write-Host "  Convert-NasPath 'Nas\homes\weng\履歴書'" -ForegroundColor Gray
Write-Host "  结果: \\nas\homes\weng\履歴書" -ForegroundColor Green
Write-Host ""
Write-Host "  Get-NasPath '履歴書'" -ForegroundColor Gray
Write-Host "  结果: \\nas\homes\weng\履歴書" -ForegroundColor Green
Write-Host ""
