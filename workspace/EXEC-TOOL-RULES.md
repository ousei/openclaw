# Exec Tool Rules - READ BEFORE USING exec TOOL

## 🚨 MANDATORY CHECKLIST

**Before calling `exec` tool with ANY PowerShell command:**

### Step 1: Check for `&&` operator

**Search your command for `&&` - if found, REPLACE with `;`**

❌ **WRONG:**
```json
{
  "tool": "exec",
  "command": "cd C:\\path && script.ps1"
}
```

✅ **CORRECT:**
```json
{
  "tool": "exec",
  "command": "cd C:\\path; script.ps1"
}
```

### Step 2: Verify semicolon usage

**All command separators must be `;` not `&&`**

### Step 3: Common patterns

| Pattern | Wrong (`&&`) | Correct (`;`) |
|---------|-------------|---------------|
| Change dir + script | `cd path && script` | `cd path; script` |
| Multiple commands | `cmd1 && cmd2 && cmd3` | `cmd1; cmd2; cmd3` |
| Set var + script | `$var=x && script` | `$var=x; script` |

## Weather Skill Example

**When user asks for weather:**

❌ **WRONG (will fail):**
```json
{
  "tool": "exec",
  "command": "cd C:\\Users\\wengzheng\\.openclaw\\workspace\\skills\\weather && .\\search_weather.ps1 \"Tokyo\"",
  "pty": false
}
```

✅ **CORRECT:**
```json
{
  "tool": "exec",
  "command": "cd C:\\Users\\wengzheng\\.openclaw\\workspace\\skills\\weather; .\\search_weather.ps1 \"Tokyo\"",
  "pty": false
}
```

## Error Message

If you see this error, you used `&&`:
```
トークン '&&' は、このバージョンでは有効なステートメント区切りではありません。
Token '&&' is not a valid statement separator in this version.
```

**Solution:** Replace `&&` with `;` and try again.

## Related Files

- `CRITICAL-POWERSHELL-RULE.md` - Critical PowerShell rules
- `POWERSHELL-RULES.md` - Complete PowerShell syntax guide
- `WEATHER-SKILL-USAGE.md` - Weather skill usage

---

**REMEMBER: Before every `exec` call, check for `&&` and replace with `;`!**
