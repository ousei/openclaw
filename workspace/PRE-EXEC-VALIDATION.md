# 执行前验证规则

## 🎯 目标

在执行任何 `exec` 工具调用前，自动验证命令以避免常见错误。

## 📋 验证步骤

### 步骤 1: PowerShell 语法验证

**检查项：**
- [ ] 命令中不包含 `&&` 运算符
- [ ] 使用 `;` 或换行分隔命令

**验证代码：**
```powershell
if ($command -match '&&') {
    # ERROR: Contains && operator
    # Replace with ;
    $command = $command -replace '&&', ';'
}
```

### 步骤 2: Weather Skill 参数验证

**检查项：**
- [ ] 如果调用 `search_weather.ps1`，参数名正确
- [ ] 使用 `-weatherLocation` 或位置参数
- [ ] 不使用 `-Location`

**验证代码：**
```powershell
if ($command -match 'search_weather\.ps1.*-Location(?!\w)') {
    # ERROR: Wrong parameter name
    # Replace -Location with -weatherLocation or use positional
    $command = $command -replace '-Location\s+"([^"]+)"', '-weatherLocation "$1"'
}
```

### 步骤 3: Web Fetch 工具验证

**检查项：**
- [ ] 不尝试使用 `web_fetch` 工具
- [ ] 使用 SearXNG skills 替代

**验证逻辑：**
- 如果需要网页数据，使用 `weather` 或 `local-search` skill
- 不要调用 `web_fetch` 工具

### 步骤 4: NAS 路径验证

**检查项：**
- [ ] NAS 路径使用变量
- [ ] 不直接写 `\\nas`

**验证代码：**
```powershell
if ($command -match '\\\\nas[^$]') {
    # WARNING: Direct NAS path detected
    # Should use variable instead
    Write-Host "WARNING: Consider using variable for NAS path"
}
```

### 步骤 5: PowerShell 关键字验证

**检查项：**
- [ ] 所有 cmdlet 使用英文
- [ ] 只有字符串值可以使用中文

**验证逻辑：**
- 检查常见中文关键字（排序对象、格式化表格等）
- 确保使用英文等价物

## 🔧 自动修复建议

### 自动修复规则

1. **`&&` → `;`**: 自动替换
2. **`-Location` → `-weatherLocation`**: 自动替换（仅限 weather skill）
3. **NAS 路径**: 建议使用变量（需要手动修复）

### 不能自动修复的

- Web Fetch 工具使用（需要改用 skill）
- PowerShell 中文关键字（需要手动替换）

## 📝 实施建议

### 在 Agent 中实施

1. **在执行前验证**：检查命令是否符合规则
2. **自动修复**：如果可以安全修复，自动修复
3. **提示警告**：如果无法自动修复，提示用户

### 验证函数示例

```powershell
function Validate-Command {
    param([string]$command)
    
    $errors = @()
    $warnings = @()
    
    # Check for &&
    if ($command -match '&&') {
        $errors += "Command contains && operator. Use ; instead."
    }
    
    # Check weather skill parameter
    if ($command -match 'search_weather\.ps1.*-Location(?!\w)') {
        $errors += "Wrong parameter name. Use -weatherLocation or positional parameter."
    }
    
    # Check NAS path
    if ($command -match '\\\\nas[^$]') {
        $warnings += "Consider using variable for NAS path instead of direct path."
    }
    
    return @{
        Valid = ($errors.Count -eq 0)
        Errors = $errors
        Warnings = $warnings
    }
}
```

## 🎯 优先级

1. **Critical**: `&&` 运算符（会导致命令失败）
2. **High**: Weather skill 参数（会导致命令失败）
3. **Medium**: NAS 路径（可能导致问题）
4. **Low**: PowerShell 关键字（可能导致问题）

## 📚 相关文档

- `ERROR-PREVENTION-CHECKLIST.md` - 完整检查清单
- `CRITICAL-POWERSHELL-RULE.md` - PowerShell 关键规则
- `WEATHER-SKILL-USAGE.md` - Weather skill 使用指南

---

**记住：验证后再执行！**
