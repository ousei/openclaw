# TOOLS.md - Local Notes

Skills define *how* tools work. This file is for *your* specifics — the stuff that's unique to your setup.

## AI 模型配置

**当前配置：使用 Ollama Pro Cloud 云端模型（不用本地模型）**

- **主要模型**: `ollama/qwen3-coder:480b-cloud` (480B)
- **备用模型 1**: `ollama/gpt-oss:120b-cloud` (120B)
- **备用模型 2**: `ollama/glm-5:cloud`
- **WhatsApp 专用**: `wa` agent 使用 `qwen3-coder:480b-cloud`

**已配置的云端模型**:
- qwen3-coder:480b-cloud, gpt-oss:120b-cloud, gpt-oss:20b-cloud, glm-5:cloud
- qwen3-vl:235b-cloud（多模态，支持图文）

**优势**:
- ✅ 大参数模型，推理能力强
- ✅ 无需本地 GPU/RAM
- ✅ 通过 Ollama Pro 使用云端（`ollama signin` 登录）

**切换模型**: 编辑 `openclaw.json` 中的 `agents.defaults.model` 或 `agents.list` 中对应 agent 的 `model`

**详细文档**: 参见 `workspace/OLLAMA-PRO-SETUP.md`

## What Goes Here

Things like:
- Camera names and locations
- SSH hosts and aliases  
- Preferred voices for TTS
- Speaker/room names
- Device nicknames
- Anything environment-specific

## Examples

```markdown
### Cameras
- living-room → Main area, 180° wide angle
- front-door → Entrance, motion-triggered

### SSH
- home-server → 192.168.1.100, user: admin

### TTS
- Preferred voice: "Nova" (warm, slightly British)
- Default speaker: Kitchen HomePod
```

## Why Separate?

Skills are shared. Your setup is yours. Keeping them apart means you can update skills without losing your notes, and share skills without leaking your infrastructure.

## 浏览器控制（Chrome 扩展）

**当前配置：** ✅ 已启用 Chrome 扩展中继（`browser.attachOnly: true`），使用 `chrome` profile 连接用户的现有 Chrome 标签页。

**Agent 可以使用 `browser` 工具：**
- 当用户要求「打开网页」「用浏览器打开 XXX」时，应使用 `browser` 工具的 `navigate` 操作
- 使用 `profile: "chrome"` 指定扩展中继
- 例如：打开 Yahoo Japan → `browser` → `navigate` → `https://www.yahoo.co.jp/`

**使用前必须满足：**
1. Gateway 已运行（`gateway.cmd` 或 `openclaw gateway`）
2. 用户在 Chrome 中打开一个标签页（任意页面即可）
3. 用户已在该标签页点击 OpenClaw Browser Relay 扩展图标，徽章显示 **ON**
4. 若未附加，提示用户：「请先在要控制的标签页点击 OpenClaw 扩展图标（徽章显示 ON），然后我才能帮您打开网页」

**错误处理：**
- 若返回「Chrome extension relay is running, but no tab is connected」→ 提醒用户点击扩展图标附加标签页
- 若返回「extension relay not reachable」→ 确认 Gateway 正在运行

**详细文档：** https://docs.openclaw.ai/tools/chrome-extension

## 本地搜索 API（已禁用 Brave Search）

**当前配置：** ✅ **已禁用 Brave Search API**，使用本地 SearXNG

**原因：** Brave Search API 有速率限制（免费版：1次/分钟），已切换到本地 SearXNG 解决方案。

### 方案对比

| 方案 | 速率限制 | 费用 | 隐私性 | 部署难度 |
|------|---------|------|--------|---------|
| Brave Search API | ⚠️ 免费版：1次/分钟 | 💰 付费版：$5/1000次 | ⭐⭐ | ⭐ 最简单 |
| SearXNG（本地） | ✅ 无限制 | ✅ 免费 | ⭐⭐⭐⭐ | ⭐⭐ 简单 |
| 自建爬虫+Meilisearch | ✅ 无限制 | ✅ 免费 | ⭐⭐⭐⭐⭐ | ⭐⭐⭐⭐ 复杂 |

### 快速部署 SearXNG（推荐）

