# OpenClaw Fork 设置指南 - 保留 UI 修改

本地已对 OpenClaw Control UI 做了修改（生成中显示交互信息，完成后根据设置隐藏）。以下步骤可让这些修改在升级时得以保留。

## 一、在 GitHub 上 Fork 仓库

1. 打开 https://github.com/openclaw/openclaw
2. 点击右上角 **Fork** 按钮
3. 选择你的 GitHub 账号作为 fork 目标

## 二、将修改推送到你的 Fork

在 PowerShell 中执行（**将 `YOUR_GITHUB_USERNAME` 替换为你的 GitHub 用户名**）：

```powershell
cd C:\Users\wengzheng\openclaw-src

# 添加你的 fork 为远程仓库
git remote add fork https://github.com/YOUR_GITHUB_USERNAME/openclaw.git

# 推送分支到你的 fork
git push -u fork feature/show-thinking-during-generation
```

如果已有 `fork` 远程，可先删除再添加：
```powershell
git remote remove fork
git remote add fork https://github.com/YOUR_GITHUB_USERNAME/openclaw.git
```

## 三、从你的 Fork 安装 OpenClaw

以后安装/升级时，使用你的 fork 而不是官方 npm 包：

```powershell
# 使用 pnpm（推荐，OpenClaw 使用 pnpm）
pnpm add -g openclaw@github:YOUR_GITHUB_USERNAME/openclaw#feature/show-thinking-during-generation

# 或使用 npm
npm install -g openclaw@github:YOUR_GITHUB_USERNAME/openclaw#feature/show-thinking-during-generation
```

`#feature/show-thinking-during-generation` 指定安装该分支。若你已将修改合并到 main，可省略 `#...`：

```powershell
pnpm add -g openclaw@github:YOUR_GITHUB_USERNAME/openclaw
```

## 四、同步上游更新（可选）

当 OpenClaw 官方有更新时，可合并到你的 fork：

```powershell
cd C:\Users\wengzheng\openclaw-src

# 拉取上游最新
git fetch origin
git checkout feature/show-thinking-during-generation
git merge origin/main

# 如有冲突，解决后再推送
git push fork feature/show-thinking-during-generation
```

然后重新安装：
```powershell
pnpm add -g openclaw@github:YOUR_GITHUB_USERNAME/openclaw#feature/show-thinking-during-generation
```

## 当前修改说明

- **文件**: `ui/src/ui/app-render.ts`
- **行为**: 生成中自动显示 thinking/tool 信息，结束后按用户设置决定是否显示
