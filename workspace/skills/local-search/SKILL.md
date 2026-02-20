---
name: local-search
description: Local web search using SearXNG or custom search engines. Privacy-focused alternative to Brave Search API.
metadata: {"clawdbot":{"emoji":"🔍","requires":{"bins":["curl","jq"]}}}
---

# Local Search 🔍

Privacy-focused local web search using SearXNG or custom search engines.

## Features

- ✅ No API keys required
- ✅ No rate limits
- ✅ Privacy-focused (searches don't go through commercial APIs)
- ✅ Supports multiple search engines via SearXNG
- ✅ Completely local deployment option

## Setup

### Option 1: SearXNG (Recommended)

1. **Install Docker** (if not already installed)

2. **Deploy SearXNG**:
   ```powershell
   # Create directory
   mkdir C:\searxng
   cd C:\searxng
   
   # Create docker-compose.yml (see LOCAL-SEARCH-SETUP.md)
   # Start service
   docker-compose up -d
   ```

3. **Verify it's running**:
   ```powershell
   # Test API
   curl "http://localhost:8888/search?q=test&format=json"
   ```

### Option 2: Custom Search Engine

See `LOCAL-SEARCH-SETUP.md` for Meilisearch + crawler setup.

## Usage Examples

```
"Search for Python tutorials using local search"
"Find information about machine learning locally"
"Local search for latest AI news"
```

## Configuration

The search endpoint defaults to `http://localhost:18888` (SearXNG port).

To change it, modify the script or set environment variable:

```powershell
$env:SEARXNG_URL = "http://your-searxng-instance:18888"
```

## How It Works

**Important:** This script uses HTML extraction method to work around SearXNG's bot detection:
1. Fetches HTML page from SearXNG search results
2. Extracts search result links and titles from HTML using regex
3. Returns JSON formatted data (no temporary files created)
4. Filters out SearXNG internal links

## Output Format

Returns JSON array of results:
```json
[
  {
    "Title": "Result Title",
    "URL": "https://example.com",
    "Snippet": "Description text..."
  }
]
```

## Usage in Other Scripts

You can use the search function in other PowerShell scripts:

```powershell
# Method 1: Call the script directly
$results = & "C:\path\to\local-search\scripts\search.ps1" "your query" | ConvertFrom-Json

# Method 2: Use the utility function
. "C:\path\to\utilities\searxng-search.ps1"
$results = Search-SearXNG "your query"
```

## Advantages over Brave Search API

- ✅ **No rate limits** - Search as much as you want
- ✅ **No API costs** - Completely free
- ✅ **Privacy** - Searches don't go through commercial APIs
- ✅ **Customizable** - Configure which engines SearXNG uses
- ✅ **Local** - Can run completely offline (with local index)

## Troubleshooting

### SearXNG not responding
```powershell
# Check if container is running
docker ps

# Check logs
docker logs searxng

# Restart if needed
docker-compose restart
```

### No results returned
- Check if SearXNG engines are enabled in settings
- Verify internet connection (SearXNG needs internet to query search engines)
- Check SearXNG logs for errors