**一键部署脚本：**
```powershell
cd C:\Users\wengzheng\.openclaw\workspace\skills\local-search
.\deploy-searxng.ps1
```

**手动部署：**
```powershell
# 创建目录
mkdir C:\searxng
cd C:\searxng

# 创建 docker-compose.yml（见 LOCAL-SEARCH-SETUP.md）
# 启动服务
docker-compose up -d
```

**访问地址：**
- Web 界面: http://localhost:18888
- API 端点: http://localhost:18888/search?q=QUERY&format=json

**当前状态：** ✅ SearXNG 已部署并运行在端口 18888

**详细文档：** 参见 `workspace/skills/local-search/LOCAL-SEARCH-SETUP.md`

## Web Search Language Codes

**重要：** 使用 `web_search` 工具时，必须使用正确的语言代码。Brave Search API 对语言代码有严格的要求：

### 日语（Japanese）
- ❌ **错误**: `search_lang: "ja"`, `ui_lang: "ja"`
- ✅ **正确**: `search_lang: "jp"`, `ui_lang: "ja-JP"`

### 其他语言映射
Brave Search API 支持的语言代码：
- `search_lang`: 'ar', 'eu', 'bn', 'bg', 'ca', 'zh-hans', 'zh-hant', 'hr', 'cs', 'da', 'nl', 'en', 'en-gb', 'et', 'fi', 'fr', 'gl', 'de', 'el', 'gu', 'he', 'hi', 'hu', 'is', 'it', 'jp', 'kn', 'ko', 'lv', 'lt', 'ms', 'ml', 'mr', 'nb', 'pl', 'pt-br', 'pt-pt', 'pa', 'ro', 'ru', 'sr', 'sk', 'sl', 'es', 'sv', 'ta', 'te', 'th', 'tr', 'uk', 'vi'

- `ui_lang`: 'es-AR', 'en-AU', 'de-AT', 'nl-BE', 'fr-BE', 'pt-BR', 'en-CA', 'fr-CA', 'es-CL', 'da-DK', 'fi-FI', 'fr-FR', 'de-DE', 'el-GR', 'zh-HK', 'en-IN', 'en-ID', 'it-IT', 'ja-JP', 'ko-KR', 'en-MY', 'es-MX', 'nl-NL', 'en-NZ', 'no-NO', 'zh-CN', 'pl-PL', 'en-PH', 'ru-RU', 'en-ZA', 'es-ES', 'sv-SE', 'fr-CH', 'de-CH', 'zh-TW', 'tr-TR', 'en-GB', 'en-US', 'es-US'

**规则：** 当需要日语搜索时，始终使用 `search_lang: "jp"` 和 `ui_lang: "ja-JP"`，而不是 `"ja"`。

## Windows 中文/日文路径编码（避免乱码）

**问题：** 当路径包含中文或日文（如 `SynologyDrive\WDS\EG-Keeper多機能FW管理\`）时，`read` / `exec` 可能报 `ENOENT: no such file or directory`，且路径显示为乱码（如 `�S���iFW�Ǘ��`）。

**已做配置：**
- `gateway.cmd` 启动时执行 `chcp 65001`，将控制台代码页设为 UTF-8

**Agent 建议：**
1. **优先用 read 工具**：直接用 `read` 工具指定完整路径，路径保持 UTF-8（中文/日文正常书写）
2. **exec 读取时**：若需用 PowerShell 读文件，先用 `-Encoding UTF8` 或 `Get-Content -LiteralPath`，且路径用单引号：`Get-Content -LiteralPath 'C:\path\中文名.txt' -Encoding UTF8`
3. **若仍失败**：提示用户确认 (1) Gateway 是否在 `chcp 65001` 环境下启动（重启 `.\gateway.cmd`）；(2)  Windows 是否勾选「Beta: 使用 Unicode UTF-8 提供全球语言支持」：设置 → 时间和语言 → 语言和区域 → 管理语言设置 → 更改系统区域设置

**用户可选（系统级 UTF-8）：**
- 设置 → 时间与语言 → 语言与区域 → 管理语言设置 → 更改系统区域设置 → 勾选「Beta: 使用 Unicode UTF-8 提供全球语言支持」→ 重启

## ⚠️ PowerShell 语法重要说明

**代理必须遵守以下 PowerShell 语法规则，避免常见错误：**

### 0. ⚠️ 命令关键字必须使用英文！

❌ **严重错误：PowerShell 命令关键字不能使用中文！**

```powershell
# ❌ 错误：使用中文关键字
Get-ChildItem | 排序对象 LastWriteTime
Get-ChildItem | 格式化表格 Name, Length

