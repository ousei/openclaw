# Read PDF from NAS and Output for AI Analysis
# 从 NAS 读取 PDF 并输出供 AI 分析理解

param(
    [Parameter(Mandatory=$false)]
    [string]$FilePath = "",
    [Parameter(Mandatory=$false)]
    [int]$MaxPages = 10
)

# Step 1: Set encoding
[Console]::OutputEncoding = [System.Text.Encoding]::UTF8
$OutputEncoding = [System.Text.Encoding]::UTF8
chcp 65001 | Out-Null

# Step 2: Check if file path uses mapped drive M:\ or UNC path
$useMappedDrive = $false
if (-not [string]::IsNullOrEmpty($FilePath)) {
    # File path provided - check format
    if ($FilePath -like "M:\*" -or $FilePath -like "M:*") {
        # File path uses M:\ drive
        Write-Host "Detected M:\ drive path: $FilePath" -ForegroundColor Cyan
        
        # Check if M:\ is accessible, if not, try to remap
        if (-not (Test-Path "M:\")) {
            Write-Host "⚠️ M:\ drive not accessible in PowerShell, attempting to remap..." -ForegroundColor Yellow
            net use M: /delete 2>$null | Out-Null
            $mapResult = net use M: \\nas\homes 19801502 /user:nas\weng /persistent:yes 2>&1
            Start-Sleep -Seconds 2
            
            if (Test-Path "M:\") {
                Write-Host "✅ Successfully remapped M:\ drive" -ForegroundColor Green
                $useMappedDrive = $true
            } else {
                Write-Host "❌ Failed to map M:\ drive" -ForegroundColor Red
                Write-Host "Error: $mapResult" -ForegroundColor Red
                Write-Host "Switching to UNC path..." -ForegroundColor Yellow
                # Convert M:\ path to UNC path
                $FilePath = $FilePath -replace "^M:\\", "\\nas\homes\"
            }
        } else {
            $useMappedDrive = $true
            Write-Host "✅ Using mapped drive M:\" -ForegroundColor Green
        }
    } elseif ($FilePath -like "\\nas\*" -or $FilePath -like "\\\\nas\*") {
        # File path uses UNC path - connect first
        Write-Host "Detected UNC path: $FilePath" -ForegroundColor Cyan
        Write-Host "Connecting to NAS via UNC path..." -ForegroundColor Yellow
        $NasHomes = "\\nas\homes"
        net use * /delete /yes 2>$null | Out-Null
        net use $NasHomes 19801502 /user:nas\weng /persistent:yes 2>&1 | Out-Null
        Start-Sleep -Seconds 2
    } else {
        # Unknown path format
        Write-Host "⚠️ Unknown path format: $FilePath" -ForegroundColor Yellow
        Write-Host "Path should start with M:\ or \\nas\" -ForegroundColor Yellow
        Write-Host "Current path: '$FilePath'" -ForegroundColor Gray
    }
}

# Step 4: If no file path provided, search for PDF files
if ([string]::IsNullOrEmpty($FilePath)) {
    Write-Host "=== Searching for PDF files ===" -ForegroundColor Cyan
    try {
        # Check if M:\ is available
        if (Test-Path "M:\") {
            $resumeDir = "M:\weng\履歴書"
            $useMappedDrive = $true
        } else {
            # Connect to NAS and use UNC path
            $NasHomes = "\\nas\homes"
            $resumeDir = "\\nas\homes\weng\履歴書"
            Write-Host "Connecting to NAS..." -ForegroundColor Yellow
            net use * /delete /yes 2>$null | Out-Null
            net use $NasHomes 19801502 /user:nas\weng /persistent:yes 2>&1 | Out-Null
            Start-Sleep -Seconds 2
        }
        if (Test-Path $resumeDir) {
            $pdfFiles = Get-ChildItem $resumeDir -Filter "*.pdf" -ErrorAction Stop | Sort-Object LastWriteTime -Descending
            if ($pdfFiles.Count -gt 0) {
                Write-Host "Found PDF files:" -ForegroundColor Green
                $pdfFiles | ForEach-Object {
                    Write-Host "  - $($_.Name) (Modified: $($_.LastWriteTime))" -ForegroundColor Gray
                }
                $FilePath = $pdfFiles[0].FullName
                Write-Host "`nUsing latest file: $FilePath" -ForegroundColor Yellow
            } else {
                Write-Host "No PDF files found in $resumeDir" -ForegroundColor Yellow
                exit 1
            }
        } else {
            Write-Host "Directory not found: $resumeDir" -ForegroundColor Red
            exit 1
        }
    } catch {
        Write-Host "Error searching for files: $($_.Exception.Message)" -ForegroundColor Red
        exit 1
    }
}

# Step 5: Verify file exists
Write-Host "`n=== Verifying file access ===" -ForegroundColor Cyan
Write-Host "Checking file: $FilePath" -ForegroundColor Gray

if (-not (Test-Path -LiteralPath $FilePath)) {
    Write-Host "❌ File does not exist: $FilePath" -ForegroundColor Red
    
    # Try to help user find the file
    if ($FilePath -like "M:\*" -or $FilePath -like "M:*") {
        Write-Host "`nTroubleshooting M:\ drive path..." -ForegroundColor Yellow
        
        # Check if M:\ drive exists
        if (Test-Path "M:\") {
            Write-Host "✅ M:\ drive is accessible" -ForegroundColor Green
            
            $parentDir = Split-Path $FilePath -Parent
            Write-Host "Checking parent directory: $parentDir" -ForegroundColor Gray
            
            if (Test-Path -LiteralPath $parentDir) {
                Write-Host "✅ Directory exists. Available PDF files:" -ForegroundColor Green
                $pdfFiles = Get-ChildItem -LiteralPath $parentDir -Filter "*.pdf" -ErrorAction SilentlyContinue
                if ($pdfFiles) {
                    $pdfFiles | Select-Object Name, Length, LastWriteTime | Format-Table -AutoSize
                } else {
                    Write-Host "No PDF files found in this directory" -ForegroundColor Yellow
                }
            } else {
                Write-Host "❌ Directory not found: $parentDir" -ForegroundColor Red
                Write-Host "`nChecking M:\weng directory structure..." -ForegroundColor Yellow
                if (Test-Path "M:\weng") {
                    Write-Host "Available directories in M:\weng:" -ForegroundColor Cyan
                    Get-ChildItem "M:\weng" -Directory | Select-Object Name | Format-Table -AutoSize
                    
                    # Check for 履歴書 directory with different names
                    Write-Host "`nSearching for resume-related directories..." -ForegroundColor Yellow
                    Get-ChildItem "M:\weng" -Directory | Where-Object { $_.Name -like "*履歴*" -or $_.Name -like "*resume*" -or $_.Name -like "*简历*" } | Select-Object Name
                } else {
                    Write-Host "❌ M:\weng directory not found" -ForegroundColor Red
                }
            }
        } else {
            Write-Host "❌ M:\ drive is not accessible" -ForegroundColor Red
            Write-Host "Please verify the drive mapping:" -ForegroundColor Yellow
            Write-Host "  net use M:" -ForegroundColor Gray
        }
    }
    exit 1
} else {
    Write-Host "✅ File found: $FilePath" -ForegroundColor Green
    $fileInfo = Get-Item -LiteralPath $FilePath
    Write-Host "   Size: $([math]::Round($fileInfo.Length / 1KB, 2)) KB" -ForegroundColor Gray
    Write-Host "   Modified: $($fileInfo.LastWriteTime)" -ForegroundColor Gray
}

# Step 6: Check if PyPDF2 or pdfplumber is installed
Write-Host "`n=== Checking PDF libraries ===" -ForegroundColor Cyan
$checkPdfplumber = python -c "import pdfplumber; print('OK')" 2>&1
$pdfplumberAvailable = ($LASTEXITCODE -eq 0)

if (-not $pdfplumberAvailable) {
    $checkPyPDF2 = python -c "import PyPDF2; print('OK')" 2>&1
    $pyPDF2Available = ($LASTEXITCODE -eq 0)
} else {
    $pyPDF2Available = $false
}

$usePdfplumber = $false
if ($pdfplumberAvailable) {
    Write-Host "pdfplumber is available (preferred for better extraction)" -ForegroundColor Green
    $usePdfplumber = $true
} elseif ($pyPDF2Available) {
    Write-Host "PyPDF2 is available" -ForegroundColor Green
} else {
    Write-Host "No PDF library found. Installing pdfplumber (better extraction)..." -ForegroundColor Yellow
    pip install pdfplumber --quiet
    if ($LASTEXITCODE -eq 0) {
        Write-Host "pdfplumber installed successfully" -ForegroundColor Green
        $usePdfplumber = $true
    } else {
        Write-Host "Trying PyPDF2 (lighter alternative)..." -ForegroundColor Yellow
        pip install PyPDF2 --quiet
        if ($LASTEXITCODE -ne 0) {
            Write-Host "Failed to install PDF libraries. Please install manually: pip install pdfplumber" -ForegroundColor Red
            exit 1
        }
        Write-Host "PyPDF2 installed successfully" -ForegroundColor Green
    }
}

# Step 7: Extract PDF text
Write-Host "`n=== Extracting PDF Text ===" -ForegroundColor Cyan
Write-Host "File: $FilePath" -ForegroundColor Gray
Write-Host "Extracting first $MaxPages pages..." -ForegroundColor Gray
Write-Host "Using library: $(if ($usePdfplumber) { 'pdfplumber' } else { 'PyPDF2' })" -ForegroundColor Gray

if ($usePdfplumber) {
    $pythonScript = @"
import pdfplumber
import sys

file_path = r'$FilePath'
max_pages = $MaxPages

try:
    with pdfplumber.open(file_path) as pdf:
        total_pages = len(pdf.pages)
        pages_to_extract = min(max_pages, total_pages)
        
        print(f'=== PDF Content Extraction (pdfplumber) ===')
        print(f'File: {file_path}')
        print(f'Total pages: {total_pages}')
        print(f'Extracting pages: 1-{pages_to_extract}')
        print(f'\n=== Extracted Text ===\n')
        
        full_text = ''
        for i in range(pages_to_extract):
            page = pdf.pages[i]
            text = page.extract_text()
            if text and text.strip():
                print(f'\n--- Page {i+1} ---')
                print(text)
                full_text += text + '\n\n'
        
        print(f'\n=== Summary ===')
        print(f'Total characters extracted: {len(full_text)}')
        print(f'Pages processed: {pages_to_extract}/{total_pages}')
        
except FileNotFoundError:
    print(f'Error: File not found: {file_path}', file=sys.stderr)
    sys.exit(1)
except Exception as e:
    print(f'Error: {str(e)}', file=sys.stderr)
    sys.exit(1)
"@
} else {
    $pythonScript = @"
import PyPDF2
import sys

file_path = r'$FilePath'
max_pages = $MaxPages

try:
    with open(file_path, 'rb') as f:
        reader = PyPDF2.PdfReader(f)
        total_pages = len(reader.pages)
        pages_to_extract = min(max_pages, total_pages)
        
        print(f'=== PDF Content Extraction (PyPDF2) ===')
        print(f'File: {file_path}')
        print(f'Total pages: {total_pages}')
        print(f'Extracting pages: 1-{pages_to_extract}')
        print(f'\n=== Extracted Text ===\n')
        
        full_text = ''
        for i in range(pages_to_extract):
            page = reader.pages[i]
            text = page.extract_text()
            if text.strip():
                print(f'\n--- Page {i+1} ---')
                print(text)
                full_text += text + '\n\n'
        
        print(f'\n=== Summary ===')
        print(f'Total characters extracted: {len(full_text)}')
        print(f'Pages processed: {pages_to_extract}/{total_pages}')
        
except FileNotFoundError:
    print(f'Error: File not found: {file_path}', file=sys.stderr)
    sys.exit(1)
except Exception as e:
    print(f'Error: {str(e)}', file=sys.stderr)
    sys.exit(1)
"@
}

# Execute Python script
python -c $pythonScript

if ($LASTEXITCODE -eq 0) {
    Write-Host "`n=== Extraction Complete ===" -ForegroundColor Green
    Write-Host "The extracted text above can now be analyzed by AI/OpenClaw" -ForegroundColor Cyan
} else {
    Write-Host "`n=== Extraction Failed ===" -ForegroundColor Red
    exit 1
}
