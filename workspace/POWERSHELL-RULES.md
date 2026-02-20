# PowerShell 语法规则 - 强制遵守

⚠️ **这是强制规则，代理必须严格遵守！**

## 🚨 紧急提醒

**在执行任何 PowerShell 命令前，必须检查：**
1. ❌ **绝对不要使用 `&&`**
2. ✅ **使用 `;` 或换行分隔命令**
3. ✅ **使用正确的路径格式（`C:\path` 或 `\\server\share`）**
4. ✅ **不要使用 `.\\` 前缀**
5. ⚠️ **PowerShell 命令关键字必须使用英文！不能使用中文！**
6. ⚠️ **NAS 路径问题：OpenClaw 可能将 `\\nas` 识别为 `\as`！必须使用变量代替！**

## 🚫 绝对禁止：使用中文命令关键字

❌ **严重错误：PowerShell 命令关键字必须使用英文！**

**错误示例（会导致命令失败）：**
```powershell
Get-ChildItem -Path "C:\Users\wengzheng\Downloads" | 排序对象 LastWriteTime  # ❌ 错误！
Get-ChildItem -Path "C:\Users\wengzheng\Downloads" | 格式化表格 Name, Length  # ❌ 错误！
```

✅ **正确示例（必须使用英文关键字）：**
```powershell
Get-ChildItem -Path "C:\Users\wengzheng\Downloads" | Sort-Object LastWriteTime  # ✅ 正确
Get-ChildItem -Path "C:\Users\wengzheng\Downloads" | Format-Table Name, Length  # ✅ 正确
```

**重要规则：**
- PowerShell 的所有命令、cmdlet、参数名必须使用英文
- 只有字符串值（如文件路径、变量值）可以使用中文
- 命令关键字：`Sort-Object`, `Format-Table`, `Where-Object`, `Select-Object` 等必须是英文

## 🚫 绝对禁止使用的语法

### 1. `&&` 运算符 - **完全禁止**

❌ **永远不要使用 `&&`！PowerShell 不支持此运算符！**

**如果看到任何包含 `&&` 的命令，必须立即替换为 `;` 或使用换行！**

**错误示例（会导致解析错误）：**
```powershell
cd C:\path && dir
test-path "file.ps1" && .\file.ps1
python script.py && cat output.json
```

✅ **正确替代方案：**

**方案 1：使用分号 `;`**
```powershell
cd C:\path; dir
test-path "file.ps1"; if ($?) { .\file.ps1 }
python script.py; if ($LASTEXITCODE -eq 0) { cat output.json }
```

**方案 2：使用换行分隔**
```powershell
cd C:\path
dir
```

**方案 3：使用条件判断**
```powershell
if (Test-Path "file.ps1") {
    .\file.ps1
}
```

## ✅ 正确的命令连接方式

### 多个命令连续执行

```powershell
# ✅ 正确：使用分号
$env:NOTION_API_KEY = "ntn_xxx"; cd C:\path; .\script.ps1

# ✅ 正确：使用换行
$env:NOTION_API_KEY = "ntn_xxx"
cd C:\path
.\script.ps1

# ✅ 正确：使用条件判断
if (Test-Path "script.ps1") {
    cd C:\path
    .\script.ps1
}
```

### 检查命令成功后再执行

```powershell
# ✅ 正确：检查退出代码
.\script1.ps1
if ($LASTEXITCODE -eq 0) {
    .\script2.ps1
}

# ✅ 正确：使用 Test-Path
if (Test-Path "file.ps1") {
    .\file.ps1
}

# ✅ 正确：使用 try-catch
try {
    .\script.ps1
    .\next-script.ps1
} catch {
    Write-Host "Error: $_" -ForegroundColor Red
}
```

## 📋 常见场景的正确写法

### 场景 1：切换目录并执行脚本

❌ **错误：**
```powershell
cd C:\Users\wengzheng\.openclaw\workspace\skills\notion && .\query-real-estate.ps1
```

✅ **正确：**
```powershell
cd C:\Users\wengzheng\.openclaw\workspace\skills\notion; .\query-real-estate.ps1
```

### 场景 2：检查文件存在后执行

❌ **错误：**
```powershell
test-path "script.ps1" && .\script.ps1
```

✅ **正确：**
```powershell
if (Test-Path "script.ps1") { .\script.ps1 }
```

### 场景 3：设置环境变量并执行

❌ **错误：**
```powershell
$env:KEY = "value" && .\script.ps1
```

