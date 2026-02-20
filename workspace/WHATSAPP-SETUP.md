# 用 WhatsApp 指挥 OpenClaw — 设置说明

## 当前状态

- **WhatsApp 通道**：已启用、已链接、运行中
- **私信策略 (dmPolicy)**：`pairing` — 新号码需先配对才能指挥
- **群组策略 (groupPolicy)**：`allowlist` — 仅允许名单内的群

---

## 方式一：配对模式（当前）

适合「只让信任的人用 WhatsApp 指挥」。

1. **确保网关在运行**  
   已用 `gateway.cmd` 或 `openclaw gateway` 启动即可。

2. **用你的手机给 OpenClaw 的 WhatsApp 号发一条消息**  
   - 会收到一条**配对码**（短数字/字母）。

3. **在本机执行配对**（在电脑上打开终端）：
   ```bash
   openclaw pairing approve whatsapp <收到的配对码>
   ```
   例如：`openclaw pairing approve whatsapp A1B2C3`

4. **之后**：该 WhatsApp 号码发来的私信都会交给 OpenClaw 处理，即可指挥。

**查看待配对请求：**
```bash
openclaw pairing list whatsapp
```

---

## 方式二：白名单模式（推荐，仅自己指挥）

适合「只有我自己的号码能指挥，不想每次配对」。

在 `~/.openclaw/openclaw.json` 的 `channels.whatsapp` 里设置：

- `dmPolicy`: `"allowlist"`
- `allowFrom`: 你的手机号列表（E.164，如 `+8613800138000`）

示例：

```json
"channels": {
  "whatsapp": {
    "dmPolicy": "allowlist",
    "allowFrom": ["+8108035015968"],
    "selfChatMode": false,
    "groupPolicy": "allowlist",
    "mediaMaxMb": 50,
    "debounceMs": 0
  }
}
```

保存后**重启 OpenClaw 网关**，之后只有 `allowFrom` 里的号码发私信会触发 agent。

---

## 群组里用 WhatsApp 指挥

- 当前：`groupPolicy: "allowlist"`，默认**不允许任何群**，除非在配置里加了群名单。
- 若要在某个群指挥：
  - 在 `channels.whatsapp.groups` 里加入该群的 JID，或
  - 设 `"*"` 允许所有群（不太安全，慎用）。
- 群内需 **@ 提及 OpenClaw** 才会回复（避免刷屏）。

---

## 常用命令

| 目的 | 命令 |
|------|------|
| 查看通道状态 | `openclaw channels status` |
| 查看待配对 | `openclaw pairing list whatsapp` |
| 批准配对 | `openclaw pairing approve whatsapp <code>` |
| 重新扫码登录 WhatsApp | `openclaw channels login` |
| 网关健康检查 | `openclaw gateway health` |

---

## 小结

- **已链接**：用手机给 OpenClaw 的 WhatsApp 发一条消息 → 收到配对码 → 在本机执行 `openclaw pairing approve whatsapp <code>`，即可用该号码指挥。
- **只想自己指挥**：在配置里设 `dmPolicy: "allowlist"` 和 `allowFrom: ["+你的号码"]`，重启网关即可。

---

## 故障排除：WhatsApp 能收、但发出去的消息 OpenClaw 收不到

1. **号码格式（日本）**  
   日本 E.164 是 `+81` 后接**不带前导 0** 的号码。例如 080-3501-5968 → `+818035015968`（不是 `+8108035015968`）。  
   已在 `allowFrom` 里同时放了两种写法：`+818035015968` 和 `+8108035015968`，任一种匹配都会放行。

2. **改完配置要重启网关**  
   修改 `openclaw.json` 后，需要**重启 OpenClaw 网关**（结束进程再重新运行 `gateway.cmd` 或 `openclaw gateway`），新的 allowlist 才会生效。

3. **确认是否“自己给自己”发（同号）**  
   若 OpenClaw 登录的就是你日常用的那个 WhatsApp 号（同一号码、多端登录），属于“自己给自己”发消息。  
   在 `channels.whatsapp` 里加上：`"selfChatMode": true`，保存并重启网关后再试。

4. **临时用 open 排查**  
   若仍收不到，可**临时**把 `dmPolicy` 改成 `"open"`，重启网关后从 WhatsApp 再发一条。  
   - 若这时能收到：多半是白名单/号码格式问题，再改回 `allowlist` 并核对 `allowFrom` 和号码格式。  
   - 若 open 时也收不到：问题在连接或 Baileys，可看下面日志。

5. **看网关日志**  
   在本机执行：`openclaw logs --follow`，再从 WhatsApp 发一条消息。  
   看是否有 `Blocked`、`pairing`、`whatsapp`、`inbound` 等字样，便于判断是被拦截还是根本没进网关。
