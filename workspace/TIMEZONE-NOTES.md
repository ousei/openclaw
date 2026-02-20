# 时区说明

## 当前配置

- **系统时区**: Tokyo Standard Time (GMT+9)
- **USER.md 中设置的时区**: Asia/Tokyo
- **OpenClaw 日志时间戳**: UTC（协调世界时）

## 问题

OpenClaw 的日志时间戳显示的是 **UTC 时间**，而不是本地时间（东京时间）。

**示例：**
- 日志显示：`03:27:57`（UTC）
- 实际本地时间：`12:27:57`（东京时间，GMT+9）
- 时差：UTC + 9 小时 = 东京时间

## 时间转换

**UTC 转东京时间：**
- UTC 时间 + 9 小时 = 东京时间
- 例如：UTC 03:27:57 → 东京 12:27:57

**东京时间转 UTC：**
- 东京时间 - 9 小时 = UTC 时间
- 例如：东京 12:27:57 → UTC 03:27:57

## 注意事项

1. **OpenClaw 日志时间戳**：始终使用 UTC
2. **系统时间**：使用本地时区（东京时间）
3. **WhatsApp 消息时间戳**：在消息内容中显示为 `[2026-02-01 12:27:59 GMT+9]`（本地时间）

## 解决方案

⚠️ **重要：OpenClaw 日志时间戳使用 UTC 是默认行为，无法通过配置更改**

OpenClaw 是一个 Node.js 应用，日志时间戳在应用代码层面硬编码使用 UTC 时间。这是标准做法，因为：
- UTC 是国际标准时间，不受时区影响
- 便于跨时区协作和日志分析
- 避免夏令时等时区变化带来的问题

**已尝试的配置（无效）：**
- ✅ 在 `.env` 中添加 `TZ=Asia/Tokyo`
- ✅ 在 `openclaw.json` 的 `env` 中添加 `"TZ": "Asia/Tokyo"`
- ❌ **结果：日志时间戳仍然显示 UTC**

**如果需要查看本地时间：**

1. **快速转换**：UTC 时间 + 9 小时 = 东京时间
   - 例如：`03:33:23` UTC → `12:33:23` 东京时间

2. **查看系统时间**：使用 `Get-Date` 命令查看当前本地时间
   ```powershell
   Get-Date  # 显示本地时间
   ```

3. **查看 WhatsApp 消息时间**：消息内容中包含本地时间戳
   - 格式：`[2026-02-01 12:33:59 GMT+9]`

4. **使用 PowerShell 转换**：
   ```powershell
   # 将 UTC 时间转换为本地时间
   $utcTime = "2026-02-01 03:33:23"
   $localTime = [DateTime]::Parse($utcTime).ToLocalTime()
   Write-Host "UTC: $utcTime"
   Write-Host "本地时间: $localTime"
   ```

## PowerShell 时间命令

```powershell
# 查看当前本地时间
Get-Date

# 查看当前 UTC 时间
Get-Date -Format "yyyy-MM-dd HH:mm:ss UTC" -UFormat "%Y-%m-%d %H:%M:%S UTC"

# 查看时区信息
Get-TimeZone

# 转换时间
$utcTime = Get-Date -AsUTC
$localTime = $utcTime.ToLocalTime()
Write-Host "UTC: $utcTime"
Write-Host "本地时间: $localTime"
```
