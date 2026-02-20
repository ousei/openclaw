# 修复 homes 文件夹访问问题

## 问题诊断

- ✅ 可以访问：`home`, `downloads`, `video`, `music`, `works`
- ❌ 无法访问：`homes`, `photo`
- 错误类型：`UnauthorizedAccessException`（权限不足）

## 根本原因

虽然你在 Synology DSM 中对 `homes` 文件夹有"完全控制"权限，但：
1. **权限未应用到子文件夹和文件** - 复选框"このフォルダ、サブフォルダ、ファイルに適用する"未勾选
2. **存在无效权限条目** - "不明なユーザー/グループ: 1028"可能导致冲突

## 解决步骤（在 Synology DSM 中操作）

### 步骤 1: 清理无效权限

1. 登录 Synology DSM 管理界面
2. 打开 **File Station**
3. 右键点击 `homes` 文件夹 → **プロパティ**（属性）
4. 切换到 **許可**（权限）标签页
5. 找到 **"不明なユーザー/グループ: 1028"** 这一行
6. 选中它，点击 **削除**（删除）
7. 点击 **保存**

### 步骤 2: 应用权限到子文件夹

1. 在同一个权限设置对话框中
2. **勾选** "このフォルダ、サブフォルダ、ファイルに適用する" 复选框
   - 这个复选框在权限列表下方
   - 勾选后，权限会应用到所有子文件夹和文件
3. 点击 **保存**

### 步骤 3: 验证修复

在 Windows 中测试：

```powershell
# 测试访问
Test-Path "\\nas\homes"

# 列出内容
Get-ChildItem "\\nas\homes" | Select-Object -First 5
```

## 如果仍然无法访问

### 方法 A: 清除 Windows 凭据缓存

```powershell
# 查看所有 nas 相关凭据
cmdkey /list | findstr nas

# 删除特定凭据（如果有）
cmdkey /delete:target:nas

# 或者删除所有网络凭据
cmdkey /list | ForEach-Object { if ($_ -match "nas") { cmdkey /delete:target:$matches[0] } }
```

然后在资源管理器中重新访问 `\\nas\homes`，输入凭据。

### 方法 B: 使用完整域名用户名连接

```powershell
# 断开所有 nas 连接
net use \\nas\* /delete /yes

# 使用完整域名用户名连接
net use \\nas\homes /user:weng@nas 你的密码 /persistent:yes
```

### 方法 C: 重置权限继承

在 Synology DSM 中：
1. File Station → 右键 `homes` → プロパティ
2. 許可标签页 → **詳細オプション**（详细选项）
3. 选择 **権限をリセット**（重置权限）或 **継承を有効にする**（启用继承）

## 注意事项

- `homes` 文件夹通常是 Synology 为每个用户创建的个人文件夹
- 它可能有特殊的访问控制，即使你对其他共享有权限
- 确保使用正确的用户名格式（`weng` 或 `weng@nas`）
