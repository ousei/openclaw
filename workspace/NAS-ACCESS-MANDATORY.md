# NAS 访问强制规则

⚠️ **这是强制规则！代理必须严格遵守！**

## 🚨 紧急：代理必须阅读此文件！

**在访问 NAS 之前，必须：**
1. 阅读此文件
2. 使用变量代替直接路径
3. 遵循标准模板

## 🚨 绝对禁止：直接使用 \\nas

❌ **永远不要在命令中直接写 `\\nas`！OpenClaw 会将其识别为 `\as`！**

**错误示例（会导致识别错误）：**
```powershell
Get-ChildItem "\\nas\homes\weng\履歴書"  # ❌ 错误！可能被识别为 \as
net use \\nas\homes /user:nas\weng 19801502  # ❌ 错误！
Test-Path "\\nas\homes\weng"  # ❌ 错误！
```

## ✅ 强制要求：使用变量

**在所有 PowerShell 命令中，必须先定义变量，然后使用变量！**

### 标准变量定义（必须使用）

```powershell
# 在所有脚本开头或命令开始前，必须先定义这些变量
$Nas = "\\nas"
$NasHomes = "\\nas\homes"
$NasHomesWeng = "\\nas\homes\weng"
```

### 正确示例（使用变量）

```powershell
# ✅ 正确：先定义变量
$Nas = "\\nas"
$NasHomes = "\\nas\homes"
$NasHomesWeng = "\\nas\homes\weng"

# ✅ 正确：使用变量访问
Get-ChildItem "$NasHomesWeng\履歴書"
net use $NasHomes /user:nas\weng 19801502 /persistent:yes
Test-Path "$NasHomesWeng\履歴書"
```

## 📋 标准 NAS 访问模板

**复制以下模板到所有 NAS 访问命令的开头：**

```powershell
# ===== NAS 路径变量定义（必须）=====
$Nas = "\\nas"
$NasHomes = "\\nas\homes"
$NasHomesWeng = "\\nas\homes\weng"

# ===== 设置 UTF-8 编码（访问日文路径时必需）=====
[Console]::OutputEncoding = [System.Text.Encoding]::UTF8
$OutputEncoding = [System.Text.Encoding]::UTF8
chcp 65001 | Out-Null

# ===== 连接 NAS =====
net use * /delete /yes 2>$null | Out-Null
net use $NasHomes /user:nas\weng 19801502 /persistent:yes 2>&1 | Out-Null
Start-Sleep -Seconds 2

# ===== 访问路径（使用变量）=====
$targetPath = "$NasHomesWeng\履歴書"
if (Test-Path $targetPath) {
    Get-ChildItem $targetPath
}
```

## 🎯 快速参考

### 列出 NAS 文件

```powershell
# 定义变量
$NasHomesWeng = "\\nas\homes\weng"

# 使用变量
Get-ChildItem "$NasHomesWeng\履歴書"
```

### 连接 NAS

```powershell
# 定义变量
$NasHomes = "\\nas\homes"

# 使用变量
net use $NasHomes /user:nas\weng 19801502 /persistent:yes
```

### 测试路径

```powershell
# 定义变量
$NasHomesWeng = "\\nas\homes\weng"

# 使用变量
Test-Path "$NasHomesWeng\履歴書"
```

## ⚠️ 检查清单

在执行任何 NAS 相关命令前，检查：

1. ✅ **是否定义了 NAS 路径变量？**
   - `$Nas = "\\nas"`
   - `$NasHomes = "\\nas\homes"`
   - `$NasHomesWeng = "\\nas\homes\weng"`

2. ✅ **是否使用变量而不是直接路径？**
   - ✅ `Get-ChildItem "$NasHomesWeng\履歴書"`
   - ❌ `Get-ChildItem "\\nas\homes\weng\履歴書"`

3. ✅ **是否设置了 UTF-8 编码？（访问日文路径时）**
   - `[Console]::OutputEncoding = [System.Text.Encoding]::UTF8`
   - `chcp 65001 | Out-Null`

4. ✅ **是否先连接了 NAS 共享？**
   - `net use $NasHomes /user:nas\weng 19801502 /persistent:yes`

## 🚫 常见错误

### 错误 1: 直接使用 \\nas

```powershell
# ❌ 错误
Get-ChildItem "\\nas\homes\weng\履歴書"

# ✅ 正确
$NasHomesWeng = "\\nas\homes\weng"
Get-ChildItem "$NasHomesWeng\履歴書"
```

### 错误 2: 在变量定义前使用路径

```powershell
# ❌ 错误
Get-ChildItem "\\nas\homes\weng\履歴書"
$NasHomesWeng = "\\nas\homes\weng"

# ✅ 正确
$NasHomesWeng = "\\nas\homes\weng"
Get-ChildItem "$NasHomesWeng\履歴書"
```

### 错误 3: 忘记使用变量

```powershell
# ❌ 错误：定义了变量但没使用
$NasHomesWeng = "\\nas\homes\weng"
Get-ChildItem "\\nas\homes\weng\履歴書"  # 还是直接用了路径

# ✅ 正确：使用变量
$NasHomesWeng = "\\nas\homes\weng"
Get-ChildItem "$NasHomesWeng\履歴書"
```

## 📚 参考文档

- `NAS-PATH-ALIAS.md` - NAS 路径别名详细说明
- `workspace\skills\nas\get-nas-files.ps1` - **最简单可靠的脚本（推荐使用）**
- `workspace\skills\nas\list-files-simple.ps1` - 示例脚本（使用变量）
- `workspace\skills\nas\access-nas-template.ps1` - 标准模板脚本
- `workspace\skills\nas\use-nas-alias.ps1` - 使用别名的示例

## 🎯 最简单的方法（推荐）

**直接运行脚本：**
```powershell
C:\Users\wengzheng\.openclaw\workspace\skills\nas\get-nas-files.ps1
```

这个脚本已经：
- ✅ 定义了所有必需的变量
- ✅ 设置了 UTF-8 编码
- ✅ 连接了 NAS
- ✅ 使用变量访问路径
- ✅ 避免了所有识别错误

---

**🚨 记住：永远使用变量，永远不要直接写 `\\nas`！这是强制规则！**
