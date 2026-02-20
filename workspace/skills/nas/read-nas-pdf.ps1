# Read PDF File from NAS - 从 NAS 读取 PDF 文件
# Extract text content from PDF files on NAS
# Output text content for OpenClaw to analyze

param(
    [Parameter(Mandatory=$false)]
    [string]$FilePath = ""
)

# Step 1: Define NAS path variables (MANDATORY)
$Nas = "\\nas"
$NasHomes = "\\nas\homes"
$NasHomesWeng = "\\nas\homes\weng"

# Step 2: Set UTF-8 encoding
[Console]::OutputEncoding = [System.Text.Encoding]::UTF8
$OutputEncoding = [System.Text.Encoding]::UTF8
chcp 65001 | Out-Null

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
                    Write-Host "  - $($_.Name) ($([math]::Round($_.Length / 1KB, 2)) KB)" -ForegroundColor Gray
                }
                $FilePath = $pdfFiles[0].FullName
                Write-Host "`nUsing: $FilePath" -ForegroundColor Yellow
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
if (-not (Test-Path $FilePath)) {
    Write-Host "File does not exist: $FilePath" -ForegroundColor Red
    exit 1
}

# Step 6: Check file extension
$extension = [System.IO.Path]::GetExtension($FilePath).ToLower()
if ($extension -ne ".pdf") {
    Write-Host "Warning: File is not a PDF ($extension)" -ForegroundColor Yellow
    Write-Host "Attempting to read anyway..." -ForegroundColor Gray
}

# Step 7: Extract PDF text content
Write-Host "`n=== PDF Content Extraction ===" -ForegroundColor Cyan
Write-Host "File: $FilePath" -ForegroundColor Gray
Write-Host "Size: $([math]::Round((Get-Item $FilePath).Length / 1KB, 2)) KB" -ForegroundColor Gray
Write-Host ""

try {
    # Method 1: Try using iTextSharp or PdfSharp (if available)
    # Check if PDF library is available
    $pdfLibAvailable = $false
    
    # Try to load PdfSharp
    try {
        Add-Type -Path "$PSScriptRoot\PdfSharp.dll" -ErrorAction Stop
        $pdfLibAvailable = $true
        Write-Host "Using PdfSharp library..." -ForegroundColor Green
    } catch {
        # PdfSharp not available, try alternative methods
    }
    
    # Method 2: Use Windows built-in capabilities or external tools
    if (-not $pdfLibAvailable) {
        Write-Host "PDF library not found. Trying alternative methods..." -ForegroundColor Yellow
        
        # Option A: Check if pdftotext is available (from poppler-utils)
        $pdftotextPath = Get-Command pdftotext -ErrorAction SilentlyContinue
        if ($pdftotextPath) {
            Write-Host "Using pdftotext tool..." -ForegroundColor Green
            $tempOutput = [System.IO.Path]::GetTempFileName()
            & pdftotext -enc UTF-8 $FilePath $tempOutput
            if (Test-Path $tempOutput) {
                $content = Get-Content $tempOutput -Raw -Encoding UTF8
                Remove-Item $tempOutput
                [Console]::WriteLine($content)
                exit 0
            }
        }
        
        # Option B: Try using Word COM object (if Word is installed)
        try {
            Write-Host "Attempting to use Word COM object..." -ForegroundColor Yellow
            $word = New-Object -ComObject Word.Application
            $word.Visible = $false
            $doc = $word.Documents.Open($FilePath)
            $content = $doc.Content.Text
            $doc.Close()
            $word.Quit()
            [System.Runtime.Interopservices.Marshal]::ReleaseComObject($word) | Out-Null
            [Console]::WriteLine($content)
            exit 0
        } catch {
            Write-Host "Word COM object not available: $($_.Exception.Message)" -ForegroundColor Yellow
        }
        
        # Option C: Try reading PDF as text (may work for some PDFs)
        Write-Host "Attempting to read PDF as text (may not work for all PDFs)..." -ForegroundColor Yellow
        try {
            # Some PDFs have text content that can be partially extracted
            $bytes = [System.IO.File]::ReadAllBytes($FilePath)
            $text = [System.Text.Encoding]::UTF8.GetString($bytes)
            
            # Extract readable text (remove binary data)
            $readableText = $text -replace '[^\x20-\x7E\x80-\xFF]', ''
            $readableText = $readableText -replace '\x00', ''
            
            # Try to find text between common PDF markers
            if ($readableText.Length -gt 100) {
                Write-Host "`n=== Extracted Text (Partial) ===" -ForegroundColor Green
                Write-Host "Note: This is raw extraction and may contain formatting codes." -ForegroundColor Yellow
                Write-Host ""
                [Console]::WriteLine($readableText.Substring(0, [Math]::Min(5000, $readableText.Length)))
                Write-Host "`n... (truncated, full length: $($readableText.Length) characters)" -ForegroundColor Gray
                exit 0
            }
        } catch {
            Write-Host "Raw text extraction failed: $($_.Exception.Message)" -ForegroundColor Yellow
        }
        
        # Option D: Fallback - show file info and suggest manual extraction
        Write-Host "`n⚠️ PDF text extraction requires additional tools:" -ForegroundColor Yellow
        Write-Host "  1. Install poppler-utils: choco install poppler" -ForegroundColor Gray
        Write-Host "  2. Install PowerShell PDF module: Install-Module -Name PdfSharp" -ForegroundColor Gray
        Write-Host "  3. Use Microsoft Word to open and save as text" -ForegroundColor Gray
        Write-Host ""
        Write-Host "File information:" -ForegroundColor Cyan
        $fileInfo = Get-Item $FilePath
        Write-Host "  Name: $($fileInfo.Name)" -ForegroundColor Gray
        Write-Host "  FullName: $($fileInfo.FullName)" -ForegroundColor Gray
        Write-Host "  Size: $($fileInfo.Length) bytes" -ForegroundColor Gray
        Write-Host "  Created: $($fileInfo.CreationTime)" -ForegroundColor Gray
        Write-Host "  Modified: $($fileInfo.LastWriteTime)" -ForegroundColor Gray
        exit 1
    } else {
        # PdfSharp is available - extract text
        # Note: This is a placeholder - actual implementation depends on PdfSharp API
        Write-Host "PDF library available. Extracting text..." -ForegroundColor Green
        # Add PdfSharp extraction code here
        Write-Host "PdfSharp extraction not yet implemented. Please install pdftotext or use Word COM." -ForegroundColor Yellow
        exit 1
    }
} catch {
    Write-Host "Error extracting PDF content: $($_.Exception.Message)" -ForegroundColor Red
    Write-Host "Stack trace: $($_.ScriptStackTrace)" -ForegroundColor Gray
    exit 1
}
