---
name: weather
description: Search weather information for any location using SearXNG local search. Returns JSON formatted results from web search.
metadata: {"clawdbot":{"emoji":"🌤️","requires":{"bins":["curl"]},"always":true}}
---

# Weather 🌤️

Search weather information for any location using SearXNG.

## ⚠️ CRITICAL: How to Use This Skill

**🚨 POWERShell SYNTAX WARNING: NEVER USE `&&` OPERATOR!**

**When a user asks for weather information, you MUST use the `exec` tool to call the PowerShell script:**

### ✅ CORRECT Command (Use semicolon `;`):

**Method 1: Positional parameter (RECOMMENDED)**
```powershell
cd C:\Users\wengzheng\.openclaw\workspace\skills\weather; .\search_weather.ps1 "Tokyo"
```

**Method 2: Named parameter**
```powershell
cd C:\Users\wengzheng\.openclaw\workspace\skills\weather; .\search_weather.ps1 -weatherLocation "Tokyo"
```

### ❌ WRONG Commands:

```powershell
# ❌ WRONG: PowerShell does NOT support &&
cd C:\Users\wengzheng\.openclaw\workspace\skills\weather && .\search_weather.ps1 "Tokyo"

# ❌ WRONG: Parameter name is -weatherLocation, NOT -Location
cd C:\Users\wengzheng\.openclaw\workspace\skills\weather; .\search_weather.ps1 -Location "Tokyo"
```

**Exec tool format:**
- Command: `cd C:\Users\wengzheng\.openclaw\workspace\skills\weather; .\search_weather.ps1 "Tokyo"`
- Or: `cd C:\Users\wengzheng\.openclaw\workspace\skills\weather; .\search_weather.ps1 -weatherLocation "Tokyo"`
- Set `pty: false` to avoid screenshot errors
- **MANDATORY: Use semicolon `;` NOT `&&`**
- **MANDATORY: Parameter name is `-weatherLocation` NOT `-Location`**

**The script will:**
1. Search for weather information using SearXNG
2. Extract results from HTML (bypasses bot detection)
3. Return JSON formatted results
4. **NO temporary files are created**

**You DO NOT need `web_fetch` tool** - this skill uses SearXNG search instead!

## Usage

### ✅ Correct Usage (PowerShell)

```powershell
# Method 1: Using parameter name
.\search_weather.ps1 -weatherLocation "Tokyo"

# Method 2: Positional parameter
.\search_weather.ps1 "Tokyo"

# Method 3: Multiple commands (use semicolon, NOT &&)
cd C:\Users\wengzheng\.openclaw\workspace\skills\weather; .\search_weather.ps1 "Tokyo"
```

### ❌ Wrong Usage (DO NOT USE)

```powershell
# ❌ ERROR: PowerShell does NOT support &&
.\search_weather.ps1 $weatherLocation="Tokyo" && echo "Done"

# ❌ ERROR: Wrong parameter syntax
.\search_weather.ps1 $weatherLocation="Tokyo"
```

## Important: PowerShell Syntax Rules

**⚠️ CRITICAL: PowerShell does NOT support `&&` operator!**

- ❌ **Wrong**: `command1 && command2`
- ✅ **Correct**: `command1; command2`
- ✅ **Correct**: Use line breaks

## Examples

```
"Search weather for Tokyo"
"Get weather information for New York"
"What's the weather in London?"
```

## Features

- ✅ **Uses SearXNG to fetch actual web search results** (extracts from HTML)
- ✅ Returns JSON formatted results (no temporary files)
- ✅ Supports any location worldwide
- ✅ Privacy-focused (uses local SearXNG instance)
- ✅ Extracts title, URL, and snippet from search results

## Configuration

The script uses SearXNG at `http://localhost:18888` by default.

**How it works:**
1. Fetches HTML page from SearXNG search results
2. Extracts search result links and titles from HTML
3. Returns JSON formatted data (no temporary files created)
4. Filters out SearXNG internal links

**Output format:**
```json
[
    {
        "Title": "Weather Site Title",
        "URL": "https://weather.example.com",
        "Snippet": "Weather description..."
    }
]
```
