# SearXNG 集成总结

## ✅ 已完成的工作

### 1. 更新了所有搜索脚本使用 HTML 提取方式

**已更新的脚本：**
- ✅ `workspace/skills/local-search/scripts/search.ps1` - 主搜索脚本
- ✅ `workspace/skills/local-search/scripts/search_from_html.ps1` - HTML 提取实现
- ✅ `workspace/skills/weather/search_weather.ps1` - 天气搜索（已使用 HTML 提取）

**新增的工具：**
- ✅ `workspace/skills/utilities/searxng-search.ps1` - 通用搜索函数，可被其他脚本引用

### 2. 工作原理

所有脚本现在都：
1. **使用 SearXNG HTML 页面** - 绕过 bot detection（API 返回 403）
2. **提取搜索结果** - 使用正则表达式从 HTML 提取链接和标题
3. **返回 JSON 格式** - 不创建临时文件，直接返回结构化数据
4. **过滤内部链接** - 自动过滤掉 SearXNG 自己的链接

### 3. 统一的使用方式

#### 方法 1: 直接调用脚本
```powershell
cd C:\Users\wengzheng\.openclaw\workspace\skills\local-search\scripts
.\search.ps1 "your query"
```

#### 方法 2: 在其他脚本中使用通用函数
```powershell
. C:\Users\wengzheng\.openclaw\workspace\skills\utilities\searxng-search.ps1
$results = Search-SearXNG "your query"
```

#### 方法 3: 调用特定技能的搜索脚本
```powershell
# 天气搜索
cd C:\Users\wengzheng\.openclaw\workspace\skills\weather
.\search_weather.ps1 "Tokyo"
```

## 📋 输出格式

所有脚本返回统一的 JSON 格式：

```json
[
    {
        "Title": "搜索结果标题",
        "URL": "https://example.com",
        "Snippet": "结果摘要（如果有）"
    }
]
```

## 🎯 适用场景

**所有需要网页数据的场景都应该使用 SearXNG：**

- ✅ 天气信息搜索
- ✅ 技术文档搜索
- ✅ 新闻搜索
- ✅ 任何需要网页搜索的功能
- ✅ 替代已禁用的 Brave Search API

## 📝 重要规则

### ✅ 应该做的
- 使用 SearXNG HTML 提取方式获取网页数据
- 返回 JSON 格式数据
- 不创建临时文件
- 使用本地 SearXNG 实例 (`http://localhost:18888`)

### ❌ 不应该做的
- ❌ 创建临时文件来存储搜索结果
- ❌ 尝试直接调用 SearXNG API（会返回 403）
- ❌ 使用其他外部搜索 API（如已禁用的 Brave Search API）

## 🔧 技术实现

### HTML 提取流程

1. **获取 HTML**: 使用 `curl.exe` 获取 SearXNG 搜索页面
   ```powershell
   curl.exe -s -L -H "User-Agent: Mozilla/5.0" "$SearchUrl"
   ```

2. **提取链接**: 使用正则表达式匹配搜索结果
   ```powershell
   [regex]::Matches($htmlContent, '<h3[^>]*class="[^"]*result[^"]*"[^>]*><a[^>]*href="([^"]+)"[^>]*>([^<]+)</a></h3>')
   ```

3. **提取摘要**: 从链接附近提取内容摘要
   ```powershell
   [regex]::Match($searchArea, '<p[^>]*class="[^"]*content[^"]*"[^>]*>([^<]{50,300})</p>')
   ```

4. **过滤结果**: 移除 SearXNG 内部链接
   ```powershell
   if ($url -match "github.com/searxng|searx.space|searxng.org") { continue }
   ```

## 📚 相关文档

- `workspace/SEARXNG-USAGE-GUIDE.md` - 详细使用指南
- `workspace/skills/local-search/SKILL.md` - Local Search 技能文档
- `workspace/skills/weather/SKILL.md` - Weather 技能文档

## 🚀 下一步

当创建新技能需要网页数据时：

1. **引用通用函数**:
   ```powershell
   . C:\Users\wengzheng\.openclaw\workspace\skills\utilities\searxng-search.ps1
   $results = Search-SearXNG "your query"
   ```

2. **或调用搜索脚本**:
   ```powershell
   $results = & "C:\Users\wengzheng\.openclaw\workspace\skills\local-search\scripts\search.ps1" "your query" | ConvertFrom-Json
   ```

3. **处理结果**:
   ```powershell
   foreach ($result in $results) {
       # 使用 $result.Title, $result.URL, $result.Snippet
   }
   ```

## ✨ 优势

- ✅ **无速率限制** - 本地 SearXNG 实例
- ✅ **隐私保护** - 不通过商业 API
- ✅ **无成本** - 完全免费
- ✅ **统一接口** - 所有技能使用相同方式
- ✅ **无临时文件** - 直接返回 JSON 数据
