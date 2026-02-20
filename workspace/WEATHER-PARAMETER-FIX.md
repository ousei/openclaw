# Weather Skill 参数错误修复

## ❌ 错误

Agent 使用了错误的参数名 `-Location`，但脚本期望的参数是 `-weatherLocation`。

**错误命令：**
```powershell
.\search_weather.ps1 -Location "東京"
```

**错误信息：**
```
パラメーター名 'Location' に一致するパラメーターが見つかりません。
Parameter 'Location' cannot be found.
```

## ✅ 正确的用法

### 方法 1: 位置参数（推荐）

```powershell
cd C:\Users\wengzheng\.openclaw\workspace\skills\weather; .\search_weather.ps1 "東京"
```

### 方法 2: 命名参数

```powershell
cd C:\Users\wengzheng\.openclaw\workspace\skills\weather; .\search_weather.ps1 -weatherLocation "東京"
```

## 📋 参数说明

脚本定义的参数：
- **参数名**: `-weatherLocation`（不是 `-Location`）
- **位置**: Position 0（可以省略参数名）
- **默认值**: "Tokyo"
- **类型**: string

## ✅ 已更新的文档

- `workspace/skills/weather/SKILL.md` - 添加了参数名说明
- `workspace/AGENTS.md` - 更新了示例，明确参数名
- `workspace/WEATHER-SKILL-USAGE.md` - 添加了参数错误示例

## 🎯 重要提醒

**Agent 必须使用：**
- ✅ `.\search_weather.ps1 "Location"` （位置参数）
- ✅ `.\search_weather.ps1 -weatherLocation "Location"` （命名参数）

**不要使用：**
- ❌ `.\search_weather.ps1 -Location "Location"` （错误的参数名）

---

**记住：参数名是 `-weatherLocation`，不是 `-Location`！**
