---
name: notion
description: Manage Notion pages, databases, and to-do items. Use when user asks about Notion, tasks, notes, or databases.
homepage: https://notion.so
metadata:
  clawdbot:
    emoji: "📝"
    requires:
      env: ["NOTION_API_KEY"]
---

# Notion API

Manage Notion pages, databases, and to-do items using the Notion API.

## Setup

1. Get API token from https://www.notion.so/my-integrations
2. Create an integration and copy the "Internal Integration Secret" (starts with `ntn_`)
3. Set environment variable:
   ```bash
   export NOTION_API_KEY="ntn_..."
   ```
4. **Important**: Add the integration to the pages/databases you want to access:
   - Open the Notion page/database
   - Click "..." → "Connections" → Add your integration

## API Endpoints

Base URL: `https://api.notion.com/v1/`

Required headers:
- `Authorization: Bearer {NOTION_API_KEY}`
- `Notion-Version: 2022-06-28` (or newer)
- `Content-Type: application/json`

## Common Operations

### Search for Pages/Databases

```bash
curl -X POST "https://api.notion.com/v1/search" \
  -H "Authorization: Bearer $NOTION_API_KEY" \
  -H "Notion-Version: 2022-06-28" \
  -H "Content-Type: application/json" \
  -d '{"filter": {"value": "page", "property": "object"}}'
```

### Query a Database

```bash
# Replace {database_id} with your actual database ID
curl -X POST "https://api.notion.com/v1/databases/{database_id}/query" \
  -H "Authorization: Bearer $NOTION_API_KEY" \
  -H "Notion-Version: 2022-06-28" \
  -H "Content-Type: application/json" \
  -d '{
    "filter": {
      "property": "Status",
      "select": {
        "equals": "Todo"
      }
    }
  }'
```

### Get Database Info

```bash
curl -X GET "https://api.notion.com/v1/databases/{database_id}" \
  -H "Authorization: Bearer $NOTION_API_KEY" \
  -H "Notion-Version: 2022-06-28"
```

### Get Page Content

```bash
curl -X GET "https://api.notion.com/v1/pages/{page_id}" \
  -H "Authorization: Bearer $NOTION_API_KEY" \
  -H "Notion-Version: 2022-06-28"
```

### Create a Page

```bash
curl -X POST "https://api.notion.com/v1/pages" \
  -H "Authorization: Bearer $NOTION_API_KEY" \
  -H "Notion-Version: 2022-06-28" \
  -H "Content-Type: application/json" \
  -d '{
    "parent": {"database_id": "{database_id}"},
    "properties": {
      "Name": {
        "title": [{"text": {"content": "New Task"}}]
      },
      "Status": {
        "select": {"name": "Todo"}
      }
    }
  }'
```

### Update a Page

```bash
curl -X PATCH "https://api.notion.com/v1/pages/{page_id}" \
  -H "Authorization: Bearer $NOTION_API_KEY" \
  -H "Notion-Version: 2022-06-28" \
  -H "Content-Type: application/json" \
  -d '{
    "properties": {
      "Status": {
        "select": {"name": "Done"}
      }
    }
  }'
```

## Querying To-Do Items

### Find To-Do Database

First, search for databases:

```bash
curl -X POST "https://api.notion.com/v1/search" \
  -H "Authorization: Bearer $NOTION_API_KEY" \
  -H "Notion-Version: 2022-06-28" \
  -H "Content-Type: application/json" \
  -d '{"filter": {"value": "database", "property": "object"}}'
```

### Query To-Do Items

Once you have the database ID, query for to-do items:

```bash
# PowerShell version
$env:NOTION_API_KEY = "ntn_xxx..."
$databaseId = "your-database-id-here"

curl.exe -X POST "https://api.notion.com/v1/databases/$databaseId/query" `
  -H "Authorization: Bearer $env:NOTION_API_KEY" `
  -H "Notion-Version: 2022-06-28" `
  -H "Content-Type: application/json" `
  -d '{
    "filter": {
      "property": "Status",
      "select": {
        "equals": "Todo"
      }
    }
  }'
```

### Alternative: Filter by Checkbox Property

If your to-do items use a checkbox property:

```bash
curl -X POST "https://api.notion.com/v1/databases/{database_id}/query" \
  -H "Authorization: Bearer $NOTION_API_KEY" \
  -H "Notion-Version: 2022-06-28" \
  -H "Content-Type: application/json" \
  -d '{
    "filter": {
      "property": "Done",
      "checkbox": {
        "equals": false
      }
    }
  }'
```

## Usage Examples

**User: "查看 Notion 的待办项目"**
1. First, search for databases to find the to-do database
2. Query the database with Status = "Todo" filter
3. Display the results

**User: "在 Notion 中添加一个任务"**
1. Get the database ID
2. Create a new page in the database with Status = "Todo"

**User: "完成 Notion 中的某个任务"**
1. Find the page ID
2. Update the page to set Status = "Done"

## Notes

- Database IDs are found in the Notion URL: `notion.so/{workspace}/{database_id}`
- Page IDs are found in the Notion URL: `notion.so/{workspace}/{page_id}`
- Property names are case-sensitive
- The integration must be added to each page/database you want to access
- API version `2022-06-28` is the minimum supported version

## Common Property Types

- **Title**: `{"title": [{"text": {"content": "Text"}}]}`
- **Select**: `{"select": {"name": "Option Name"}}`
- **Checkbox**: `{"checkbox": true}`
- **Date**: `{"date": {"start": "2026-01-31"}}`
- **Number**: `{"number": 42}`
