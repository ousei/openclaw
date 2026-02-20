# Read PDF from NAS with automatic PyPDF2 installation
# 从 NAS 读取 PDF，自动安装 PyPDF2（如果需要）

param(
    [Parameter(Mandatory=$false)]
    [string]$FilePath = ""
)

# Step 1: Set encoding
[Console]::OutputEncoding = [System.Text.Encoding]::UTF8
$OutputEncoding = [System.Text.Encoding]::UTF8
chcp 65001 | Out-Null

# Step 2: Define NAS paths
$NasHomes = "\\nas\homes"
$NasHomesWeng = "\\nas\homes\weng"

# Step 3: Connect to NAS
net use * /delete /yes 2>$null | Out-Null
net use $NasHomes /user:nas\weng 19801502 /persistent:yes 2>&1 | Out-Null
Start-Sleep -Seconds 2

# Step 4: If no file path provided, search for PDF files
if ([string]::IsNullOrEmpty($FilePath)) {
    Write-Host "=== Searching for PDF files ===" -ForegroundColor Cyan
    try {
        $resumeDir = "$NasHomesWeng\履歴書"
        if (Test-Path $resumeDir) {
            $pdfFiles = Get-ChildItem $resumeDir -Filter "*.pdf" -ErrorAction Stop
            if ($pdfFiles.Count -gt 0) {
                Write-Host "Found PDF files:" -ForegroundColor Green
                $pdfFiles | ForEach-Object {
                    Write-Host "  - $($_.Name)" -ForegroundColor Gray
                }
                $FilePath = $pdfFiles[0].FullName
            } else {
                Write-Host "No PDF files found" -ForegroundColor Yellow
                exit 1
            }
        }
    } catch {
        Write-Host "Error: $($_.Exception.Message)" -ForegroundColor Red
        exit 1
    }
}

# Step 5: Verify file exists
if (-not (Test-Path -LiteralPath $FilePath)) {
    Write-Host "File not found: $FilePath" -ForegroundColor Red
    exit 1
}

# Step 6: Check if PyPDF2 is installed
Write-Host "`n=== Checking PyPDF2 installation ===" -ForegroundColor Cyan
$checkPyPDF2 = python -c "import PyPDF2; print('OK')" 2>&1
if ($LASTEXITCODE -ne 0) {
    Write-Host "PyPDF2 not found. Installing..." -ForegroundColor Yellow
    pip install PyPDF2
    if ($LASTEXITCODE -ne 0) {
        Write-Host "Failed to install PyPDF2. Please install manually: pip install PyPDF2" -ForegroundColor Red
        exit 1
    }
    Write-Host "PyPDF2 installed successfully" -ForegroundColor Green
} else {
    Write-Host "PyPDF2 is available" -ForegroundColor Green
}

# Step 7: Extract PDF text using Python script
Write-Host "`n=== Extracting PDF text ===" -ForegroundColor Cyan
Write-Host "File: $FilePath" -ForegroundColor Gray

$scriptPath = Join-Path $PSScriptRoot "extract-pdf-text.py"
if (Test-Path $scriptPath) {
    python $scriptPath $FilePath 10
} else {
    # Fallback: inline Python command
    Write-Host "Using inline Python extraction..." -ForegroundColor Yellow
    $pythonCmd = @"
import PyPDF2
import sys
file_path = r'$FilePath'
try:
    with open(file_path, 'rb') as f:
        reader = PyPDF2.PdfReader(f)
        for i, page in enumerate(reader.pages[:10]):
            text = page.extract_text()
            if text:
                print(f'\n--- Page {i+1} ---')
                print(text)
except Exception as e:
    print(f'Error: {e}', file=sys.stderr)
    sys.exit(1)
"@
    python -c $pythonCmd
}
