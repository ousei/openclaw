# PowerShell 命令关键字必须使用英文

⚠️ **这是强制规则！PowerShell 命令关键字不能使用中文！**

## 问题

代理在生成 PowerShell 命令时错误地使用了中文关键字，导致命令失败。

**错误示例：**
```powershell
Get-ChildItem -Path "C:\Users\wengzheng\Downloads" | 排序对象 LastWriteTime  # ❌ 错误！
```

**正确示例：**
```powershell
Get-ChildItem -Path "C:\Users\wengzheng\Downloads" | Sort-Object LastWriteTime  # ✅ 正确
```

## 规则

### PowerShell 命令关键字必须是英文

**只有以下内容可以使用中文：**
- ✅ 字符串值（文件路径中的中文）
- ✅ 变量值中的中文
- ✅ 注释中的中文

**以下内容必须使用英文：**
- ❌ Cmdlet 名称（如 `Sort-Object`, `Format-Table`）
- ❌ 参数名称（如 `-Path`, `-Recurse`）
- ❌ 操作符（如 `|`, `;`, `-and`, `-or`）
- ❌ 关键字（如 `if`, `foreach`, `try`, `catch`）

## 常用命令对照表

| 中文（错误） | 英文（正确） |
|------------|------------|
| 排序对象 | `Sort-Object` |
| 格式化表格 | `Format-Table` |
| 筛选对象 | `Where-Object` |
| 选择对象 | `Select-Object` |
| 获取子项 | `Get-ChildItem` |
| 输出文件 | `Out-File` |
| 测试路径 | `Test-Path` |
| 设置位置 | `Set-Location` |
| 获取内容 | `Get-Content` |
| 写入主机 | `Write-Host` |

## 正确示例

### 示例 1：列出文件并排序

```powershell
# ✅ 正确
Get-ChildItem -Path "C:\Users\wengzheng\Downloads" | Sort-Object LastWriteTime | Format-Table Name, Length, LastWriteTime

# ❌ 错误
Get-ChildItem -Path "C:\Users\wengzheng\Downloads" | 排序对象 LastWriteTime | 格式化表格 Name, Length, LastWriteTime
```

### 示例 2：筛选文件

```powershell
# ✅ 正确
Get-ChildItem -Path "C:\Users\wengzheng\Downloads" | Where-Object { $_.Extension -eq ".pdf" } | Select-Object Name, Length

# ❌ 错误
Get-ChildItem -Path "C:\Users\wengzheng\Downloads" | 筛选对象 { $_.Extension -eq ".pdf" } | 选择对象 Name, Length
```

### 示例 3：条件判断

```powershell
# ✅ 正确
if (Test-Path "C:\Users\wengzheng\Downloads\file.txt") {
    Get-Content "C:\Users\wengzheng\Downloads\file.txt"
}

# ❌ 错误
如果 (测试路径 "C:\Users\wengzheng\Downloads\file.txt") {
    获取内容 "C:\Users\wengzheng\Downloads\file.txt"
}
```

## 检查清单

在执行 PowerShell 命令前，检查：
1. ✅ 所有 cmdlet 名称都是英文
2. ✅ 所有参数名称都是英文
3. ✅ 所有操作符都是英文
4. ✅ 只有字符串值可以使用中文

## 重要提醒

**即使回复用户时使用中文，PowerShell 命令本身必须使用英文关键字！**

- 回复用户：可以使用中文
- PowerShell 命令：必须使用英文关键字
- 文件路径：可以包含中文（作为字符串值）
