# Notion API 查询脚本使用指南

## ⚠️ PowerShell 语法注意

**PowerShell 不支持 `&&` 运算符！**

❌ **错误写法：**
```powershell
cd C:\Users\wengzheng\.openclaw\workspace\skills\notion && dir
```

✅ **正确写法（使用分号）：**
```powershell
cd C:\Users\wengzheng\.openclaw\workspace\skills\notion; dir
```

✅ **或者分两行：**
```powershell
cd C:\Users\wengzheng\.openclaw\workspace\skills\notion
dir
```

## 快速开始

### 1. 设置环境变量（如果还没设置）

```powershell
$env:NOTION_API_KEY = "ntn_xxx..."
```

### 2. 切换到脚本目录

```powershell
cd C:\Users\wengzheng\.openclaw\workspace\skills\notion
```

### 3. 运行脚本

**查询未着手的任务：**
```powershell
.\query-notion-todos.ps1
```

**查询所有任务（按状态分组）：**
```powershell
.\query-all-tasks.ps1
```

**搜索所有数据库：**
```powershell
.\search-databases.ps1
```

## 一行命令（推荐）

如果你想在一行内完成所有操作：

```powershell
$env:NOTION_API_KEY = "ntn_xxx..."; cd C:\Users\wengzheng\.openclaw\workspace\skills\notion; .\query-notion-todos.ps1
```

注意：使用 `;` 而不是 `&&`！

## 脚本说明

### query-notion-todos.ps1
- **功能**: 查询状态为「未着手」的任务
- **输出**: 格式化的任务列表 + 原始 JSON

### query-all-tasks.ps1
- **功能**: 查询所有任务，按状态分组显示
- **输出**: 按状态分组的任务列表 + 原始 JSON

### search-databases.ps1
- **功能**: 搜索所有可访问的 Notion 数据库
- **输出**: 数据库列表（名称和 ID）

## 常见问题

**Q: 为什么 PowerShell 显示日文为乱码？**
A: 这是 PowerShell 控制台的编码问题，不影响数据。JSON 输出中的数据是正确的。

**Q: 如何查看完整的 JSON 输出？**
A: 脚本会在最后输出完整的 JSON，你可以复制后给我处理。

**Q: 如何保存输出到文件？**
```powershell
.\query-notion-todos.ps1 | Out-File -FilePath "notion-todos.json" -Encoding UTF8
```

## 数据库信息

- **任务数据库 ID**: `2e29fe12-e0aa-816e-9366-dae1fbe6fd20`
- **状态值**:
  - `not-started` = 未着手
  - `in-progress` = 進行中
  - `done` = 完了
  - `archived` = アーカイブ
