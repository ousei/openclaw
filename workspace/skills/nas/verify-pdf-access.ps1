# Verify PDF File Access on Mapped Drive M:\
# 验证映射驱动器 M:\ 上的 PDF 文件访问

# Step 1: Set encoding
[Console]::OutputEncoding = [System.Text.Encoding]::UTF8
$OutputEncoding = [System.Text.Encoding]::UTF8
chcp 65001 | Out-Null

Write-Host "=== Verifying PDF File Access ===" -ForegroundColor Cyan
Write-Host ""

# Step 2: Check if mapped drive M:\ exists
Write-Host "Step 1: Checking mapped drive M:\" -ForegroundColor Yellow
if (Test-Path "M:\") {
    Write-Host "✅ Mapped drive M:\ is available" -ForegroundColor Green
    
    # Step 3: Check if weng directory exists
    Write-Host "`nStep 2: Checking directory structure" -ForegroundColor Yellow
    $wengDir = "M:\weng"
    if (Test-Path -LiteralPath $wengDir) {
        Write-Host "✅ Directory found: $wengDir" -ForegroundColor Green
        
        # Step 4: Check if 履歴書 directory exists
        $resumeDir = "M:\weng\履歴書"
        if (Test-Path -LiteralPath $resumeDir) {
            Write-Host "✅ Resume directory found: $resumeDir" -ForegroundColor Green
            
            # Step 5: List PDF files
            Write-Host "`nStep 3: Listing PDF files" -ForegroundColor Yellow
            $pdfFiles = Get-ChildItem -LiteralPath $resumeDir -Filter "*.pdf" -ErrorAction SilentlyContinue
            
            if ($pdfFiles) {
                Write-Host "✅ Found $($pdfFiles.Count) PDF file(s):" -ForegroundColor Green
                $pdfFiles | ForEach-Object {
                    Write-Host "  - $($_.Name)" -ForegroundColor Gray
                    Write-Host "    Size: $([math]::Round($_.Length / 1KB, 2)) KB" -ForegroundColor Gray
                    Write-Host "    Modified: $($_.LastWriteTime)" -ForegroundColor Gray
                    Write-Host "    Full Path: $($_.FullName)" -ForegroundColor Gray
                    Write-Host ""
                }
                
                # Step 6: Check specific file
                $targetFile = "M:\weng\履歴書\2025-04-10_職務経歴書.pdf"
                Write-Host "Step 4: Checking target file" -ForegroundColor Yellow
                if (Test-Path -LiteralPath $targetFile) {
                    Write-Host "✅ Target file found: $targetFile" -ForegroundColor Green
                    $fileInfo = Get-Item -LiteralPath $targetFile
                    Write-Host "   Size: $([math]::Round($fileInfo.Length / 1KB, 2)) KB" -ForegroundColor Gray
                    Write-Host "   Modified: $($fileInfo.LastWriteTime)" -ForegroundColor Gray
                    
                    # Step 7: Verify script exists
                    Write-Host "`nStep 5: Checking extraction script" -ForegroundColor Yellow
                    $scriptPath = "C:\Users\wengzheng\.openclaw\workspace\skills\nas\extract-pdf-text.py"
                    if (Test-Path $scriptPath) {
                        Write-Host "✅ Extraction script found: $scriptPath" -ForegroundColor Green
                        Write-Host "`n=== Ready to extract PDF text ===" -ForegroundColor Green
                        Write-Host "Run: python $scriptPath `"$targetFile`" 10" -ForegroundColor Cyan
                    } else {
                        Write-Host "❌ Extraction script not found: $scriptPath" -ForegroundColor Red
                    }
                } else {
                    Write-Host "⚠️ Target file not found: $targetFile" -ForegroundColor Yellow
                    Write-Host "Available PDF files listed above." -ForegroundColor Gray
                }
            } else {
                Write-Host "⚠️ No PDF files found in $resumeDir" -ForegroundColor Yellow
            }
        } else {
            Write-Host "❌ Resume directory not found: $resumeDir" -ForegroundColor Red
            Write-Host "Available directories in $wengDir:" -ForegroundColor Yellow
            Get-ChildItem -LiteralPath $wengDir -Directory | Select-Object Name
        }
    } else {
        Write-Host "❌ Directory not found: $wengDir" -ForegroundColor Red
    }
} else {
    Write-Host "❌ Mapped drive M:\ not found" -ForegroundColor Red
    Write-Host "Please map \\nas\homes to M:\ drive first:" -ForegroundColor Yellow
    Write-Host "  net use M: \\nas\homes 19801502 /user:nas\weng /persistent:yes" -ForegroundColor Gray
}

Write-Host "`n=== Verification Complete ===" -ForegroundColor Cyan