# ✅ 正确：必须使用英文关键字
Get-ChildItem | Sort-Object LastWriteTime
Get-ChildItem | Format-Table Name, Length
```

**规则：**
- PowerShell 的所有 cmdlet、参数名必须使用英文
- 只有字符串值（路径、变量值）可以使用中文
- 常用英文关键字：
  - `Sort-Object`（不是"排序对象"）
  - `Format-Table`（不是"格式化表格"）
  - `Where-Object`（不是"筛选对象"）
  - `Select-Object`（不是"选择对象"）
  - `Get-ChildItem`（不是"获取子项"）
  - `Out-File`（不是"输出文件"）

### 1. 命令连接符

❌ **错误：** PowerShell 不支持 `&&` 运算符
```powershell
cd C:\path && dir
```

✅ **正确：** 使用分号 `;` 连接命令
```powershell
cd C:\path; dir
```

✅ **或者：** 使用换行分隔命令
```powershell
cd C:\path
dir
```

### 2. Set-Location (cd) 命令

❌ **错误：** `Set-Location` 不支持 `-Force` 参数
```powershell
Set-Location -Path "C:\path" -Force
```

✅ **正确：** 直接使用路径，或使用 `-ErrorAction SilentlyContinue` 忽略错误
```powershell
Set-Location -Path "C:\path"
# 或者
cd "C:\path"
```

### 3. 文件写入

✅ **正确：** 使用 `Out-File` 写入文件前，确保目录存在
```powershell
# 先创建目录（如果不存在）
if (-not (Test-Path "C:\path\to\directory")) {
    New-Item -ItemType Directory -Path "C:\path\to\directory" -Force | Out-Null
}
# 然后写入文件
"content" | Out-File -FilePath "C:\path\to\directory\file.md" -Encoding UTF8
```

✅ **或者：** 使用 `Join-Path` 和 `$PSScriptRoot` 构建路径
```powershell
$outputFile = Join-Path $PSScriptRoot "output.md"
"content" | Out-File -FilePath $outputFile -Encoding UTF8
```

### 4. 相对路径

⚠️ **注意：** 在 PowerShell 脚本中，相对路径是相对于当前工作目录的，不是脚本所在目录
```powershell
# 错误：如果当前目录不是脚本目录，相对路径会失败
.\query-notion-todos.ps1 | Out-File "immutable\output.md"

# 正确：先切换到脚本目录，或使用绝对路径
cd "C:\Users\wengzheng\.openclaw\workspace\skills\notion"
.\query-notion-todos.ps1 | Out-File "immutable\output.md"
```

### 5. Python 脚本执行

❌ **错误：** PowerShell 中不能使用 `&&` 连接 Python 命令
```powershell
python script.py && cat output.json
```

✅ **正确：** 使用分号或换行
```powershell
python script.py; cat output.json
# 或者
python script.py
if ($LASTEXITCODE -eq 0) { cat output.json }
```

### 6. 环境变量设置

✅ **正确：** 在 PowerShell 中设置环境变量
```powershell
$env:NOTION_API_KEY = "ntn_xxx..."
```

### 7. UNC 网络路径格式

⚠️ **重要：UNC 路径必须使用正确的格式**

❌ **错误格式：**
```powershell
dir //nas\\homes\\weng          # 错误：使用了正斜杠和混合反斜杠
dir .\\nas\\homes\\weng          # 错误：使用了 .\\ 前缀
Get-Item "//nas\\homes\\weng"    # 错误：路径格式不正确
```

✅ **正确格式：**
```powershell
dir "\\nas\homes\weng"            # 正确：双反斜杠开头，单反斜杠分隔
Get-Item "\\nas\homes\weng"      # 正确：使用引号包裹路径
Get-ChildItem "\\nas\homes\weng\documents"  # 正确：完整路径
```

**关键规则：**
- UNC 路径必须以 `\\`（双反斜杠）开头
- 路径中使用 `\`（单反斜杠）分隔
- 使用引号包裹路径（避免特殊字符问题）
- 不要混淆本地路径和网络路径

**路径示例：**
```powershell
# 本地路径（脚本文件）
C:\Users\wengzheng\.openclaw\workspace\skills\notion\query-real-estate.ps1

