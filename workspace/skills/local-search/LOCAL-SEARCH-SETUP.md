# 本地搜索 API 设置指南

在本地建立类似 Brave Search API 功能的程序，用于搜索网页信息。

## 🎯 方案对比

### 方案 1: SearXNG（推荐）⭐
**优点：**
- ✅ 开源、免费、隐私保护
- ✅ 聚合多个搜索引擎（Google、Bing、DuckDuckGo 等）
- ✅ 提供 REST API，兼容 Brave Search API 格式
- ✅ 无需 API Key，无速率限制
- ✅ 支持 Docker 一键部署

**缺点：**
- ⚠️ 依赖外部搜索引擎（不是完全本地）
- ⚠️ 需要 Docker 或 Python 环境

### 方案 2: 自建爬虫 + 搜索引擎
**优点：**
- ✅ 完全本地化，数据不离开本地
- ✅ 可自定义索引内容

**缺点：**
- ⚠️ 需要大量存储空间
- ⚠️ 需要定期爬取和更新索引
- ⚠️ 配置复杂，维护成本高

### 方案 3: Meilisearch + 爬虫
**优点：**
- ✅ 轻量级，适合个人使用
- ✅ 快速搜索，支持模糊搜索
- ✅ 完全本地化

**缺点：**
- ⚠️ 需要自己爬取和索引网页
- ⚠️ 索引范围有限

---

## 🚀 方案 1: SearXNG 部署（推荐）

### 使用 Docker 部署（最简单）

#### Windows PowerShell 部署步骤：

```powershell
# 1. 创建配置目录
mkdir C:\searxng
cd C:\searxng

# 2. 创建 docker-compose.yml
@"
version: '3.8'

services:
  searxng:
    image: searxng/searxng:latest
    container_name: searxng
    ports:
      - "8888:8080"
    volumes:
      - ./searxng:/etc/searxng:rw
    environment:
      - SEARXNG_HOSTNAME=http://localhost:8888/
    restart: unless-stopped

  redis:
    image: redis:alpine
    container_name: searxng-redis
    volumes:
      - redis-data:/data
    restart: unless-stopped

volumes:
  redis-data:
"@ | Out-File -FilePath docker-compose.yml -Encoding UTF8

# 3. 启动服务
docker-compose up -d

# 4. 检查状态
docker-compose ps
```

#### 访问和测试

1. **Web 界面**: http://localhost:8888
2. **API 端点**: http://localhost:8888/search?q=test&format=json

### 配置 OpenClaw 使用 SearXNG

编辑 `openclaw.json`，添加本地搜索配置：

```json
{
  "tools": {
    "web": {
      "search": {
        "enabled": true,
        "provider": "searxng",
        "baseUrl": "http://localhost:8888",
        "apiKey": null
      },
      "fetch": {
        "enabled": true
      }
    }
  }
}
```

**注意**: OpenClaw 可能需要支持自定义搜索提供商的配置。如果当前不支持，可以考虑：
1. 使用 SearXNG 的 API 作为代理
2. 创建一个本地 Skill 来调用 SearXNG API

---

## 🔧 方案 2: 自建爬虫 + Meilisearch

### 架构
```
网页爬虫 → 内容提取 → Meilisearch 索引 → REST API
```

### 快速开始

#### 1. 安装 Meilisearch

```powershell
# 使用 Docker
docker run -d \
  --name meilisearch \
  -p 7700:7700 \
  -v C:\meilisearch\data:/meili_data \
  getmeili/meilisearch:latest
```

#### 2. 创建爬虫脚本（Python 示例）

```python
# crawler.py
import requests
from bs4 import BeautifulSoup
from meilisearch import Client
import time

# 初始化 Meilisearch
client = Client('http://localhost:7700', 'masterKey')
index = client.index('webpages')

def crawl_and_index(url):
    try:
        response = requests.get(url, timeout=10)
        soup = BeautifulSoup(response.text, 'html.parser')
        
        # 提取内容
        title = soup.title.string if soup.title else ''
        text = soup.get_text()[:5000]  # 限制长度
        
        # 索引到 Meilisearch
        document = {
            'id': url,
            'url': url,
            'title': title,
            'content': text
        }
        index.add_documents([document])
        print(f"✓ 已索引: {url}")
    except Exception as e:
        print(f"✗ 错误 {url}: {e}")

# 爬取示例网站
urls = [
    'https://example.com',
    # 添加更多 URL
]

for url in urls:
    crawl_and_index(url)
    time.sleep(1)  # 避免过快请求
```

