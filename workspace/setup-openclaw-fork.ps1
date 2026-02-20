# OpenClaw Fork 设置脚本
# 使用前：将下方 YOUR_GITHUB_USERNAME 替换为你的 GitHub 用户名

$githubUser = "YOUR_GITHUB_USERNAME"
$openclawSrc = "C:\Users\wengzheng\openclaw-src"

if ($githubUser -eq "YOUR_GITHUB_USERNAME") {
    Write-Host "请先编辑本脚本，将 YOUR_GITHUB_USERNAME 替换为你的 GitHub 用户名" -ForegroundColor Yellow
    exit 1
}

Set-Location $openclawSrc

# 移除已存在的 fork 远程（如有）
git remote remove fork 2>$null

# 添加你的 fork
git remote add fork "https://github.com/$githubUser/openclaw.git"
Write-Host "已添加 fork 远程: $githubUser/openclaw" -ForegroundColor Green

# 推送分支
git push -u fork feature/show-thinking-during-generation
if ($LASTEXITCODE -eq 0) {
    Write-Host "`n推送成功！" -ForegroundColor Green
    Write-Host "从你的 fork 安装 OpenClaw："
    Write-Host "  pnpm add -g openclaw@github:$githubUser/openclaw#feature/show-thinking-during-generation" -ForegroundColor Cyan
} else {
    Write-Host "推送失败。请确认：" -ForegroundColor Red
    Write-Host "  1. 已在 GitHub 上 fork openclaw/openclaw"
    Write-Host "  2. 已配置 git 认证（如 SSH 或 credential helper）"
}
