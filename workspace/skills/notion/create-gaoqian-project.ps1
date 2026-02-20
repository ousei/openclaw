# create-gaoqian-project.ps1 - 为 Notion 创建「搞钱」项目及任务
# Set UTF-8 encoding for proper handling of Chinese/Japanese characters
[Console]::OutputEncoding = [System.Text.Encoding]::UTF8
$OutputEncoding = [System.Text.Encoding]::UTF8

# ===== 配置区 =====

if (-not $env:NOTION_API_KEY) {
    Write-Error "NOTION_API_KEY 未设置，请在环境变量或 .env 中配置。"
    exit 1
}

$projectDbId = "2e29fe12-e0aa-81fb-a137-f3fe5c2a6c34"  # プロジェクトDB
$taskDbId    = "2e29fe12-e0aa-816e-9366-dae1fbe6fd20"  # タスクDB

$headers = @{
    "Authorization"  = "Bearer $env:NOTION_API_KEY"
    "Notion-Version" = "2022-06-28"
    "Content-Type"   = "application/json"
}

Write-Host "Using NOTION_API_KEY: $($env:NOTION_API_KEY.Substring(0,8))..." -ForegroundColor Yellow

# ===== 1. 创建项目「搞钱」 =====

Write-Host "`n[1/2] 创建项目『搞钱』..." -ForegroundColor Cyan

$projectBodyHash = @{
  parent = @{ database_id = $projectDbId }
  properties = @{
    Name = @{
      title = @(@{ text = @{ content = "搞钱" } })
    }
    "ステータス" = @{
      status = @{ name = "進行中" }
    }
    "優先度" = @{
      select = @{ name = "高" }
    }
  }
}
$projectBody = $projectBodyHash | ConvertTo-Json -Depth 5

try {
    $projectRes = Invoke-RestMethod `
      -Uri "https://api.notion.com/v1/pages" `
      -Method POST `
      -Headers $headers `
      -Body $projectBody `
      -ContentType "application/json"
    
    $projectId = $projectData.id
    
    Write-Host "项目已创建：搞钱" -ForegroundColor Green
    Write-Host "Project ID: $projectId"
    Write-Host "Notion URL: $($projectData.url)"
} catch {
    Write-Host "创建项目失败！" -ForegroundColor Red
    Write-Host "错误: $($_.Exception.Message)" -ForegroundColor Yellow
    if ($_.Exception.Response) {
        try {
            $stream = $_.Exception.Response.GetResponseStream()
            $reader = New-Object System.IO.StreamReader($stream)
            $errorBody = $reader.ReadToEnd()
            $reader.Close()
            $stream.Close()
            Write-Host "错误详情: $errorBody" -ForegroundColor Yellow
        } catch {}
    }
    exit 1
}

# ===== 2. 为「搞钱」项目创建一批任务 =====

Write-Host "`n[2/2] 为项目『搞钱』创建任务..." -ForegroundColor Cyan

$tasks = @(
    @{
        name     = "调研 10 种 AI 自动化搞钱模式，并整理利弊"
        status   = "未着手"
        priority = "高"
        due      = (Get-Date).AddDays(7).ToString("yyyy-MM-dd")
    },
    @{
        name     = "从搞钱模式清单中筛选 3 个适合自己资源的方向"
        status   = "未着手"
        priority = "高"
        due      = (Get-Date).AddDays(9).ToString("yyyy-MM-dd")
    },
    @{
        name     = "为 3 个搞钱方向分别写 1 页 Notion 评估"
        status   = "未着手"
        priority = "中"
        due      = (Get-Date).AddDays(14).ToString("yyyy-MM-dd")
    },
    @{
        name     = "确定本期唯一主线搞钱方案（只选 1 条）"
        status   = "未着手"
        priority = "高"
        due      = $null
    },
    @{
        name     = "梳理主线搞钱方案的完整钱流（从流量到收款）"
        status   = "未着手"
        priority = "高"
        due      = $null
    },
    @{
        name     = "把搞钱系统拆成 3–5 个子系统（获客 / 转化 / 交付 / 收款 / 监控）"
        status   = "未着手"
        priority = "中"
        due      = $null
    },
    @{
        name     = "搭一条最简单的获客通路（Landing Page + 一条投放渠道）"
        status   = "未着手"
        priority = "高"
        due      = $null
    },
    @{
        name     = "用 AI 搭建交付流程 MVP（从接单到自动生成/交付）"
        status   = "未着手"
        priority = "高"
        due      = $null
    },
    @{
        name     = "打通收款 + 记账链路（支付 + 记账表）"
        status   = "未着手"
        priority = "中"
        due      = $null
    },
    @{
        name     = "配置搞钱系统的基础监控（收入 / 请求量 / 错误率，每日汇总）"
        status   = "未着手"
        priority = "中"
        due      = $null
    },
    @{
        name     = "搞钱系统连续无人值守运行 7 天（只做监控不手动干预）"
        status   = "未着手"
        priority = "中"
        due      = $null
    },
    @{
        name     = "整理搞钱系统运维 Checklist（每天 / 每周 / 每月）"
        status   = "未着手"
        priority = "中"
        due      = $null
    },
    @{
        name     = "为搞钱系统设计 3 类常见故障的应急预案（支付失败 / 模型异常 / API 限流）"
        status   = "未着手"
        priority = "中"
        due      = $null
    }
)

foreach ($t in $tasks) {
    $dueProp = if ($t.due) { @{ date = @{ start = $t.due } } } else { @{ date = $null } }

    $taskBodyHash = @{
      parent = @{ database_id = $taskDbId }
      properties = @{
        "タスク名" = @{
          title = @(@{ text = @{ content = $t.name } })
        }
        "ステータス" = @{
          status = @{ name = $t.status }
        }
        "優先度" = @{
          select = @{ name = $t.priority }
        }
        "期限" = $dueProp
        "プロジェクト" = @{
          relation = @(@{ id = $projectId })
        }
      }
    }
    $taskBody = $taskBodyHash | ConvertTo-Json -Depth 8

    try {
        $res = Invoke-RestMethod `
          -Uri "https://api.notion.com/v1/pages" `
          -Method POST `
          -Headers $headers `
          -Body $taskBody `
          -ContentType "application/json"
        
            Write-Host "  - 已创建任务: $($t.name)" -ForegroundColor Green
    } catch {
        Write-Host "  - 创建任务失败: $($t.name)" -ForegroundColor Red
        Write-Host "    错误: $($_.Exception.Message)" -ForegroundColor Yellow
    }
}

Write-Host "`n全部『搞钱』相关任务已创建完毕。" -ForegroundColor Green
Write-Host "请在 Notion 的プロジェクト/タスク视图中按『搞钱』项目筛选查看。"