#### 3. 创建搜索 API（Flask 示例）

```python
# search_api.py
from flask import Flask, request, jsonify
from meilisearch import Client

app = Flask(__name__)
client = Client('http://localhost:7700', 'masterKey')
index = client.index('webpages')

@app.route('/search', methods=['GET'])
def search():
    query = request.args.get('q', '')
    limit = int(request.args.get('limit', 10))
    
    results = index.search(query, {'limit': limit})
    
    # 转换为类似 Brave Search API 的格式
    formatted_results = {
        'web': {
            'results': [
                {
                    'title': r['title'],
                    'url': r['url'],
                    'description': r['content'][:200]
                }
                for r in results['hits']
            ]
        }
    }
    return jsonify(formatted_results)

if __name__ == '__main__':
    app.run(port=5000)
```

---

## 📝 方案 3: 使用 SearXNG API 作为本地 Skill

如果 OpenClaw 不支持直接配置 SearXNG，可以创建一个 Skill 来调用本地 SearXNG API。

### 创建 Skill

在 `workspace/skills/local-search/` 目录下创建：

**SKILL.md**:
```markdown
---
name: local-search
description: Local web search using SearXNG
metadata: {"clawdbot":{"emoji":"🔍","requires":{"bins":["curl"]}}
---

# Local Search

Search the web using local SearXNG instance.

## Usage

"Search for Python tutorials"
"Find information about machine learning"
```

**search.sh** (或 PowerShell 脚本):
```bash
#!/bin/bash
QUERY="$1"
curl -s "http://localhost:8888/search?q=${QUERY}&format=json" | jq '.results[] | {title: .title, url: .url, snippet: .content}'
```

---

## 🔍 测试本地搜索

### 测试 SearXNG API

```powershell
# PowerShell 测试
$query = "Python tutorial"
$url = "http://localhost:8888/search?q=$([System.Web.HttpUtility]::UrlEncode($query))&format=json"
Invoke-RestMethod -Uri $url | ConvertTo-Json
```

### 测试 Meilisearch

```powershell
# 搜索
$body = @{q="Python"} | ConvertTo-Json
Invoke-RestMethod -Uri "http://localhost:7700/indexes/webpages/search" `
  -Method POST -Body $body -ContentType "application/json" `
  -Headers @{"Authorization"="Bearer masterKey"}
```

---

## 📊 性能对比

| 方案 | 部署难度 | 搜索质量 | 隐私性 | 维护成本 |
|------|---------|---------|--------|---------|
| SearXNG | ⭐⭐ 简单 | ⭐⭐⭐⭐ 高 | ⭐⭐⭐ 中 | ⭐⭐ 低 |
| 自建爬虫+Meilisearch | ⭐⭐⭐⭐ 复杂 | ⭐⭐⭐ 中 | ⭐⭐⭐⭐⭐ 高 | ⭐⭐⭐⭐ 高 |
| Brave Search API | ⭐ 最简单 | ⭐⭐⭐⭐⭐ 最高 | ⭐⭐ 低 | ⭐ 最低 |

---

## 🎯 推荐方案

**对于大多数用户**: 使用 **SearXNG**（方案 1）
- 部署简单
- 搜索质量好
- 无速率限制
- 隐私保护

**对于高隐私需求**: 使用 **自建爬虫 + Meilisearch**（方案 2）
- 完全本地化
- 数据不离开本地
- 需要更多维护

---

## 📚 参考资源

- SearXNG 文档: https://docs.searxng.org/
- Meilisearch 文档: https://www.meilisearch.com/docs
- Docker 安装: https://docs.docker.com/get-docker/
