# Ollama 配置总结

## ✅ 已完成的配置

### 1. 环境变量配置
- ✅ 在 `.env` 文件中添加了 `OLLAMA_API_KEY=ollama-local`
- ✅ OpenClaw 会自动读取 `.env` 文件中的环境变量

### 2. 模型配置
- ✅ 主要模型：`ollama/deepseek-r1:14b`
- ✅ 备用模型 1：`ollama/deepseek-r1:7b`
- ✅ 备用模型 2：`ollama/llama3:latest`

### 3. 配置方式
根据 OpenClaw 文档，使用了**自动发现模式**：
- 设置了 `OLLAMA_API_KEY` 环境变量
- **没有**显式定义 `models.providers.ollama`
- OpenClaw 会自动从 `http://127.0.0.1:11434` 发现模型

## 📋 配置详情

### 环境变量（`.env` 文件）
```
OLLAMA_API_KEY=ollama-local
```

### 模型配置（`openclaw.json`）
```json
{
  "agents": {
    "defaults": {
      "model": {
        "primary": "ollama/deepseek-r1:14b",
        "fallbacks": [
          "ollama/deepseek-r1:7b",
          "ollama/llama3:latest"
        ]
      }
    }
  }
}
```

## 🔍 模型发现机制

OpenClaw 会自动：
1. 查询 `http://127.0.0.1:11434/api/tags` 获取模型列表
2. 查询 `/api/show` 检查每个模型的能力
3. 只保留支持工具（tools）的模型
4. 标记推理（reasoning）能力（如果模型支持 thinking）
5. 读取上下文窗口大小
6. 设置所有成本为 $0（因为是本地模型）

## ⚠️ 重要注意事项

1. **模型必须支持工具**：OpenClaw 只会自动发现支持工具（tools）的模型
2. **Ollama 服务必须运行**：确保 `ollama serve` 正在运行
3. **模型名称格式**：使用 `ollama/model-name` 格式（如 `ollama/deepseek-r1:14b`）

## 🚀 下一步

1. **重启 OpenClaw 网关**：
   ```powershell
   # 停止当前运行的网关（Ctrl+C）
   # 然后重新启动
   cd C:\Users\wengzheng\.openclaw
   .\gateway.cmd
   ```

2. **验证模型可用性**：
   ```powershell
   # 检查 Ollama 服务
   ollama list
   
   # 检查 OpenClaw 是否发现模型
   openclaw models list
   ```

3. **如果模型未发现**：
   - 确保模型支持工具能力
   - 或者使用显式配置（见下面的备选方案）

## 🔧 备选方案：显式配置

如果自动发现不工作，可以使用显式配置：

```json
{
  "models": {
    "providers": {
      "ollama": {
        "baseUrl": "http://127.0.0.1:11434/v1",
        "apiKey": "ollama-local",
        "api": "openai-completions",
        "models": [
          {
            "id": "deepseek-r1:14b",
            "name": "DeepSeek R1 14B",
            "reasoning": true,
            "input": ["text"],
            "cost": {
              "input": 0,
              "output": 0,
              "cacheRead": 0,
              "cacheWrite": 0
            },
            "contextWindow": 32768,
            "maxTokens": 327680
          }
        ]
      }
    }
  }
}
```

## 📚 参考文档

- OpenClaw Ollama Provider: https://docs.clawd.bot/providers/ollama
- Ollama 官方文档: https://docs.ollama.com/