# 网络路径（NAS 文件）
\\nas\homes\weng\documents\file.txt

# ❌ 错误：不要将本地路径拼接到网络路径
.\\nas\\homes\\weng\\Users\\wengzheng\\.openclaw\\...  # 错误！
```

### 8. Test-NetConnection 的正确用法

⚠️ **重要：Test-NetConnection 在不同 PowerShell 版本中行为不同**

❌ **错误用法（会导致属性不存在错误）：**
```powershell
Test-NetConnection -ComputerName nas -Port 445 -InformationLevel Quiet | Select -ExpandProperty TcpTestSucceeded
```

✅ **正确用法：**

**方法 1: 检查返回类型（兼容不同版本）**
```powershell
$result = Test-NetConnection -ComputerName nas -Port 445 -InformationLevel Quiet -WarningAction SilentlyContinue
if ($result -is [bool]) {
    # PowerShell 5.1 返回布尔值
    if ($result) { Write-Host "端口可访问" }
} elseif ($result.PSObject.Properties.Name -contains 'TcpTestSucceeded') {
    if ($result.TcpTestSucceeded) { Write-Host "端口可访问" }
}
```

**方法 2: 使用 Test-Path（推荐，最可靠）**
```powershell
# 测试 UNC 路径，比端口测试更可靠
if (Test-Path "\\nas\homes\weng") {
    Write-Host "NAS 可访问"
}
```

**推荐：** 优先使用 `Test-Path` 测试 UNC 路径，而不是使用 `Test-NetConnection` 测试端口。

### 9. 错误处理

✅ **推荐：** 检查命令是否成功
```powershell
$result = .\script.ps1
if ($LASTEXITCODE -ne 0) {
    Write-Host "Script failed with exit code $LASTEXITCODE" -ForegroundColor Red
}
```

**重要提醒：**
- ⚠️ **所有通过 `exec` 工具执行的 PowerShell 命令必须遵守以上规则**
- ⚠️ **如果命令失败，检查是否使用了 `&&`、`Set-Location -Force` 等不支持的语法**
- ⚠️ **PowerShell 不支持 `&&` 运算符！永远使用 `;` 或换行分隔命令！**
- 写入文件前，确保目标目录存在
- **UNC 路径必须使用 `\\` 开头，不要使用 `//` 或 `.\\`**
- **参考 `POWERSHELL-RULES.md` 获取完整的 PowerShell 语法规则**

## Notion API

**配置：**
- API Token: 已配置在 `.env` 文件（`NOTION_API_KEY`）
- 集成来源: Notion 内部集成「aiclaw」，wengzheng 工作区
- API 端点: `https://api.notion.com/v1/`
- **注意：** OpenClaw 不支持在 `openclaw.json` 中配置 `tools.notion`，只能通过环境变量 `NOTION_API_KEY` 访问

**数据库 ID（已测试）：**
- **タスク（任务/待办）数据库**: `2e29fe12-e0aa-816e-9366-dae1fbe6fd20` ⭐
- **プロジェクト（项目）数据库 1**: `2e29fe12-e0aa-81fb-a137-f3fe5c2a6c34`
- **プロジェクト（项目）数据库 2**: `2e29fe12-e0aa-8125-8c3e-ca664ec2831a`
- **家主db**: `2e39fe12-e0aa-81d2-9e4e-fe3de4633f12`
- **不動産db**: `2e39fe12-e0aa-814b-88b6-e33aa4afe2f5`
- **契約者db**: `2e39fe12-e0aa-8146-b201-fbf844e001ea`

**快速开始：**

**最简单的方式 - 查询待办项目：**

**方法 1: PowerShell 脚本（推荐）**

⚠️ **注意**: 
- PowerShell 不支持 `&&`，请使用 `;` 或换行分隔命令！
- 如果通过 OpenClaw 的 exec 工具运行遇到 400 错误，建议直接在 PowerShell 终端中手动运行

