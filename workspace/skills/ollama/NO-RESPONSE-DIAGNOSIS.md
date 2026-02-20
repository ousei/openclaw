# Ollama 无响应问题诊断

## 问题现象

- ✅ OpenClaw 启动正常
- ✅ 模型配置正确（`ollama/deepseek-r1:14b`）
- ✅ 消息被接收（日志显示 `embedded run start`）
- ✅ 运行完成（日志显示 `embedded run done`）
- ❌ **但没有响应显示在界面上**

## 可能的原因

### 1. 模型返回空响应

`deepseek-r1:14b` 可能返回了空内容或只返回了 `<think>` 标签而没有实际文本。

### 2. API 端点不匹配

虽然配置了 `openai-completions`，但实际调用可能有问题。

### 3. 响应格式问题

Ollama 的响应格式可能与 OpenClaw 期望的格式不匹配。

## 解决方案

### 方案 1：测试模型响应

直接测试 Ollama API 是否返回内容：

```powershell
$body = @{
    model = 'deepseek-r1:14b'
    prompt = '你好'
    max_tokens = 50
} | ConvertTo-Json

Invoke-RestMethod -Uri 'http://localhost:11434/v1/completions' -Method POST -Body $body -ContentType 'application/json'
```

### 方案 2：切换到更小的模型

`deepseek-r1:14b` 是推理模型，可能响应格式特殊。尝试使用 `llama3:latest`：

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

### 方案 3：检查响应内容

查看会话文件，确认是否有响应消息被保存：

```powershell
Get-Content "C:\Users\wengzheng\.openclaw\agents\main\sessions\20277525-ed42-453c-b298-678e7547fe90.jsonl" | Select-String -Pattern "04:07" | Select-Object -Last 10
```

## 下一步

1. **先测试 Ollama API 直接调用**，确认模型能返回内容
2. **如果 API 正常**，问题可能在 OpenClaw 的响应处理
3. **如果 API 也返回空**，可能是模型配置问题
