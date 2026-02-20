# 修复上下文窗口问题

## 问题

日志显示：
```
blocked model (context window too small): ollama/llama3:latest ctx=8192 (min=16000)
```

OpenClaw 要求最小上下文窗口为 16000，但 `llama3:latest` 配置的是 8192。

## ✅ 已修复

更新了 `openclaw.json` 中的 `llama3:latest` 配置：
- `contextWindow`: 8192 → **16384**
- `maxTokens`: 81920 → **163840**

## 下一步

**重启 OpenClaw 网关**让配置生效：
1. 在运行 OpenClaw 的终端按 `Ctrl+C` 停止
2. 重新启动：`cd C:\Users\wengzheng\.openclaw && .\gateway.cmd`

重启后应该可以正常工作了！
