# SearXNG 网页数据获取指南

## 概述

所有需要从网页获取数据的场景都应该使用 SearXNG，而不是创建临时文件或使用其他方式。

## 为什么使用 SearXNG HTML 提取方式？

1. **绕过 Bot Detection**: SearXNG API 有严格的 bot detection，直接 API 调用会返回 403
2. **无需临时文件**: 直接从 HTML 提取数据，返回 JSON 格式
3. **通用性强**: 适用于所有需要网页搜索的场景
4. **本地部署**: 使用本地 SearXNG 实例，无速率限制

## SearXNG 实例信息

- **URL**: `http://localhost:18888`
- **状态**: 已部署并运行
- **访问方式**: HTML 页面提取（推荐）

## 使用方法

### 方法 1: 使用 local-search 脚本

```powershell
cd C:\Users\wengzheng\.openclaw\workspace\skills\local-search\scripts
.\search.ps1 "your search query"
```

### 方法 2: 使用通用搜索函数

```powershell
# 在其他 PowerShell 脚本中
. C:\Users\wengzheng\.openclaw\workspace\skills\utilities\searxng-search.ps1
$results = Search-SearXNG "your query"

# 处理结果
foreach ($result in $results) {
    Write-Host "Title: $($result.Title)"
    Write-Host "URL: $($result.URL)"
    Write-Host "Snippet: $($result.Snippet)"
}
```

### 方法 3: 直接调用 HTML 提取脚本

```powershell
cd C:\Users\wengzheng\.openclaw\workspace\skills\local-search\scripts
.\search_from_html.ps1 "your search query"
```

## 输出格式

所有脚本都返回 JSON 格式：

```json
[
    {
        "Title": "搜索结果标题",
        "URL": "https://example.com",
        "Snippet": "结果摘要..."
    }
]
```

## 在技能中使用示例

### Weather 技能

```powershell
# weather/search_weather.ps1 已更新为使用 SearXNG HTML 提取
.\search_weather.ps1 "Tokyo"
```

### Email 技能（如果需要搜索邮件相关信息）

```powershell
# 示例：搜索邮件服务信息
. C:\Users\wengzheng\.openclaw\workspace\skills\utilities\searxng-search.ps1
$emailInfo = Search-SearXNG "Gmail API documentation"
```

### 其他技能

任何需要网页数据的技能都可以：

1. **直接调用搜索脚本**:
   ```powershell
   $results = & "C:\Users\wengzheng\.openclaw\workspace\skills\local-search\scripts\search.ps1" "query" | ConvertFrom-Json
   ```

2. **使用通用函数**:
   ```powershell
   . C:\Users\wengzheng\.openclaw\workspace\skills\utilities\searxng-search.ps1
   $results = Search-SearXNG "query"
   ```

## 重要规则

✅ **应该做的**:
- 使用 SearXNG HTML 提取方式获取网页数据
- 返回 JSON 格式数据
- 不创建临时文件
- 使用本地 SearXNG 实例 (`http://localhost:18888`)

❌ **不应该做的**:
- 创建临时文件来存储搜索结果
- 尝试直接调用 SearXNG API（会返回 403）
- 使用其他外部搜索 API（如已禁用的 Brave Search API）

## 技术细节

### HTML 提取方法

1. 使用 `curl.exe` 获取 SearXNG 搜索页面的 HTML
2. 使用正则表达式提取搜索结果链接：
   - 模式 1: `<h3[^>]*class="[^"]*result[^"]*"[^>]*><a[^>]*href="([^"]+)"[^>]*>([^<]+)</a></h3>`
   - 模式 2: `href="(https?://[^"]+)"[^>]*>([^<]{10,100})</a>`
3. 提取摘要（snippet）：
   - 从结果链接附近查找 `<p class="content">` 或 `<span class="content">`
4. 过滤掉 SearXNG 内部链接（github.com/searxng, searx.space 等）

### 错误处理

如果搜索失败，脚本会返回错误信息：

```json
{
    "error": "错误描述",
    "webUrl": "http://localhost:18888/search?q=...",
    "query": "原始查询"
}
```

## 相关文件

- `workspace/skills/local-search/scripts/search.ps1` - 主搜索脚本
- `workspace/skills/local-search/scripts/search_from_html.ps1` - HTML 提取实现
- `workspace/skills/utilities/searxng-search.ps1` - 通用搜索函数
- `workspace/skills/weather/search_weather.ps1` - 天气搜索示例

## 故障排除

### SearXNG 未运行

```powershell
# 检查容器状态
docker ps | Select-String searxng

# 启动 SearXNG
cd C:\searxng
docker-compose up -d
```

### 没有搜索结果

- 检查 SearXNG 是否可访问: `curl http://localhost:18888`
- 检查网络连接（SearXNG 需要互联网来查询搜索引擎）
- 查看 SearXNG 日志: `docker logs searxng`

### 编码问题

如果遇到中文编码问题，确保：
- PowerShell 使用 UTF-8 编码
- 脚本文件保存为 UTF-8 with BOM 或 UTF-8
