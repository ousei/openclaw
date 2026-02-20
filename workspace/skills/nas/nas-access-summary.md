# NAS 访问总结

## 不同共享文件夹的访问方式

根据实际测试，不同的 NAS 共享文件夹需要使用不同的用户名格式：

### `\\nas\home` ✅

**连接命令：**
```powershell
net use \\nas\home /user:weng 19801502 /persistent:yes
```

**用户名格式：** `weng`（简单用户名）

**状态：** ✅ 可以成功连接

### `\\nas\homes` ✅

**连接命令：**
```powershell
net use \\nas\homes /user:nas\weng 19801502 /persistent:yes
```

**用户名格式：** `nas\weng`（域\用户名）

**状态：** ✅ 可以成功连接

## 常见错误

### 错误 1: "访问被拒绝"（アクセスが拒否されました）

**原因：**
- 使用了错误的用户名格式
- 例如：对 `\\nas\homes` 使用 `weng` 而不是 `nas\weng`

**解决方法：**
- 尝试使用不同的用户名格式：
  - `weng`
  - `nas\weng`
  - `weng@nas`

### 错误 2: "系统错误 1219"（システム エラー 1219）

**原因：**
- 同一个用户使用不同用户名建立了多个连接

**解决方法：**
```powershell
# 断开所有连接
net use \\nas\* /delete /yes

# 然后使用正确的格式重新连接
```

## 用户名格式对照表

| 共享文件夹 | 用户名格式 | 示例命令 |
|-----------|-----------|---------|
| `\\nas\home` | `weng` | `net use \\nas\home /user:weng 密码 /persistent:yes` |
| `\\nas\homes` | `nas\weng` | `net use \\nas\homes /user:nas\weng 密码 /persistent:yes` |

## 最佳实践

1. **先尝试简单用户名** (`weng`)
   - 如果成功，就用这个格式

2. **如果失败，尝试域格式** (`nas\weng`)
   - 很多共享文件夹需要这个格式

3. **使用资源管理器测试**
   - 在资源管理器中手动连接，Windows 会自动处理凭据格式
   - 连接成功后，PowerShell 也可以使用

4. **保存凭据**
   - 使用 `/persistent:yes` 参数保存连接
   - 或在资源管理器中勾选"记住我的凭据"

## 验证连接

```powershell
# 查看所有网络连接
net use

# 测试路径访问
Test-Path "\\nas\home"
Test-Path "\\nas\homes"

# 列出内容
Get-ChildItem "\\nas\home"
Get-ChildItem "\\nas\homes"
```