**标准版本：**
```powershell
# 设置环境变量（如果还没设置，通常已配置在 .env）
$env:NOTION_API_KEY = "ntn_xxx..."

# 切换到脚本目录并运行
cd C:\Users\wengzheng\.openclaw\workspace\skills\notion
.\query-notion-todos.ps1
```

**调试版本（如果遇到错误，会显示详细错误信息）：**
```powershell
cd C:\Users\wengzheng\.openclaw\workspace\skills\notion
.\query-todos-debug.ps1
```

**或者一行命令：**
```powershell
$env:NOTION_API_KEY = "ntn_xxx..."; cd C:\Users\wengzheng\.openclaw\workspace\skills\notion; .\query-notion-todos.ps1
```

**如果遇到 400 错误：**
1. 检查环境变量是否正确设置：`$env:NOTION_API_KEY`
2. 使用调试版本脚本查看详细错误信息
3. 参考 `TROUBLESHOOTING.md` 进行故障排查

**方法 2: 查询所有任务（按状态分组）**
```powershell
.\query-all-tasks.ps1
```

**方法 3: 查询不动产数据库（重要）**

⚠️ **推荐使用包装脚本（避免编码和路径问题）：**
```powershell
# 使用包装脚本（自动处理编码和路径）
C:\Users\wengzheng\.openclaw\workspace\skills\notion\run-query-real-estate.ps1
```

**或者直接运行（需要先设置环境变量）：**
```powershell
# 设置环境变量
$env:NOTION_API_KEY = "ntn_xxx..."

# 切换到脚本目录（使用分号，不是 &&）
cd C:\Users\wengzheng\.openclaw\workspace\skills\notion; .\query-real-estate.ps1
```

**或者一行命令（使用分号分隔）：**
```powershell
$env:NOTION_API_KEY = "ntn_xxx..."; cd C:\Users\wengzheng\.openclaw\workspace\skills\notion; .\query-real-estate.ps1
```

**❌ 错误示例（不要使用）：**
```powershell
# 错误：使用了 &&
cd C:\path && .\script.ps1

# 错误：路径格式错误
.\\.openclaw\workspace\skills\notion\query-real-estate.ps1
```

**方法 4: 使用 curl（Windows）**
```cmd
set NOTION_API_KEY=ntn_xxx...
query-with-curl.bat
```

**脚本功能：**
- ✅ 自动使用环境变量中的 `NOTION_API_KEY`
- ✅ 查询「未着手」状态的任务
- ✅ 显示格式化的任务列表（标题、状态、截止日期、优先级）
- ✅ 同时输出原始 JSON（方便复制给我处理）
- ✅ 使用正确的日文属性名 `ステータス`

**其他脚本：**

1. **查找数据库 ID：**
   ```powershell
   cd workspace\skills\notion
   .\search-databases.ps1
   ```

2. **查询待办项目（带参数）：**
   ```powershell
   .\query-todos.ps1 -DatabaseId "2e29fe12-e0aa-816e-9366-dae1fbe6fd20" -Status "未着手"
   ```

**获取数据库 ID：**
- 方法 1: 使用 `search-databases.ps1` 脚本
- 方法 2: 从 Notion URL 中获取：
  - 打开 Notion 数据库页面
  - URL 格式: `notion.so/{workspace}/{database_id}`
  - 复制 `database_id`（32 位十六进制字符串）

**使用说明：**
- Notion API 使用 Bearer token 认证
- 请求头需要包含: `Authorization: Bearer {NOTION_API_KEY}`
- 请求头需要包含: `Notion-Version: 2022-06-28` (或更新的版本)
- 请求头需要包含: `Content-Type: application/json`

**常用操作：**
- 搜索数据库: `POST /search` (使用 `search-databases.ps1`)
- 查询数据库: `POST /databases/{database_id}/query` (使用 `query-todos.ps1`)
- 查询页面: `GET /pages/{page_id}`
- 创建页面: `POST /pages`
- 更新页面: `PATCH /pages/{page_id}`

**重要提示：**
- ⚠️ **当用户询问不动产、房产、房屋等信息时，必须使用 `query-real-estate.ps1` 查询 Notion 不动产数据库**
- ⚠️ **不要只说"无法访问"，应该主动使用工具查询用户信息**
- ⚠️ **代理应该主动使用 Notion API 查询用户信息，而不是猜测或说"不知道"**

