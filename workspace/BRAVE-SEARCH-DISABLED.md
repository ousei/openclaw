# Brave Search API 已禁用

## ✅ 已完成的更改

**日期**: 2026-02-03

### 1. 配置文件更新 (`openclaw.json`)

```json
{
  "tools": {
    "web": {
      "search": {
        "enabled": false,    // ✅ 已禁用
        "apiKey": null       // ✅ API Key 已移除
      },
      "fetch": {
        "enabled": true      // ✅ Web fetch 仍然可用
      }
    }
  }
}
```

### 2. 文档更新

- ✅ `TOOLS.md` - 更新搜索方案说明
- ✅ `.cursor/rules/web-search-lang-codes.mdc` - 标记为已弃用

## 🔄 替代方案

### 当前使用：本地 SearXNG

**部署状态**: ✅ 已部署并运行

**访问地址**:
- Web 界面: http://localhost:18888
- API 端点: http://localhost:18888/search?q=QUERY&format=json

**优势**:
- ✅ 无速率限制
- ✅ 完全免费
- ✅ 隐私保护
- ✅ 无 API 费用

### 可用的搜索方式

1. **SearXNG Web 界面**
   - 直接访问: http://localhost:18888
   - 支持所有搜索功能

2. **local-search Skill**
   - 位置: `workspace/skills/local-search/`
   - 使用 SearXNG API

3. **weather Skill**
   - 位置: `workspace/skills/weather/`
   - 使用 SearXNG 搜索天气

## 📝 注意事项

- ⚠️ OpenClaw 的内置 `web_search` 工具已禁用
- ✅ 仍可使用 `web_fetch` 工具获取网页内容
- ✅ 通过 Skills 可以使用本地搜索功能

## 🔧 如需重新启用 Brave Search API

如果将来需要重新启用，可以：

1. 编辑 `openclaw.json`:
   ```json
   {
     "tools": {
       "web": {
         "search": {
           "enabled": true,
           "apiKey": "YOUR_API_KEY"
         }
       }
     }
   }
   ```

2. 重启 OpenClaw 网关

## 📚 相关文档

- SearXNG 部署: `workspace/skills/local-search/LOCAL-SEARCH-SETUP.md`
- SearXNG 状态: `C:\searxng\DEPLOYMENT-STATUS.md`
- 本地搜索 Skill: `workspace/skills/local-search/SKILL.md`
