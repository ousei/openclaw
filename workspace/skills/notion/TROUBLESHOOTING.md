# Notion API 查询故障排查指南

## 如果遇到 400 错误

### 步骤 1: 检查环境变量

在 PowerShell 中运行：
```powershell
$env:NOTION_API_KEY
```

如果返回空，说明环境变量未设置。设置它：
```powershell
$env:NOTION_API_KEY = "ntn_xxx..."
```

### 步骤 2: 使用调试版本脚本

调试版本会显示详细的错误信息：
```powershell
cd C:\Users\wengzheng\.openclaw\workspace\skills\notion
.\query-todos-debug.ps1
```

### 步骤 3: 手动测试 API 连接

```powershell
$env:NOTION_API_KEY = "ntn_xxx..."
$dbId = "2e29fe12-e0aa-816e-9366-dae1fbe6fd20"
$headers = @{
    "Authorization" = "Bearer $env:NOTION_API_KEY"
    "Notion-Version" = "2022-06-28"
    "Content-Type" = "application/json"
}

try {
    $response = Invoke-RestMethod `
        -Uri "https://api.notion.com/v1/databases/$dbId/query" `
        -Method POST `
        -Headers $headers `
        -ContentType "application/json"
    Write-Host "Success! Found $($response.results.Count) tasks" -ForegroundColor Green
} catch {
    Write-Host "Error: $($_.Exception.Message)" -ForegroundColor Red
    if ($_.Exception.Response) {
        $stream = $_.Exception.Response.GetResponseStream()
        $reader = New-Object System.IO.StreamReader($stream)
        $errorBody = $reader.ReadToEnd()
        $reader.Close()
        $stream.Close()
        Write-Host "Error details: $errorBody" -ForegroundColor Yellow
    }
}
```

## 常见错误及解决方案

### 错误 1: "NOTION_API_KEY not found"
**原因**: 环境变量未设置
**解决**: 设置环境变量（见步骤 1）

### 错误 2: "400 Bad Request"
**可能原因**:
- API key 无效或过期
- 数据库 ID 错误
- Integration 未添加到数据库

**排查**:
1. 检查 API key 是否正确
2. 确认数据库 ID: `2e29fe12-e0aa-816e-9366-dae1fbe6fd20`
3. 在 Notion 中确认 integration 已添加到数据库

### 错误 3: "401 Unauthorized"
**原因**: API key 无效
**解决**: 检查 API key 是否正确，确保以 `ntn_` 开头

### 错误 4: PowerShell 编码问题
**现象**: 日文显示为乱码
**说明**: 这是 PowerShell 控制台编码问题，不影响数据。JSON 输出中的数据是正确的。

## 推荐的执行方式

**方式 1: 直接在 PowerShell 中运行（最可靠）**
```powershell
# 打开 PowerShell，然后：
$env:NOTION_API_KEY = "ntn_xxx..."
cd C:\Users\wengzheng\.openclaw\workspace\skills\notion
.\query-notion-todos.ps1
```

**方式 2: 使用调试版本（如果遇到问题）**
```powershell
cd C:\Users\wengzheng\.openclaw\workspace\skills\notion
.\query-todos-debug.ps1
```

## 验证 API Key 是否有效

```powershell
$env:NOTION_API_KEY = "ntn_xxx..."
$headers = @{
    "Authorization" = "Bearer $env:NOTION_API_KEY"
    "Notion-Version" = "2022-06-28"
}
try {
    $result = Invoke-RestMethod -Uri "https://api.notion.com/v1/users/me" -Headers $headers
    Write-Host "API Key is valid! User: $($result.name)" -ForegroundColor Green
} catch {
    Write-Host "API Key is invalid or expired" -ForegroundColor Red
}
```
