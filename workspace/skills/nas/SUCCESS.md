# NAS 访问配置成功 ✅

## 连接状态

### ✅ `\\nas\home`
- **用户名**: `weng`
- **密码**: `19801502`
- **状态**: ✅ 可以访问

### ✅ `\\nas\homes`
- **用户名**: `nas\weng`
- **密码**: `19801502`
- **状态**: ✅ **已成功配置并可以访问**

## 使用方法

### 在 OpenClaw 中使用

OpenClaw 现在可以直接访问 NAS 文件：

```powershell
# 访问 home 共享
Get-ChildItem "\\nas\home"

# 访问 homes 共享
Get-ChildItem "\\nas\homes"

# 读取文件
Get-Content "\\nas\homes\documents\file.txt"

# 写入文件
"Hello" | Out-File "\\nas\homes\documents\test.txt"
```

### 在资源管理器中访问

1. 按 `Windows + E` 打开资源管理器
2. 地址栏输入：
   - `\\nas\home` （使用 `weng` 用户名）
   - `\\nas\homes` （使用 `nas\weng` 用户名）
3. 输入密码：`19801502`
4. 勾选"记住我的凭据"

## 关键要点

1. **不同共享需要不同用户名格式**：
   - `home` → `weng`
   - `homes` → `nas\weng`

2. **凭据已保存**：
   - Windows 会记住凭据
   - 后续访问无需重复输入

3. **OpenClaw 可以直接使用**：
   - 使用 UNC 路径即可
   - 无需额外配置

## 故障排查

如果将来遇到访问问题：

1. **检查连接状态**：
   ```powershell
   net use
   ```

2. **重新连接**：
   ```powershell
   # 断开所有连接
   net use \\nas\* /delete /yes
   
   # 重新连接 homes
   net use \\nas\homes /user:nas\weng 19801502 /persistent:yes
   ```

3. **使用资源管理器**：
   - 最可靠的方法
   - 会自动处理凭据

## 配置完成时间

2026-01-31 - 成功配置 `\\nas\homes` 访问
