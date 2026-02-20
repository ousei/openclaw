# Ollama Pro + 多模态模型配置

参考 [Ollama OpenClaw 官方文档](https://docs.ollama.com/integrations/openclaw) 完成配置。

## ✅ 已配置的模型

### 文本模型（Ollama Pro Cloud）
| 模型 | 说明 |
|------|------|
| `qwen3-coder:480b-cloud` | 主模型，480B 参数，编程与代理任务 |
| `gpt-oss:120b-cloud` | 备用，120B |
| `gpt-oss:20b-cloud` | 备用，20B |
| `glm-5:cloud` | 备用，推理与代码生成 |

### 本地模型
| 模型 | 说明 |
|------|------|
| `ministral-3:14b` / `8b` | 备用 |
| `qwen3:14b` | 备用 |
| `glm-4.7` | 推理与代码生成 |

### 多模态模型（支持图文）
| 模型 | 说明 |
|------|------|
| `qwen3-vl:235b-cloud` | 云端视觉语言模型，支持图像输入 |
| `qwen3-vl:32b` | 本地视觉语言模型 |

## 前置条件

### 1. Ollama Pro 登录

Cloud 模型需在 ollama.com 登录：

```powershell
ollama signin
```

按提示完成登录后，本地 Ollama 会将 Cloud 模型请求转发到云端。

### 2. 拉取模型（首次使用）

```powershell
# Cloud 模型（登录后自动使用云端，可不拉取）
ollama pull qwen3-coder:480b-cloud
ollama pull gpt-oss:120b-cloud
ollama pull qwen3-vl:235b-cloud

# 本地模型
ollama pull ministral-3:14b
ollama pull glm-4.7
ollama pull qwen3-vl:32b
```

### 3. 确保 Ollama 运行

```powershell
ollama serve
# 或通过系统托盘/服务启动
```

## 切换多模态模型

当对话包含图片时，可将主模型临时改为 `qwen3-vl:235b-cloud`：

- 在 Control UI 的 Sessions 中修改当前会话模型，或
- 修改 `openclaw.json` 的 `agents.defaults.model.primary` 为 `ollama/qwen3-vl:235b-cloud`

## 验证配置

```powershell
# 检查 Ollama 模型列表
ollama list

# 检查 OpenClaw 识别的模型
openclaw models list

# 测试 Cloud 模型
ollama run qwen3-coder:480b-cloud "Hello"
```

## 重启网关

修改配置后需重启：

```powershell
# 停止当前 gateway.cmd (Ctrl+C)
# 重新启动
cd C:\Users\wengzheng\.openclaw
.\gateway.cmd
```

## 参考链接

- [Ollama OpenClaw 集成](https://docs.ollama.com/integrations/openclaw)
- [Ollama Cloud 模型](https://ollama.com/search?c=cloud)
- [OpenClaw 配置参考](https://docs.openclaw.ai/gateway/configuration)
