# Ollama 本地模型配置

## 已安装的模型

根据 `ollama list` 输出，你已安装以下模型：

1. **llama3:latest** (4.7 GB) - ✅ 已设置为主要模型
2. **deepseek-r1:7b** (4.7 GB) - ✅ 已设置为备用模型 1
3. **llama3.2:3b-instruct-q5_K_M** (2.3 GB) - ✅ 已设置为备用模型 2
4. **deepseek-r1:14b** (9.0 GB) - 可用（较大，速度较慢）
5. **llama3-groq-tool-use:latest** (4.7 GB) - 可用
6. **summerwind/japanese-starling-chatv:latest** (4.4 GB) - 可用（日语支持）
7. **smollm2:135m** (270 MB) - 可用（最小，速度最快）
8. **hf.co/mmnga/cyberagent-DeepSeek-R1-Distill-Qwen-14B-Japanese-gguf:latest** (9.0 GB) - 可用（日语支持）

## 当前配置

**主要模型**: `ollama/llama3:latest`
**备用模型**:
1. `ollama/deepseek-r1:7b`
2. `ollama/llama3.2:3b-instruct-q5_K_M`

## 模型选择建议

### 性能优先（快速响应）
- `smollm2:135m` - 最小最快，但能力有限
- `llama3.2:3b-instruct-q5_K_M` - 平衡选择

### 能力优先（更好的回答质量）
- `llama3:latest` - 当前主要模型 ✅
- `deepseek-r1:7b` - 当前备用模型 ✅
- `deepseek-r1:14b` - 更强但更慢

### 日语支持
- `summerwind/japanese-starling-chatv:latest`
- `hf.co/mmnga/cyberagent-DeepSeek-R1-Distill-Qwen-14B-Japanese-gguf:latest`

## 切换模型

如果需要切换主要模型，编辑 `openclaw.json`：

```json
"model": {
  "primary": "ollama/模型名称",
  "fallbacks": ["ollama/备用模型1", "ollama/备用模型2"]
}
```

## 测试 Ollama 服务

```powershell
# 检查 Ollama 服务状态
ollama list

# 测试 API
$body = @{model='llama3:latest'; prompt='Hello'} | ConvertTo-Json
Invoke-RestMethod -Uri 'http://localhost:11434/api/generate' -Method POST -Body $body -ContentType 'application/json'
```

## 常见问题

### Ollama 服务未运行
```powershell
# 启动 Ollama（如果作为服务安装）
# 或者直接运行 ollama serve
```

### 模型未下载
```powershell
# 拉取模型
ollama pull llama3:latest
ollama pull deepseek-r1:7b
```

### 性能问题
- 较小的模型（如 llama3.2:3b）响应更快
- 较大的模型（如 deepseek-r1:14b）质量更好但更慢
- 根据你的硬件选择合适的模型

## 优势

✅ **免费** - 无需 API 费用
✅ **隐私** - 数据不离开本地
✅ **无限制** - 无配额限制
✅ **离线** - 无需网络连接

## 注意事项

⚠️ **性能** - 本地模型可能比云端 API 慢
⚠️ **资源** - 需要足够的 RAM 和 GPU（如果可用）
⚠️ **质量** - 较小的模型可能不如 GPT-5.1 强大
