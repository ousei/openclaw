# NAS 路径别名使用指南

## 问题

OpenClaw 在处理 `\\nas` 路径时可能识别错误，导致：
- `\\nas` 被识别为 `\as`
- 路径解析失败
- 命令执行错误

## 解决方案：使用 Nas 变量代替 \\nas

### 方法 1: 在 PowerShell 脚本中使用变量（推荐）

```powershell
# 定义 NAS 路径变量（使用 Nas 作为变量名）
$Nas = "\\nas"
$NasHomes = "\\nas\homes"
$NasHomesWeng = "\\nas\homes\weng"

# 使用变量访问路径（避免 OpenClaw 识别错误）
Get-ChildItem "$NasHomesWeng\履歴書"
```

### 方法 2: 使用路径转换函数

```powershell
# 导入路径映射模块
. C:\Users\wengzheng\.openclaw\workspace\skills\nas\nas-path-mapper.ps1

# 将 Nas 路径转换为实际路径
$path = Convert-NasPath "Nas\homes\weng\履歴書"
Get-ChildItem $path
```

### 方法 3: 使用包装脚本

```powershell
# 运行使用 Nas 别名的脚本
C:\Users\wengzheng\.openclaw\workspace\skills\nas\use-nas-alias.ps1
```

## 标准 NAS 路径变量定义

在所有 PowerShell 脚本中，建议使用以下变量定义：

```powershell
# NAS 路径变量（避免 OpenClaw 识别错误）
$Nas = "\\nas"
$NasHomes = "\\nas\homes"
$NasHomesWeng = "\\nas\homes\weng"
```

## 使用示例

### 示例 1: 列出目录内容

```powershell
# 定义变量
$NasHomesWeng = "\\nas\homes\weng"

# 设置编码
[Console]::OutputEncoding = [System.Text.Encoding]::UTF8
chcp 65001 | Out-Null

# 连接 NAS
net use $NasHomes /user:nas\weng 19801502 /persistent:yes

# 访问路径
Get-ChildItem "$NasHomesWeng\履歴書"
```

### 示例 2: 访问文件

```powershell
$NasHomesWeng = "\\nas\homes\weng"
$filePath = "$NasHomesWeng\履歴書\2025-04-10_履歴書.pdf"
Get-Item $filePath
```

### 示例 3: 在脚本中使用

```powershell
# 脚本开头定义
$Nas = "\\nas"
$NasHomes = "\\nas\homes"
$NasHomesWeng = "\\nas\homes\weng"

# 在脚本中使用变量
if (Test-Path "$NasHomesWeng\履歴書") {
    Get-ChildItem "$NasHomesWeng\履歴書"
}
```

## 规则

**在生成 PowerShell 命令时：**
1. ✅ **使用变量**：`$NasHomesWeng` 代替 `\\nas\homes\weng`
2. ✅ **先定义变量**：在脚本开头定义 NAS 路径变量
3. ❌ **避免直接使用**：不要在命令中直接写 `\\nas`（可能被识别错误）

## 快速参考

```powershell
# 标准定义（复制到脚本开头）
$Nas = "\\nas"
$NasHomes = "\\nas\homes"
$NasHomesWeng = "\\nas\homes\weng"

# 使用
Get-ChildItem "$NasHomesWeng\履歴書"
```
