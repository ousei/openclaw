# Ollama 无响应问题排查

## 当前状态

✅ **配置正确**：
- `api: "openai-completions"` ✅
- `baseUrl: "http://127.0.0.1:11434/v1"` ✅
- 模型列表显示正常 ✅
- Ollama API 测试成功 ✅

❌ **问题**：
- OpenClaw 启动后没有响应
- 日志显示 `embedded run start` 但没有看到完成

## 可能的原因

1. **模型调用卡住**：`deepseek-r1:14b` 可能需要很长时间才能响应
2. **API 端点不匹配**：虽然 `/v1/completions` 可用，但 OpenClaw 可能期望不同的格式
3. **配置未生效**：需要完全重启 OpenClaw

## 解决方案

### 1. 检查运行状态

查看日志中是否有错误：
```powershell
Get-Content "C:\tmp\openclaw\openclaw-2026-01-31.log" -Tail 50 | Select-String -Pattern "error|Error|done|done"
```

### 2. 测试简单模型

尝试使用更小的模型（响应更快）：
```json
{
  "agents": {
    "defaults": {
      "model": {
        "primary": "ollama/llama3:latest",
        "fallbacks": []
      }
    }
  }
}
```

### 3. 完全重启 OpenClaw

1. 停止 OpenClaw（Ctrl+C）
2. 等待几秒
3. 重新启动：
   ```powershell
   cd C:\Users\wengzheng\.openclaw
   .\gateway.cmd
   ```

### 4. 检查模型响应时间

`deepseek-r1:14b` 是一个大模型，首次调用可能需要很长时间。如果一直卡住，可能是：
- 模型正在加载（首次使用）
- 推理过程很慢
- 需要等待更长时间

### 5. 使用支持工具的模型

根据文档，OpenClaw 的自动发现只保留支持工具的模型。`deepseek-r1:14b` 可能不支持工具，所以虽然配置了，但可能无法正常工作。

尝试使用明确支持工具的模型：
```json
{
  "agents": {
    "defaults": {
      "model": {
        "primary": "ollama/llama3:latest"
      }
    }
  }
}
```

## 下一步

1. **先尝试使用 `llama3:latest`**（更小、更快、可能支持工具）
2. **如果还是没反应**，检查日志看是否有超时或错误
3. **如果模型调用成功但没返回**，可能是前端显示问题
