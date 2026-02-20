# 错误预防检查清单

## 🚨 在执行任何命令前必须检查

### 1. PowerShell 语法检查

**❌ 禁止使用 `&&` 运算符**

**检查步骤：**
1. 查看命令中是否包含 `&&`
2. 如果发现，立即替换为 `;` 或换行
3. 验证命令使用 `;` 分隔

**示例：**
```powershell
# ❌ 错误
cd path && script.ps1

# ✅ 正确
cd path; script.ps1
```

### 2. Weather Skill 参数检查

**❌ 禁止使用 `-Location` 参数**

**检查步骤：**
1. 如果调用 `search_weather.ps1`，检查参数名
2. 使用位置参数（推荐）或 `-weatherLocation`
3. 不要使用 `-Location`

**示例：**
```powershell
# ❌ 错误
.\search_weather.ps1 -Location "Tokyo"

# ✅ 正确（方法1：位置参数）
.\search_weather.ps1 "Tokyo"

# ✅ 正确（方法2：命名参数）
.\search_weather.ps1 -weatherLocation "Tokyo"
```

### 3. Web Fetch 工具检查

**❌ 禁止使用 `web_fetch` 工具**

**检查步骤：**
1. 如果需要网页数据，使用 SearXNG 搜索
2. 使用 `weather` skill 或 `local-search` skill
3. 不要尝试使用 `web_fetch` 工具

**替代方案：**
```powershell
# ✅ 正确：使用 weather skill
cd C:\Users\wengzheng\.openclaw\workspace\skills\weather; .\search_weather.ps1 "Tokyo"

# ✅ 正确：使用 local-search skill
cd C:\Users\wengzheng\.openclaw\workspace\skills\local-search\scripts; .\search.ps1 "query"
```

### 4. NAS 路径检查

**❌ 禁止直接使用 `\\nas` 路径**

**检查步骤：**
1. 如果涉及 NAS 路径，使用变量
2. 先定义 `$Nas = "\\nas"` 或类似变量
3. 使用变量访问路径

**示例：**
```powershell
# ❌ 错误
Get-ChildItem "\\nas\homes\weng"

# ✅ 正确
$NasHomes = "\\nas\homes"
Get-ChildItem "$NasHomes\weng"
```

### 5. PowerShell 命令关键字检查

**❌ 禁止使用中文命令关键字**

**检查步骤：**
1. 确保所有 PowerShell cmdlet 使用英文
2. 只有字符串值（路径、变量值）可以使用中文
3. 命令关键字必须是英文

**示例：**
```powershell
# ❌ 错误
Get-ChildItem | 排序对象 LastWriteTime

# ✅ 正确
Get-ChildItem | Sort-Object LastWriteTime
```

## 📋 执行前检查清单

在执行任何 `exec` 工具调用前，按顺序检查：

- [ ] **步骤 1**: 检查命令中是否包含 `&&`
  - 如果发现，替换为 `;`
  
- [ ] **步骤 2**: 如果调用 weather skill，检查参数名
  - 使用位置参数或 `-weatherLocation`
  - 不要使用 `-Location`
  
- [ ] **步骤 3**: 如果需要网页数据，使用 SearXNG
  - 不要使用 `web_fetch` 工具
  - 使用相应的 skill 脚本
  
- [ ] **步骤 4**: 如果涉及 NAS 路径，使用变量
  - 不要直接写 `\\nas`
  - 先定义变量再使用
  
- [ ] **步骤 5**: 检查 PowerShell 命令关键字
  - 确保使用英文关键字
  - 只有字符串值可以使用中文

## 🎯 常见错误快速参考

| 错误类型 | 错误示例 | 正确示例 |
|---------|---------|---------|
| `&&` 运算符 | `cd path && script` | `cd path; script` |
| Weather 参数 | `-Location "Tokyo"` | `"Tokyo"` 或 `-weatherLocation "Tokyo"` |
| Web Fetch | 使用 `web_fetch` 工具 | 使用 SearXNG skill |
| NAS 路径 | `"\\nas\homes"` | `$NasHomes = "\\nas\homes"; "$NasHomes\weng"` |
| 中文关键字 | `排序对象` | `Sort-Object` |

## 🔧 自动验证脚本

在执行命令前，可以运行验证：

```powershell
# 检查命令中是否包含 &&
if ($command -match '&&') {
    Write-Host "ERROR: Command contains && operator!" -ForegroundColor Red
    Write-Host "Replace && with ;" -ForegroundColor Yellow
}

# 检查 weather skill 参数
if ($command -match 'search_weather\.ps1.*-Location') {
    Write-Host "ERROR: Wrong parameter name -Location!" -ForegroundColor Red
    Write-Host "Use -weatherLocation or positional parameter" -ForegroundColor Yellow
}
```

## 📚 相关文档

- `CRITICAL-POWERSHELL-RULE.md` - PowerShell 关键规则
- `POWERSHELL-RULES.md` - 完整 PowerShell 语法指南
- `WEATHER-SKILL-USAGE.md` - Weather skill 使用指南
- `WEATHER-PARAMETER-FIX.md` - Weather 参数修复
- `NAS-ACCESS-MANDATORY.md` - NAS 访问规则

---

**记住：在执行任何命令前，先检查这个清单！**
