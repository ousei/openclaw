# 文件读取指南

## 错误：EISDIR: illegal operation on a directory, read

**原因：** 尝试读取一个目录而不是文件。

## 正确的文件路径格式

### ✅ 正确示例（文件）

```javascript
// 读取文件
read({ path: "C:\\Users\\wengzheng\\.openclaw\\workspace\\USER.md" })
read({ path: "C:\\Users\\wengzheng\\.openclaw\\workspace\\MEMORY.md" })
read({ path: "C:\\Users\\wengzheng\\.openclaw\\workspace\\TOOLS.md" })
read({ path: "C:\\Users\\wengzheng\\.openclaw\\workspace\\skills\\notion\\query-real-estate.ps1" })
```

### ❌ 错误示例（目录）

```javascript
// 错误：尝试读取目录
read({ path: "C:\\Users\\wengzheng\\.openclaw\\workspace" })  // ❌ 这是目录
read({ path: "C:\\Users\\wengzheng\\.openclaw\\workspace\\skills" })  // ❌ 这是目录
read({ path: "C:\\Users\\wengzheng\\.openclaw\\workspace\\skills\\notion" })  // ❌ 这是目录
```

## 如何区分文件和目录

### 使用 list_dir 工具查看目录内容

```javascript
// 列出目录内容
list_dir({ target_directory: "C:\\Users\\wengzheng\\.openclaw\\workspace" })
list_dir({ target_directory: "C:\\Users\\wengzheng\\.openclaw\\workspace\\skills\\notion" })
```

### 文件路径特征

- ✅ **文件**：路径以文件名和扩展名结尾（如 `.md`, `.ps1`, `.json`, `.txt`）
- ❌ **目录**：路径以目录名结尾，没有扩展名

## 常见文件路径

### 工作空间文件

```
C:\Users\wengzheng\.openclaw\workspace\USER.md
C:\Users\wengzheng\.openclaw\workspace\MEMORY.md
C:\Users\wengzheng\.openclaw\workspace\TOOLS.md
C:\Users\wengzheng\.openclaw\workspace\AGENTS.md
C:\Users\wengzheng\.openclaw\workspace\SOUL.md
C:\Users\wengzheng\.openclaw\workspace\POWERSHELL-RULES.md
```

### Notion 脚本文件

```
C:\Users\wengzheng\.openclaw\workspace\skills\notion\query-real-estate.ps1
C:\Users\wengzheng\.openclaw\workspace\skills\notion\query-notion-todos.ps1
C:\Users\wengzheng\.openclaw\workspace\skills\notion\run-query-real-estate.ps1
C:\Users\wengzheng\.openclaw\workspace\skills\notion\README.md
```

### 配置文件

```
C:\Users\wengzheng\.openclaw\openclaw.json
C:\Users\wengzheng\.openclaw\.env
```

## 使用 PowerShell 检查路径类型

```powershell
# 检查路径是文件还是目录
$path = "C:\Users\wengzheng\.openclaw\workspace\USER.md"
if (Test-Path $path) {
    $item = Get-Item $path
    if ($item.PSIsContainer) {
        Write-Host "这是目录"
    } else {
        Write-Host "这是文件"
    }
}
```

## 解决方案

如果遇到 `EISDIR` 错误：

1. **检查路径**：确保路径指向文件而不是目录
2. **使用 list_dir**：如果需要查看目录内容，使用 `list_dir` 工具
3. **添加文件扩展名**：如果路径缺少扩展名，可能是目录路径

## 工具使用建议

- **read 工具**：只能读取文件，不能读取目录
- **list_dir 工具**：用于查看目录内容
- **glob_file_search 工具**：用于搜索文件（支持通配符）
