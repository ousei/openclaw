# Web Fetch 404 错误处理

## 问题描述

`web_fetch` 工具在获取 Yahoo 天气页面时返回 404 错误。

**错误信息：**
```
web_fetch failed: Web fetch failed (404): Yahoo!天気・災害
指定された地域、またはコンテンツを表示できませんでした。
```

## 可能的原因

1. **URL 不正确或已过期**
   - Yahoo 天气页面的 URL 可能已更改
   - 需要特定的参数或格式

2. **需要认证或 Cookies**
   - 某些页面需要登录或特定的 cookies
   - 可能需要设置 User-Agent 或其他 headers

3. **地区限制**
   - Yahoo 天气可能对某些地区有访问限制
   - 需要特定的语言或地区设置

## 解决方案

### 方案 1: 使用 SearXNG 搜索天气（推荐）

由于已部署本地 SearXNG，建议使用搜索功能而不是直接 fetch 特定 URL：

```powershell
# 使用 weather skill
cd C:\Users\wengzheng\.openclaw\workspace\skills\weather
.\search_weather.ps1 "Tokyo"
```

### 方案 2: 使用其他天气 API

如果需要直接获取天气数据，可以考虑：

1. **OpenWeatherMap API**（需要 API key）
2. **WeatherAPI**（有免费计划）
3. **通过 SearXNG 搜索**（推荐，无需 API key）

### 方案 3: 修复 web_fetch URL

如果必须使用 web_fetch，需要：

1. **确认正确的 Yahoo 天气 URL 格式**
2. **添加必要的 headers**（User-Agent、Accept-Language 等）
3. **处理重定向**

## 当前推荐方案

**使用本地 SearXNG 搜索天气信息：**

1. **通过 Web 界面**:
   - 访问: http://localhost:18888
   - 搜索: "Tokyo weather" 或 "東京 天気"

2. **通过 weather Skill**:
   ```powershell
   cd C:\Users\wengzheng\.openclaw\workspace\skills\weather
   .\search_weather.ps1 "Tokyo"
   ```

3. **通过 local-search Skill**:
   ```powershell
   cd C:\Users\wengzheng\.openclaw\workspace\skills\local-search\scripts
   .\search.ps1 "Tokyo weather"
   ```

## 注意事项

- `web_fetch` 工具仍然可用，但某些网站（如 Yahoo）可能有访问限制
- 使用 SearXNG 搜索可以绕过直接访问限制
- 搜索结果通常包含多个来源，更可靠