**注意事项：**
- ✅ 确保 Notion integration 已添加到需要访问的页面/数据库
- ✅ API token 以 `ntn_` 开头
- ✅ 需要授予相应的权限（读取、更新等）
- ✅ 属性名称区分大小写（如 "Status" vs "status"）

**任务状态值：**
- `未着手` (not-started) - 待办
- `進行中` (in-progress) - 进行中
- `完了` (done) - 已完成
- `アーカイブ` (archived) - 已归档

## 内存搜索问题

**问题：** `fts unavailable: no such module: fts5`

**说明：** 这是 SQLite FTS5 全文搜索模块缺失的问题。`memory_search` 工具依赖 FTS5，但当前 SQLite 版本可能不支持或未编译 FTS5。

**影响：**
- ❌ `memory_search` 工具无法使用全文搜索功能
- ✅ 其他功能（包括 Notion API）正常工作
- ✅ 可以使用文件搜索（`codebase_search`）作为替代

**解决方案：**
1. 这是一个系统级别的问题，通常需要更新 SQLite 或重新编译 Node.js SQLite 绑定
2. 目前可以忽略此错误，不影响其他功能
3. 如需使用内存搜索，可以：
   - 使用文件搜索替代
   - 在文件中记录重要信息（如上面的数据库 ID）
   - 等待 OpenClaw 更新修复

## NAS 服务器访问

**网络路径：**
- ❌ `\\nas\home` - **已不可用**
- ✅ `\\nas\homes\weng` - **当前使用的路径**（使用 `nas\weng` 用户名，密码：19801502）

**状态说明：**
- ❌ `\\nas\home` - 已不再使用，无法访问
- ✅ `\\nas\homes\weng` - **当前可用的路径**，需要使用域格式 `nas\weng` 才能访问
- 用户文件现在位于 `\\nas\homes\weng` 路径下

**连接凭据：**
- `\\nas\homes\weng`: 用户名 `nas\weng`，密码 `19801502`

**重要更新：**
- ⚠️ **`\\nas\home` 路径已废弃，不再使用**
- ✅ **所有文件访问应使用 `\\nas\homes\weng` 路径**

**NAS 设置检查：**
- ✅ SMB 服务已启用
- ✅ SMB 协议版本：SMB2-SMB3（兼容性好）
- ✅ 性能优化功能已启用
- ✅ 安全设置合理（NTLMv1 已禁用）
- ✅ **设置正确，连接问题已解决**

**使用方式：**

⚠️ **🚨 强制规则：OpenClaw 识别问题 - 必须使用变量代替 \\nas**

**问题：** OpenClaw 在处理 `\\nas` 路径时**一定会**识别错误（将 `\\nas` 识别为 `\as`）

**🚨 强制解决方案：必须使用变量！**

**在生成任何 NAS 访问命令前，必须先定义变量，然后使用变量！**

**方法 1: 使用 PowerShell 变量（推荐）**
```powershell
# 定义 NAS 路径变量（使用 Nas 作为变量名，避免 \\nas 识别错误）
$Nas = "\\nas"
$NasHomes = "\\nas\homes"
$NasHomesWeng = "\\nas\homes\weng"

# 使用变量访问路径
Get-ChildItem "$NasHomesWeng\履歴書"
```

**方法 2: 使用脚本中的函数**
```powershell
# 导入 NAS 路径映射模块
. C:\Users\wengzheng\.openclaw\workspace\skills\nas\nas-path-mapper.ps1

# 使用函数转换路径
$path = Convert-NasPath "Nas\homes\weng\履歴書"
Get-ChildItem $path
```

**方法 3: 使用包装脚本**
```powershell
# 运行使用 Nas 别名的脚本
C:\Users\wengzheng\.openclaw\workspace\skills\nas\use-nas-alias.ps1
```

⚠️ **重要：UNC 路径格式规则**
- ✅ **正确格式**：使用双反斜杠 `\\` 开头，路径中使用单反斜杠 `\`
- ❌ **错误格式**：不要使用 `//`、`.\\` 或混合格式
- ✅ **正确示例**：`\\nas\homes\weng\documents\file.txt`
- ❌ **错误示例**：`//nas\\homes\\weng`、`.\\nas\\homes\\weng`
- ⚠️ **OpenClaw 识别问题**：在命令中使用变量 `$Nas` 代替直接写 `\\nas`

