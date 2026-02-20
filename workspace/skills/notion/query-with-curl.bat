@echo off
REM Query Notion To-Do Items using curl
REM Make sure NOTION_API_KEY is set in environment

if "%NOTION_API_KEY%"=="" (
    echo Error: NOTION_API_KEY not set
    echo Please set it first:
    echo   set NOTION_API_KEY=ntn_xxx...
    exit /b 1
)

echo Querying Notion API for tasks with status "未着手"...
echo.

curl.exe -X POST "https://api.notion.com/v1/databases/2e29fe12-e0aa-816e-9366-dae1fbe6fd20/query" ^
  -H "Authorization: Bearer %NOTION_API_KEY%" ^
  -H "Notion-Version: 2022-06-28" ^
  -H "Content-Type: application/json" ^
  -d "{\"filter\":{\"property\":\"ステータス\",\"status\":{\"equals\":\"未着手\"}}}"

echo.
echo Done.
