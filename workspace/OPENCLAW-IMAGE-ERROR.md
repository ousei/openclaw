# OpenClaw 图像获取错误说明

## 错误信息

```
[tools] image failed: Failed to fetch media from https://raw.cdn.openclaw.ai/image?path=...
TypeError: fetch failed
```

## 问题原因

这是 OpenClaw 的**截图功能**错误。当使用 `exec` 工具执行 PowerShell 命令时，如果设置了 `pty: true`（伪终端模式），OpenClaw 会尝试：
1. 捕获命令执行的终端截图
2. 将截图保存到临时目录
3. 通过 CDN 提供截图给代理查看

**失败的可能原因：**
1. 截图文件不存在（路径错误或文件未生成）
2. CDN 无法访问本地临时文件
3. 路径编码问题（`appd` 可能是 `AppData` 的缩写错误）

## 解决方案

### 方案 1: 禁用截图功能（推荐）

在 `exec` 工具调用时，设置 `pty: false`：

```json
{
  "command": "your-powershell-command",
  "pty": false  // 禁用伪终端，不生成截图
}
```

**优点：**
- 避免截图错误
- 命令执行更快
- 输出直接返回，不需要截图

### 方案 2: 使用脚本文件代替内联命令

将命令写入脚本文件，然后执行脚本：

```powershell
# 创建脚本文件
# 然后执行
.\your-script.ps1
```

**优点：**
- 避免复杂的命令转义
- 更容易调试
- 可以设置编码和错误处理

### 方案 3: 忽略错误（如果命令成功执行）

如果命令本身执行成功，只是截图失败，可以忽略此错误。截图功能是可选的，不影响命令执行结果。

## 推荐做法

**对于 PowerShell 命令：**

1. **使用 `pty: false`**（推荐）
   ```json
   {
     "command": "your-powershell-command",
     "pty": false
   }
   ```

2. **使用脚本文件**
   ```powershell
   # 执行脚本文件
   C:\Users\wengzheng\.openclaw\workspace\skills\nas\list-files-simple.ps1
   ```

3. **避免使用 `pty: true`**
   - 除非确实需要终端截图
   - PowerShell 命令通常不需要截图

## 注意事项

- **截图功能是可选的**：命令执行成功即可，截图失败不影响功能
- **使用脚本更可靠**：将复杂命令写入脚本文件，避免转义和编码问题
- **直接输出更好**：使用 `pty: false` 让命令输出直接返回，不需要截图

## 相关文件

- `workspace\skills\nas\list-files-simple.ps1` - 示例脚本（不使用 pty）
- `workspace\POWERSHELL-RULES.md` - PowerShell 语法规则
