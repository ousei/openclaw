# Web Fetch 工具已禁用

## 原因

根据用户要求，所有需要网页数据的场景都应该使用 SearXNG 搜索，而不是直接使用 `web_fetch` 工具访问特定 URL。

## 问题

`web_fetch` 工具直接访问特定 URL 时经常遇到问题：
- ❌ DNS 解析失败 (`getaddrinfo ENOTFOUND`)
- ❌ 404 错误（URL 已更改或不存在）
- ❌ 403 错误（访问限制）
- ❌ 需要知道确切的 URL

## 解决方案

**使用 SearXNG 搜索替代 `web_fetch`**

### 优势

- ✅ 通过搜索获取多个来源的结果
- ✅ 不需要知道确切 URL
- ✅ 绕过网站访问限制
- ✅ 本地部署，无速率限制
- ✅ 返回 JSON 格式数据，不创建临时文件

### 使用方法

#### 1. 天气信息

```powershell
cd C:\Users\wengzheng\.openclaw\workspace\skills\weather
.\search_weather.ps1 "Tokyo"
```

#### 2. 通用搜索

```powershell
cd C:\Users\wengzheng\.openclaw\workspace\skills\local-search\scripts
.\search.ps1 "your search query"
```

#### 3. 在其他脚本中使用

```powershell
. C:\Users\wengzheng\.openclaw\workspace\skills\utilities\searxng-search.ps1
$results = Search-SearXNG "your query"
```

## 配置更改

在 `openclaw.json` 中：

```json
{
  "tools": {
    "web": {
      "search": {
        "enabled": false,
        "apiKey": "disabled-using-local-searxng"
      },
      "fetch": {
        "enabled": false
      }
    }
  }
}
```

**注意**: OpenClaw 配置不支持自定义字段（如 `reason`），只需设置 `enabled: false` 即可。

## 相关文档

- `.cursor/rules/use-searxng-for-web-data.mdc` - Cursor 规则
- `workspace/SEARXNG-USAGE-GUIDE.md` - 使用指南
- `workspace/SEARXNG-INTEGRATION-SUMMARY.md` - 集成总结

## 注意事项

如果确实需要直接访问特定 URL（例如用户明确提供了 URL），可以临时启用 `web_fetch`，但默认情况下应该使用 SearXNG 搜索。
