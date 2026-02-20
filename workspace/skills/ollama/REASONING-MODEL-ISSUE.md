# 推理模型响应问题

## 问题发现

测试 `deepseek-r1:14b` API 调用时发现：
- ✅ API 调用成功
- ❌ 响应包含 `<think>...</think>` 标签（推理模型的思考过程）
- ❌ 文本内容被编码成乱码
- ❌ OpenClaw 可能无法正确处理这种格式

## 原因

`deepseek-r1:14b` 是**推理模型**（reasoning model），它的响应格式与普通模型不同：
- 包含 `<think>` 标签用于展示推理过程
- OpenClaw 可能无法正确解析这种格式
- 或者响应被过滤掉了（因为只包含思考标签而没有实际文本）

## ✅ 解决方案

### 方案 1：使用非推理模型（推荐）

切换到 `llama3:latest`：

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

### 方案 2：等待 OpenClaw 更新

如果未来 OpenClaw 支持推理模型的响应格式，可以再切换回 `deepseek-r1:14b`。

## 当前状态

已切换到 `llama3:latest`，请重启 OpenClaw 并测试。
