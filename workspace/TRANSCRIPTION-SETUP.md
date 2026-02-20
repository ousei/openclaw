# 本地语音转写环境（Whisper + ffmpeg）

本机已安装并配置好本地转写所需环境，OpenClaw 收到语音后可自动转成文字再处理。

## 已安装

| 组件 | 说明 |
|------|------|
| **ffmpeg** | 8.0.1（winget `Gyan.FFmpeg`），已加入系统 PATH |
| **openai-whisper** | pip 安装，提供 `whisper` 命令行，已加入用户 PATH（优先于 npm 的 whisper） |

## 使用说明

- **OpenClaw 语音消息**：发到 WhatsApp/其他通道的语音会先保存为音频文件，再由 openai-whisper 技能调用 `whisper` 转成文字，无需额外操作。
  - **多语言支持**：Whisper 会自动检测语言（支持中文、日文、英文等 99 种语言）
  - 如需手动指定语言，可在技能中添加 `--language zh`（中文）或 `--language ja`（日文）参数
  
- **手动转写**：在新开的终端里执行：
  ```bash
  # 自动检测语言
  whisper "路径/到/音频.mp3" --model base --output_format txt --output_dir .
  
  # 指定为中文
  whisper "路径/到/音频.mp3" --model base --language zh --output_format txt --output_dir .
  
  # 指定为日文
  whisper "路径/到/音频.mp3" --model base --language ja --output_format txt --output_dir .
  ```
  首次运行会下载模型到 `~/.cache/whisper`。

## 注意事项

1. **PATH 配置**：
   - 已将 Python Scripts 和 ffmpeg 加入**系统 PATH**（Machine PATH 最前面）
   - `gateway.cmd` 已配置正确的 PATH，Python Scripts 目录在最前面
   - 创建了 `whisper.cmd` 包装脚本确保调用 Python 的 `whisper.exe`
   - npm 的 `whisper`（无扩展名）已重命名为 `whisper.bak`，避免冲突
2. **语言识别**：Whisper 默认**自动检测语言**，支持中文（zh）、日文（ja）等 99 种语言。混合语言的音频也能正确识别。
3. **编码问题**：在 Windows 日文环境下，控制台输出可能有编码问题，但不影响转写文件本身（UTF-8 编码）。
4. **模型选择**：
   - `tiny`：最快，准确度较低
   - `base`：默认，平衡速度和准确度
   - `small/medium`：更准确，速度较慢
   - `large`：最准确，需要更多资源
   - 首次使用某模型会自动下载到 `~/.cache/whisper`
5. **OpenClaw 集成**：确保 OpenClaw 网关已重启，以加载新的 PATH 配置和 `whisper.cmd` 包装脚本。

## 验证

在新终端中执行：

```powershell
# 应看到 Python 的 whisper（或 Scripts 路径）
where.exe whisper

# 应看到 ffmpeg 版本
ffmpeg -version
```

若 `where whisper` 第一个结果是 `...\Python313\Scripts\whisper.exe`，说明环境正确。
