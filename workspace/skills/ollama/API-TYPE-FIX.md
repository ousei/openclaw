# Ollama API 类型修复

## 问题

配置 `api: "openai-chat"` 后出现错误：
```
Invalid config at C:\Users\wengzheng\.openclaw\openclaw.json:
- models.providers.ollama.api: Invalid input
```

## 原因

OpenClaw 的 Ollama provider **只支持** `openai-completions` API 类型，不支持 `openai-chat`。

## ✅ 正确配置

```json
{
  "models": {
    "providers": {
      "ollama": {
        "baseUrl": "http://127.0.0.1:11434/v1",
        "apiKey": "ollama-local",
        "api": "openai-completions",
        "models": [...]
      }
    }
  }
}
```

## 📝 说明

虽然 Ollama 提供 `/v1/chat/completions` 端点，但 OpenClaw 的 Ollama provider 内部使用 `openai-completions` API 类型来映射这个端点。

## 🚀 下一步

1. 配置已修复为 `openai-completions`
2. **重启 OpenClaw 网关**让配置生效
3. 重启后应该可以正常工作了
