# Ollama 配置最终修复

## 错误信息

```
Error: Unhandled API in mapOptionsForApi: undefined
```

## 原因

显式配置 Ollama provider 时，**必须**指定 `api` 字段，否则 OpenClaw 无法确定使用哪个 API 端点。

## ✅ 最终配置

### `openclaw.json`

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
          },
          {
            "id": "deepseek-r1:7b",
            "name": "DeepSeek R1 7B",
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
          },
          {
            "id": "llama3:latest",
            "name": "Llama 3",
            "reasoning": false,
            "input": ["text"],
            "cost": {
              "input": 0,
              "output": 0,
              "cacheRead": 0,
              "cacheWrite": 0
            },
            "contextWindow": 8192,
            "maxTokens": 81920
          }
        ]
      }
    }
  }
}
```

### `.env` 文件

```
OLLAMA_API_KEY=ollama-local
```

## 🔑 关键配置项

1. **`baseUrl`**: `http://127.0.0.1:11434/v1` - 必须包含 `/v1` 后缀
2. **`apiKey`**: `ollama-local` - 任何值都可以
3. **`api`**: `openai-completions` - **必需**，指定 API 类型
4. **`models`**: 显式定义模型列表

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
   应该不再显示 "missing"，也不再出现 API undefined 错误

3. **测试模型**：
   重启后，OpenClaw 应该能够正常使用 `ollama/deepseek-r1:14b` 了

## 📝 配置说明

- **为什么需要显式配置**：`deepseek-r1:14b` 不支持工具，自动发现会跳过它
- **为什么需要 `api` 字段**：OpenClaw 需要知道使用哪个 API 端点类型
- **`openai-completions` vs `openai-chat`**：根据文档示例，使用 `openai-completions`

## ✅ 配置完成

现在配置应该完整了：
- ✅ 环境变量已设置
- ✅ Provider 配置已添加
- ✅ API 类型已指定
- ✅ 模型列表已定义

重启后应该可以正常工作了！
