# 🚨 CRITICAL: PowerShell Syntax Rule - READ THIS FIRST!

## ⚠️ MANDATORY RULE - NO EXCEPTIONS

**BEFORE executing ANY PowerShell command via `exec` tool, you MUST check:**

### ❌ NEVER USE `&&` OPERATOR - IT WILL FAIL!

**PowerShell does NOT support `&&` operator. Using it will cause this error:**
```
トークン '&&' は、このバージョンでは有効なステートメント区切りではありません。
Token '&&' is not a valid statement separator in this version.
```

## ✅ ALWAYS USE SEMICOLON `;` INSTEAD

### Weather Skill Example:

**❌ WRONG (will fail):**
```powershell
cd C:\Users\wengzheng\.openclaw\workspace\skills\weather && .\search_weather.ps1 "Tokyo"
```

**✅ CORRECT (use semicolon):**
```powershell
cd C:\Users\wengzheng\.openclaw\workspace\skills\weather; .\search_weather.ps1 "Tokyo"
```

## Quick Reference

| Wrong (`&&`) | Correct (`;`) |
|-------------|---------------|
| `cd path && script` | `cd path; script` |
| `cmd1 && cmd2 && cmd3` | `cmd1; cmd2; cmd3` |
| `$var = "x" && script` | `$var = "x"; script` |

## Before Every exec Command

1. Check if command contains `&&`
2. If yes, replace ALL `&&` with `;`
3. Verify the command uses `;` not `&&`
4. Then execute

## This Rule Applies To:

- ✅ Weather skill calls
- ✅ All PowerShell commands
- ✅ All `exec` tool calls
- ✅ Every single PowerShell command

## Related Files

- `POWERSHELL-RULES.md` - Complete PowerShell syntax guide
- `.cursor/rules/powershell-no-ampersand.mdc` - Cursor rule
- `WEATHER-SKILL-USAGE.md` - Weather skill usage

---

**REMEMBER: PowerShell = Use `;` NOT `&&`!**
