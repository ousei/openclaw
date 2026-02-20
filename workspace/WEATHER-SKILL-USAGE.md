# Weather Skill 使用指南（给 AI Agent）

## ⚠️ 重要：当用户请求天气信息时

**你必须使用 `exec` 工具调用 PowerShell 脚本来获取天气信息，而不是使用 `web_fetch` 工具！**

## 正确的调用方式

### ⚠️ 重要：PowerShell 语法和参数

**🚨 绝对不要使用 `&&` 运算符！PowerShell 不支持它！**

**🚨 参数名是 `-weatherLocation`，不是 `-Location`！**

### 方法 1: 使用 exec 工具（推荐）

**✅ 正确（使用分号 `;` 和位置参数）：**
```json
{
  "tool": "exec",
  "command": "cd C:\\Users\\wengzheng\\.openclaw\\workspace\\skills\\weather; .\\search_weather.ps1 \"Tokyo\"",
  "pty": false
}
```

**✅ 正确（使用命名参数 `-weatherLocation`）：**
```json
{
  "tool": "exec",
  "command": "cd C:\\Users\\wengzheng\\.openclaw\\workspace\\skills\\weather; .\\search_weather.ps1 -weatherLocation \"Tokyo\"",
  "pty": false
}
```

**❌ 错误（使用 `&&` 会导致失败）：**
```json
{
  "tool": "exec",
  "command": "cd C:\\Users\\wengzheng\\.openclaw\\workspace\\skills\\weather && .\\search_weather.ps1 \"Tokyo\"",
  "pty": false
}
```

**❌ 错误（参数名错误，应该是 `-weatherLocation` 不是 `-Location`）：**
```json
{
  "tool": "exec",
  "command": "cd C:\\Users\\wengzheng\\.openclaw\\workspace\\skills\\weather; .\\search_weather.ps1 -Location \"Tokyo\"",
  "pty": false
}
```

### 方法 2: 直接 PowerShell 命令

```powershell
cd C:\Users\wengzheng\.openclaw\workspace\skills\weather; .\search_weather.ps1 "Tokyo"
```

## 脚本功能

`search_weather.ps1` 脚本会：
1. ✅ 使用 SearXNG 搜索天气信息（`http://localhost:18888`）
2. ✅ 从 HTML 页面提取搜索结果（绕过 bot detection）
3. ✅ 返回 JSON 格式的结果
4. ✅ **不创建任何临时文件**

## 输出格式

脚本返回 JSON 数组：

```json
[
    {
        "Title": "天气网站标题",
        "URL": "https://weather.example.com",
        "Snippet": "天气描述..."
    }
]
```

## 为什么不用 web_fetch？

- ❌ `web_fetch` 工具已禁用（`web.fetch.enabled = false`）
- ❌ 直接访问特定 URL 经常失败（DNS 错误、404、403）
- ✅ SearXNG 搜索更可靠，返回多个来源的结果
- ✅ 不需要知道确切的 URL

## 示例对话

**用户**: "看一下现在的天气" 或 "What's the weather in Tokyo?"

**你的操作**:
1. 识别用户想要天气信息
2. 使用 `exec` 工具调用 `search_weather.ps1` 脚本
3. 解析返回的 JSON 结果
4. 向用户展示天气信息

**示例命令**:
```powershell
cd C:\Users\wengzheng\.openclaw\workspace\skills\weather; .\search_weather.ps1 "Tokyo"
```

## 常见错误

### ❌ 错误 1: 说"我没有访问实时网页的工具"
**正确做法**: 你有 weather skill！使用 `exec` 工具调用脚本即可。

### ❌ 错误 2: 尝试使用 `web_fetch` 工具
**正确做法**: `web_fetch` 已禁用，使用 SearXNG 搜索脚本。

### ❌ 错误 3: 创建临时文件
**正确做法**: 脚本直接返回 JSON，不需要临时文件。

## 相关文件

- `workspace/skills/weather/search_weather.ps1` - 天气搜索脚本
- `workspace/skills/weather/SKILL.md` - Weather skill 文档
- `.cursor/rules/use-searxng-for-web-data.mdc` - SearXNG 使用规则

## 快速参考

**当用户请求天气时，执行：**
```powershell
cd C:\Users\wengzheng\.openclaw\workspace\skills\weather; .\search_weather.ps1 "用户指定的地点"
```

**如果用户没有指定地点，默认使用 "Tokyo"**：
```powershell
cd C:\Users\wengzheng\.openclaw\workspace\skills\weather; .\search_weather.ps1 "Tokyo"
```