✅ **正确：**
```powershell
$env:KEY = "value"; .\script.ps1
```

### 场景 4：执行多个命令

❌ **错误：**
```powershell
.\script1.ps1 && .\script2.ps1 && echo "Done"
```

✅ **正确：**
```powershell
.\script1.ps1; .\script2.ps1; Write-Host "Done"
```

## 🔍 如何验证命令

在执行命令前，检查是否包含 `&&`：

```powershell
# 如果命令中包含 &&，必须替换为 ; 或换行
# 错误命令示例：
# cd path && dir
# 正确命令：
# cd path; dir
```

## ⚠️ 重要提醒

1. **所有通过 `exec` 工具执行的 PowerShell 命令都必须遵守此规则**
2. **如果看到 `&&`，必须立即替换为 `;` 或使用条件判断**
3. **这是语法错误，会导致命令完全无法执行**
4. **参考 `TOOLS.md` 中的 PowerShell 语法说明部分**

## 9. Test-NetConnection 的正确用法

⚠️ **重要：Test-NetConnection 在不同 PowerShell 版本中行为不同**

❌ **错误用法（可能导致属性不存在错误）：**
```powershell
Test-NetConnection -ComputerName nas -Port 445 -InformationLevel Quiet | Select -ExpandProperty TcpTestSucceeded
```

✅ **正确用法（兼容不同版本）：**

**方法 1: 直接使用布尔返回值（PowerShell 5.1+）**
```powershell
$result = Test-NetConnection -ComputerName nas -Port 445 -InformationLevel Quiet -WarningAction SilentlyContinue
if ($result -is [bool]) {
    # PowerShell 5.1 返回布尔值
    if ($result) { Write-Host "端口可访问" }
} elseif ($result.PSObject.Properties.Name -contains 'TcpTestSucceeded') {
    # 检查属性是否存在
    if ($result.TcpTestSucceeded) { Write-Host "端口可访问" }
}
```

**方法 2: 使用 Test-Path（最可靠，推荐）**
```powershell
# 测试 UNC 路径，比端口测试更可靠
if (Test-Path "\\nas\homes\weng") {
    Write-Host "NAS 可访问"
}
```

**方法 3: 使用 net use（检查已保存的连接）**
```powershell
$connections = net use 2>$null | Select-String "\\\\nas"
if ($connections) {
    Write-Host "找到 NAS 连接"
}
```

**推荐：** 优先使用 `Test-Path` 测试 UNC 路径，而不是使用 `Test-NetConnection` 测试端口。

## 10. NAS 路径别名（避免 OpenClaw 识别错误）

⚠️ **重要：OpenClaw 可能将 `\\nas` 识别为 `\as`**

**问题：** 在 PowerShell 命令中直接使用 `\\nas` 可能导致 OpenClaw 识别错误

**解决方案：使用变量代替直接路径**

❌ **错误（可能导致识别错误）：**
```powershell
Get-ChildItem "\\nas\homes\weng\履歴書"
net use \\nas\homes /user:nas\weng 19801502
```

✅ **正确（使用变量）：**
```powershell
# 在脚本开头定义变量
$Nas = "\\nas"
$NasHomes = "\\nas\homes"
$NasHomesWeng = "\\nas\homes\weng"

# 使用变量访问路径
Get-ChildItem "$NasHomesWeng\履歴書"
net use $NasHomes /user:nas\weng 19801502
```

**标准 NAS 路径变量定义（复制到脚本开头）：**
```powershell
$Nas = "\\nas"
$NasHomes = "\\nas\homes"
$NasHomesWeng = "\\nas\homes\weng"
```

**规则：**
- ✅ 在 PowerShell 脚本中，始终先定义 NAS 路径变量
- ✅ 使用变量访问 NAS 路径，而不是直接写 `\\nas`
- ❌ 避免在命令中直接使用 `\\nas`（可能被识别错误）

## 📚 参考文档

- `TOOLS.md` - PowerShell 语法重要说明部分
- `workspace\skills\notion\README.md` - PowerShell 语法注意部分
- `workspace\skills\nas\test-nas-connection-safe.ps1` - 安全的 NAS 连接测试脚本
- `NAS-PATH-ALIAS.md` - NAS 路径别名使用指南

---

**记住：**
1. PowerShell 不支持 `&&`，永远使用 `;` 或换行！
2. PowerShell 命令关键字必须使用英文！
3. NAS 路径必须使用变量，不要直接写 `\\nas`！
