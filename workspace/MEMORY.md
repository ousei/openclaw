# MEMORY.md - 长期记忆

这是代理的长期记忆文件，记录重要信息、决策和上下文。

## 用户信息

**姓名/称呼：** 翁征  
**语言偏好：** 中文  
**代理称呼：** 管家

## 重要数据源

### Notion 数据库

用户的重要信息存储在 Notion 数据库中，代理应该主动使用 Notion API 查询这些信息。

**已配置的数据库：**
- **不动产数据库** (`不動産db`): `2e39fe12-e0aa-814b-88b6-e33aa4afe2f5` ⭐ **重要**
- **家主数据库** (`家主db`): `2e39fe12-e0aa-81d2-9e4e-fe3de4633f12`
- **契約者数据库** (`契約者db`): `2e39fe12-e0aa-8146-b201-fbf844e001ea`
- **任务数据库** (`タスク`): `2e29fe12-e0aa-816e-9366-dae1fbe6fd20`
- **项目数据库 1**: `2e29fe12-e0aa-81fb-a137-f3fe5c2a6c34`
- **项目数据库 2**: `2e29fe12-e0aa-8125-8c3e-ca664ec2831a`

**如何使用：**
1. Notion API Key 已配置在 `.env` 文件中（`NOTION_API_KEY`）
2. 可以使用 `exec` 工具运行 PowerShell 脚本查询数据库
3. 脚本位置：`C:\Users\wengzheng\.openclaw\workspace\skills\notion\`
4. 查询不动产数据库的示例：
   ```powershell
   $env:NOTION_API_KEY = "ntn_xxx..."
   cd C:\Users\wengzheng\.openclaw\workspace\skills\notion
   # 使用 curl 或 PowerShell 脚本查询数据库
   ```

**重要提示：**
- 当用户询问不动产、房产、房屋等信息时，**必须**查询 Notion 不动产数据库
- 当用户询问个人信息时，**应该**查询相关的 Notion 数据库
- 不要只说"无法访问"，应该主动使用工具查询

### NAS 服务器

- ❌ `\\nas\home` - **已废弃，不再使用**
- ✅ `\\nas\homes\weng` - **当前使用的路径**（使用用户名 `nas\weng`，密码：19801502）

**重要更新：**
- 用户文件现在位于 `\\nas\homes\weng` 路径下
- 所有文件访问应使用此路径

## 系统配置

- **当前模型：** `ollama/llama3-groq-tool-use:latest`（本地 Ollama）
- **工作空间：** `C:\Users\wengzheng\.openclaw\workspace`

## 重要原则

1. **主动查询信息：** 当用户询问个人信息时，不要只说"无法访问"，应该使用可用的工具（如 Notion API、文件系统等）主动查询
2. **记住数据源位置：** 重要信息存储在 Notion 数据库中，数据库 ID 已记录在此文件中
3. **使用中文回复：** 用户偏好中文沟通
4. **工具优先：** 优先使用工具查询信息，而不是猜测或说"不知道"

## 更新记录

- 2026-01-31: 创建 MEMORY.md，记录用户信息、Notion 数据库 ID 和重要原则