⚠️ **重要：NAS 访问方法**
- ✅ **推荐方法**：使用 `Test-Path` 和 `Get-ChildItem`（最可靠）
- ❌ **避免使用**：`Invoke-Command`（需要 WinRM，NAS 通常不支持）
- ❌ **避免使用**：`Test-NetConnection`（可能不准确，端口测试不代表文件访问）
- ✅ **连接步骤**：
  1. 先连接共享：`net use \\nas\homes /user:nas\weng 19801502 /persistent:yes`
  2. 然后访问路径：`Test-Path "\\nas\homes\weng"`
  3. 列出内容：`Get-ChildItem "\\nas\homes\weng"`

⚠️ **重要：访问包含日文字符的路径**

**问题：** 访问包含日文字符的路径（如 `履歴書`）可能失败

**解决方案：**

1. **设置 UTF-8 编码**（必须）：
```powershell
[Console]::OutputEncoding = [System.Text.Encoding]::UTF8
$OutputEncoding = [System.Text.Encoding]::UTF8
chcp 65001 | Out-Null
```

2. **先列出目录内容，确认路径名**：
```powershell
# 列出所有目录，查看实际存在的目录名
Get-ChildItem "\\nas\homes\weng" | Select-Object Name

# 搜索包含特定字符的目录
Get-ChildItem "\\nas\homes\weng" -Directory | Where-Object { $_.Name -match "履歴" }
```

3. **使用 -LiteralPath 参数**（如果路径包含特殊字符）：
```powershell
Get-ChildItem -LiteralPath "\\nas\homes\weng\履歴書"
```

4. **完整示例脚本（已验证有效）**：
```powershell
# 设置编码（必须）
[Console]::OutputEncoding = [System.Text.Encoding]::UTF8
chcp 65001 | Out-Null

# 连接 NAS
net use \\nas\homes /user:nas\weng 19801502 /persistent:yes

# 列出内容
Get-ChildItem "\\nas\homes\weng"

# 访问日文路径（三种方法，已验证有效）
# 方法 1: 使用变量（推荐）
$path = "\\nas\homes\weng\履歴書"
Get-ChildItem $path

# 方法 2: 使用反引号转义
Get-ChildItem "`\\nas\homes\weng\履歴書"

# 方法 3: 使用 -LiteralPath
Get-ChildItem -LiteralPath "\\nas\homes\weng\履歴書"
```

**已验证的有效方法：**
- ✅ 使用变量存储路径（最可靠）
- ✅ 使用反引号 ` 转义反斜杠
- ✅ 使用 `-LiteralPath` 参数

**推荐使用脚本：** 
- `workspace\skills\nas\get-nas-files.ps1` - **列出 NAS 文件（推荐）**
- `workspace\skills\nas\read-nas-file-direct.ps1` - **直接读取 NAS 文件内容（不复制到本地）**
- `workspace\skills\nas\access-nas-with-japanese.ps1` - 访问日文字符路径
- `workspace\skills\nas\list-nas-files.ps1` - 列出 NAS 文件（完整版）

**快速执行（使用变量避免识别错误）：**
```powershell
# 列出文件
C:\Users\wengzheng\.openclaw\workspace\skills\nas\get-nas-files.ps1

# 读取文件内容（不复制到本地）
C:\Users\wengzheng\.openclaw\workspace\skills\nas\read-nas-file-direct.ps1 -FilePath "\\nas\homes\weng\履歴書\file.txt"
```

**📚 详细指南：** 参见 `NAS-FILE-ANALYSIS.md` - NAS 文件分析和读取完整指南

**在 PowerShell 中使用 UNC 路径：**
```powershell
# ✅ 正确：使用双反斜杠开头
Get-ChildItem "\\nas\homes\weng"

# ✅ 正确：访问文件
Get-Content "\\nas\homes\weng\documents\file.txt"

# ❌ 错误：不要使用正斜杠或混合格式
Get-ChildItem "//nas\\homes\\weng"  # 错误！

# ❌ 错误：不要使用 .\\ 前缀
Get-ChildItem ".\\nas\\homes\\weng"  # 错误！
```

