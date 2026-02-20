# Anthropic API Key 配置说明

## 当前状态

**日期**: 2026-02-03

### 问题
OpenClaw 报告找不到 Anthropic API key，但当前配置使用的是本地 Ollama 模型，不需要 Anthropic。

### 解决方案

已在 `auth-profiles.json` 中添加了一个占位符 API key，以避免错误提示。

**占位符**: `sk-ant-placeholder-not-used-currently-using-local-ollama-models`

## 当前模型配置

**主要模型**: `ollama/ministral-3:14b` (本地)
**备用模型**: 
- `ollama/ministral-3:8b` (本地)
- `ollama/qwen3:14b` (本地)

**不需要 Anthropic API key**，因为使用的是本地 Ollama 模型。

## 如果将来需要使用 Anthropic

如果将来需要切换到 Anthropic 模型（如 `anthropic/claude-opus-4-5`），需要：

1. **获取 Anthropic API Key**:
   - 访问 https://console.anthropic.com/
   - 创建账户并获取 API key

2. **更新 auth-profiles.json**:
   ```json
   {
     "profiles": {
       "anthropic:default": {
         "type": "api_key",
         "provider": "anthropic",
         "key": "sk-ant-your-real-api-key-here"
       }
     }
   }
   ```

3. **更新 openclaw.json**:
   ```json
   {
     "agents": {
       "defaults": {
         "model": {
           "primary": "anthropic/claude-opus-4-5",
           "fallbacks": ["ollama/ministral-3:14b"]
         }
       }
     }
   }
   ```

## 当前错误已解决

✅ 已添加占位符 API key，错误应该不再出现。

**注意**: 占位符不会实际调用 Anthropic API，因为当前配置使用的是本地 Ollama 模型。
