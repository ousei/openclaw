# 修复 "missing" 模型问题

## 问题诊断

**症状**：
- `openclaw models list` 显示模型为 "missing"
- 错误：`Unknown model: ollama/deepseek-r1:14b`

**原因**：
1. `deepseek-r1:14b` **不支持工具（tools）**
2. OpenClaw 的自动发现机制只会保留支持工具的模型
3. 因此需要使用**显式配置**来强制包含这些模型

## ✅ 已应用的修复

### 1. 添加了显式 Ollama Provider 配置

在 `openclaw.json` 中添加了：
```json
{
  "models": {
    "providers": {
      "ollama": {
        "baseUrl": "http://127.0.0.1:11434/v1",
        "apiKey": "ollama-local",
        "models": [
          {
            "id": "deepseek-r1:14b",
            "name": "DeepSeek R1 14B",
            "reasoning": true,
            "contextWindow": 32768,
            "maxTokens": 327680
          },
          {
            "id": "deepseek-r1:7b",
            "name": "DeepSeek R1 7B",
            "reasoning": true,
            "contextWindow": 32768,
            "maxTokens": 327680
          },
          {
            "id": "llama3:latest",
            "name": "Llama 3",
            "reasoning": false,
            "contextWindow": 8192,
            "maxTokens": 81920
          }
        ]
      }
    }
  }
}
```

### 2. 环境变量已设置

`.env` 文件中：
```
OLLAMA_API_KEY=ollama-local
```

## 🔍 关键发现

**模型能力检查**：
- `deepseek-r1:14b`: ❌ 不支持工具，✅ 支持推理（reasoning）
- 这就是为什么自动发现跳过了它

**解决方案**：
- 使用显式配置强制包含这些模型
- 即使不支持工具，也可以用于基本对话

## 📋 配置说明

### baseUrl
- `http://127.0.0.1:11434/v1` - Ollama 的 OpenAI 兼容 API 端点
- `/v1` 后缀是必需的

### apiKey
- `ollama-local` - 任何值都可以（Ollama 不需要真实的 key）

### models 配置
- `id`: 模型在 Ollama 中的名称（不带 `ollama/` 前缀）
- `reasoning`: 是否支持推理（deepseek-r1 系列支持）
- `contextWindow`: 上下文窗口大小
- `maxTokens`: 最大输出 token 数（通常设为 contextWindow × 10）

## 🚀 下一步

1. **重启 OpenClaw 网关**：
   ```powershell
   # 停止当前运行的网关（Ctrl+C）
   # 然后重新启动
   cd C:\Users\wengzheng\.openclaw
   .\gateway.cmd
   ```

2. **验证配置**：
   ```powershell
   openclaw models list
   ```
   应该不再显示 "missing"

3. **测试模型**：
   重启后，OpenClaw 应该能够使用 `ollama/deepseek-r1:14b` 了

## ⚠️ 注意事项

- **工具支持**：虽然 `deepseek-r1:14b` 不支持工具，但可以用于基本对话和推理任务
- **性能**：14B 模型需要较多内存，确保有足够的 RAM
- **API 类型**：移除了 `"api": "openai-completions"`，让 OpenClaw 自动检测

## 🔧 如果仍然不工作

如果重启后仍然显示 "missing"，检查：

1. **Ollama 服务是否运行**：
   ```powershell
   Invoke-RestMethod -Uri "http://localhost:11434/api/tags"
   ```

2. **环境变量是否加载**：
   ```powershell
   $env:OLLAMA_API_KEY
   ```

3. **配置文件语法**：
   ```powershell
   Get-Content openclaw.json | ConvertFrom-Json
   ```