**重要提示：**
- NAS 路径是网络路径，不是本地路径
- 不要在 NAS 路径下拼接本地路径（如 `C:\Users\...`）
- 脚本文件位于本地：`C:\Users\wengzheng\.openclaw\workspace\skills\notion\query-real-estate.ps1`
- NAS 文件位于网络：`\\nas\homes\weng\...`

**`homes\weng` 文件夹访问问题：**

如果遇到 `\\nas\homes\weng` 无法访问的错误（权限不足或连接冲突），解决方法：

**✅ 成功连接的方法（已验证）：**

**对于 `\\nas\homes\weng`（当前使用的路径）：**
```powershell
# 必须使用域\用户名格式
net use \\nas\homes /user:nas\weng 19801502 /persistent:yes
```

**关键点：**
- ✅ `\\nas\homes\weng` - 必须使用 `nas\weng` 格式（域\用户名）
- ⚠️ 如果使用错误的格式，会提示"访问被拒绝"
- ✅ 连接成功后，在资源管理器中可以正常访问
- ❌ `\\nas\home` 路径已废弃，不再使用

**方法 1: 使用资源管理器手动连接（最可靠）**
1. 打开资源管理器（Windows + E）
2. 地址栏输入：`\\nas\homes\weng`
3. 输入用户名和密码（使用 `nas\weng` 格式）
4. 勾选"记住我的凭据"
5. 点击确定

**方法 2: 使用 net use 命令连接**
```powershell
# 断开所有连接（如果有冲突）
net use \\nas\* /delete /yes

# 使用域\用户名格式连接 homes 共享
net use \\nas\homes /user:nas\weng 19801502 /persistent:yes

# 然后访问用户目录
# 路径：\\nas\homes\weng
```

**方法 3: 检查 NAS 权限设置**
- 登录 NAS 管理界面（通常是 `http://nas` 或 `http://nas:5000`）
- 检查 `homes` 共享文件夹的权限设置
- 确保勾选"このフォルダ、サブフォルダ、ファイルに適用する"（应用到子文件夹）
- 删除无效的权限条目（如"不明なユーザー/グループ"）

**常见错误：**

1. **路径格式错误：**
   - ❌ `dir //nas\\homes\\weng` - 使用了正斜杠和混合反斜杠
   - ✅ `dir "\\nas\homes\weng"` - 使用双反斜杠开头，单反斜杠分隔
   
2. **路径混淆错误：**
   - ❌ `.\\nas\\homes\\weng\\Users\\wengzheng\\.openclaw\\...` - 错误地将本地路径拼接到 NAS 路径
   - ✅ 本地脚本：`C:\Users\wengzheng\.openclaw\workspace\skills\notion\query-real-estate.ps1`
   - ✅ NAS 文件：`\\nas\homes\weng\documents\file.txt`

3. **"多个连接冲突"（错误 1219）**：
   - 解决：先断开所有连接 `net use \\nas\* /delete /yes`，然后使用 `nas\weng` 格式重新连接

4. **"权限不足"**：
   - 解决：在 Synology DSM 中检查权限设置，确保权限应用到子文件夹

5. **NET HELPMSG 3775**：
   - 通常是网络路径连接问题
   - 解决：先使用 `net use` 连接共享，或确保凭据已保存

**注意事项：**
- 如果 NAS 需要认证，确保当前 Windows 用户已有访问权限
- 如果遇到权限问题，可以：
  1. 在 Windows 资源管理器中手动访问一次，输入凭据并选择"记住我的凭据"
  2. 或者使用 `net use` 命令映射驱动器：
     ```powershell
     net use Z: \\nas\homes\weng /persistent:yes
     ```
     然后可以使用 `Z:\` 访问

**推荐做法：**
- 如果需要频繁访问，建议映射为驱动器号（如 `Z:`）
  ```powershell
  net use Z: \\nas\homes\weng /persistent:yes
  ```
- 如果只是偶尔访问，直接使用 UNC 路径 `\\nas\homes\weng` 即可
- 对于 `homes\weng` 文件夹，建议先手动在资源管理器中连接一次，保存凭据

---

Add whatever helps you do your job. This is your cheat sheet.
