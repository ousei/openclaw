# NAS 文件分析和读取指南

## 目标

使用 OpenClaw 直接从 NAS 读取文件并进行分析，**不需要复制到本地**。

## 方法 1: 使用 read 工具直接读取（推荐）

OpenClaw 的 `read` 工具可以直接读取网络路径的文件。

### 前提条件

1. **NAS 必须已连接**（使用 `net use` 或手动连接）
2. **使用变量代替直接路径**（避免 OpenClaw 识别错误）

### 步骤

**步骤 1: 连接 NAS**
```powershell
# 定义变量（必须）
$NasHomes = "\\nas\homes"

# 连接
net use $NasHomes /user:nas\weng 19801502 /persistent:yes
```

**步骤 2: 使用 read 工具读取文件**

在 OpenClaw 中使用 `read` 工具，路径使用变量构建：

```json
{
  "path": "\\\\nas\\homes\\weng\\履歴書\\2025-04-10_履歴書.pdf"
}
```

**⚠️ 注意：** 由于 OpenClaw 可能将 `\\nas` 识别错误，建议：
1. 先使用 PowerShell 脚本获取文件的实际路径
2. 然后使用 read 工具读取

## 方法 2: 使用 PowerShell 脚本读取并输出（最可靠）

创建一个脚本，读取 NAS 文件内容并输出给 OpenClaw。

### 脚本功能

- 连接 NAS（使用变量）
- 搜索目标文件
- 读取文件内容
- 输出到控制台（OpenClaw 可以捕获）

### 使用方法

```powershell
# 读取指定文件
C:\Users\wengzheng\.openclaw\workspace\skills\nas\read-nas-file-direct.ps1 -FilePath "\\nas\homes\weng\履歴書\file.txt"

# 或者让脚本自动搜索
C:\Users\wengzheng\.openclaw\workspace\skills\nas\read-nas-file-direct.ps1
```

### 支持的文件类型

- **文本文件**: `.txt`, `.md`, `.json`, `.csv`, `.log`, `.ps1`, `.py`, `.js`, `.html`, `.xml`
  - 直接读取并输出内容
  
- **PDF 文件**: `.pdf`
  - 输出文件信息
  - 需要额外工具提取文本内容

- **其他文件**: 
  - 输出文件元数据（名称、大小、修改时间等）

## 方法 3: 使用 OpenClaw 的 read 工具（需要正确路径）

### 正确的使用方式

**❌ 错误（可能被识别错误）：**
```json
{
  "path": "\\\\nas\\homes\\weng\\履歴書\\file.txt"
}
```

**✅ 正确（使用脚本获取路径后）：**
```json
{
  "path": "\\\\nas\\homes\\weng\\履歴書\\file.txt"
}
```

**推荐流程：**
1. 先运行 `get-nas-files.ps1` 获取文件列表和完整路径
2. 从输出中复制完整的文件路径
3. 使用 `read` 工具读取该路径

## 完整工作流程

### 场景：分析 NAS 上的简历文件

**步骤 1: 列出文件**
```powershell
C:\Users\wengzheng\.openclaw\workspace\skills\nas\get-nas-files.ps1
```

**步骤 2: 读取文件内容**
```powershell
# 方法 A: 使用脚本读取（文本文件）
C:\Users\wengzheng\.openclaw\workspace\skills\nas\read-nas-file-direct.ps1 -FilePath "\\nas\homes\weng\履歴書\Applicant_翁征.md"

# 方法 B: 使用 OpenClaw read 工具（需要完整路径）
# 从步骤 1 的输出中复制完整路径，然后使用 read 工具
```

**步骤 3: 分析内容**
- OpenClaw 可以分析脚本输出的文本内容
- 对于 PDF，需要先转换为文本或使用 PDF 解析工具

## 推荐方案

### 对于文本文件（.txt, .md, .json 等）

**使用 PowerShell 脚本读取：**
```powershell
C:\Users\wengzheng\.openclaw\workspace\skills\nas\read-nas-file-direct.ps1 -FilePath "\\nas\homes\weng\履歴書\Applicant_翁征.md"
```

脚本会：
1. 连接 NAS（使用变量）
2. 读取文件内容
3. 输出到控制台
4. OpenClaw 可以捕获并分析

### 对于 PDF 文件

**选项 1: 使用 PDF 转换工具**
```powershell
# 需要安装 pdftotext 或其他 PDF 工具
# 转换为文本后读取
```

**选项 2: 使用 PowerShell PDF 库**
```powershell
# 需要安装 PDF 解析库
# 提取文本内容
```

**选项 3: 直接读取文件信息**
```powershell
# 至少可以获取文件名、大小、修改时间等信息
C:\Users\wengzheng\.openclaw\workspace\skills\nas\read-nas-file-direct.ps1 -FilePath "\\nas\homes\weng\履歴書\2025-04-10_履歴書.pdf"
```

## 最佳实践

1. **使用变量**：所有 NAS 路径操作都使用变量
2. **先列出再读取**：先获取文件列表，确认路径后再读取
3. **使用脚本**：复杂操作使用脚本，避免内联命令的编码和路径问题
4. **直接读取**：文本文件可以直接读取，不需要复制到本地

## 示例脚本

已创建的脚本：
- `get-nas-files.ps1` - 列出 NAS 文件
- `read-nas-file-direct.ps1` - 直接读取 NAS 文件内容

## 注意事项

1. **NAS 必须已连接**：确保 `net use` 连接成功
2. **使用变量**：避免 OpenClaw 识别错误
3. **编码设置**：访问日文路径时设置 UTF-8 编码
4. **文件类型**：文本文件可以直接读取，PDF 需要额外处理
