# NAS 访问完整指南

## 当前配置

- **NAS 路径**: `\\nas\homes\weng`
- **用户名**: `nas\weng`
- **密码**: `19801502`

## 正确的访问步骤

### 步骤 1: 连接 NAS 共享

```powershell
# 清理旧连接（如果有）
net use * /delete /yes 2>$null

# 连接 homes 共享（注意：先连接 homes，不是 homes\weng）
net use \\nas\homes /user:nas\weng 19801502 /persistent:yes
```

### 步骤 2: 验证连接

```powershell
# 检查连接状态
net use | Select-String "\\\\nas"

# 测试路径访问
Test-Path "\\nas\homes\weng"
```

### 步骤 3: 访问文件

```powershell
# 列出 weng 目录内容
Get-ChildItem "\\nas\homes\weng"

# 访问子目录（使用正确的路径格式）
Get-ChildItem "\\nas\homes\weng\履歴書"
```

## 处理日文字符路径

### 问题：日文字符路径访问失败

**可能的原因：**
1. 路径编码问题
2. 路径不存在
3. 权限问题

### 解决方案

#### 方法 1: 使用 UTF-8 编码

```powershell
# 设置控制台编码为 UTF-8
[Console]::OutputEncoding = [System.Text.Encoding]::UTF8
$OutputEncoding = [System.Text.Encoding]::UTF8
chcp 65001 | Out-Null

# 然后访问路径
Get-ChildItem "\\nas\homes\weng\履歴書"
```

#### 方法 2: 先列出目录，找到正确的路径名

```powershell
# 列出 weng 目录下的所有内容
Get-ChildItem "\\nas\homes\weng" | Select-Object Name, FullName

# 查看是否有"履歴書"目录，注意大小写和字符
Get-ChildItem "\\nas\homes\weng" | Where-Object { $_.Name -like "*履歴*" }
```

#### 方法 3: 使用通配符搜索

```powershell
# 搜索包含特定字符的目录
Get-ChildItem "\\nas\homes\weng" -Directory | Where-Object { $_.Name -match "履歴" }
```

## 完整的访问脚本（已验证有效）

```powershell
# 步骤 1: 设置 UTF-8 编码（必须）
[Console]::OutputEncoding = [System.Text.Encoding]::UTF8
$OutputEncoding = [System.Text.Encoding]::UTF8
chcp 65001 | Out-Null

# 步骤 2: 连接 NAS 共享
net use \\nas\homes /user:nas\weng 19801502 /persistent:yes

# 步骤 3: 测试路径是否存在
$targetPath = "\\nas\homes\weng\履歴書"
if (Test-Path $targetPath) {
    Write-Host "✅ 路径存在！" -ForegroundColor Green
    
    # 步骤 4: 访问目录（使用变量，已验证有效）
    Get-ChildItem $targetPath
    
    # 或者使用反引号转义（也有效）
    # Get-ChildItem "`\\nas\homes\weng\履歴書"
    
    # 或者使用 -LiteralPath（如果上述方法失败）
    # Get-ChildItem -LiteralPath "\\nas\homes\weng\履歴書"
} else {
    Write-Host "路径不存在，列出所有目录..." -ForegroundColor Yellow
    Get-ChildItem "\\nas\homes\weng" -Directory | Select-Object Name
}
```

**已验证的有效方法：**
1. ✅ 使用变量存储路径：`$path = "\\nas\homes\weng\履歴書"; Get-ChildItem $path`
2. ✅ 使用反引号转义：`Get-ChildItem "`\\nas\homes\weng\履歴書"`
3. ✅ 使用 -LiteralPath：`Get-ChildItem -LiteralPath "\\nas\homes\weng\履歴書"`

## 常见问题排查

### 问题 1: 路径不存在

**检查方法：**
```powershell
# 列出所有目录，查看实际存在的目录名
Get-ChildItem "\\nas\homes\weng" -Directory | Select-Object Name
```

**可能的原因：**
- 目录名拼写错误
- 目录名使用了不同的字符（全角/半角）
- 目录确实不存在

### 问题 2: 编码问题

**解决方法：**
```powershell
# 设置 UTF-8 编码
[Console]::OutputEncoding = [System.Text.Encoding]::UTF8
chcp 65001 | Out-Null

# 或者使用 Get-ChildItem 的 -LiteralPath 参数
Get-ChildItem -LiteralPath "\\nas\homes\weng\履歴書"
```

### 问题 3: 权限问题

**检查方法：**
```powershell
# 测试基本访问
Test-Path "\\nas\homes\weng"

# 尝试列出内容
Get-ChildItem "\\nas\homes\weng" -ErrorAction Stop
```

## 推荐的最佳实践

1. **先连接共享**：使用 `net use` 连接 `\\nas\homes`
2. **设置编码**：在处理日文字符前设置 UTF-8 编码
3. **验证路径**：使用 `Test-Path` 检查路径是否存在
4. **列出内容**：如果不确定路径名，先列出目录内容
5. **使用通配符**：使用 `-like` 或 `-match` 搜索目录

## 快速参考

```powershell
# 1. 连接
net use \\nas\homes /user:nas\weng 19801502 /persistent:yes

# 2. 设置编码
[Console]::OutputEncoding = [System.Text.Encoding]::UTF8
chcp 65001 | Out-Null

# 3. 列出内容
Get-ChildItem "\\nas\homes\weng"

# 4. 访问子目录
Get-ChildItem "\\nas\homes\weng\履歴書"
```
