# Read NAS File Directly - 直接读取 NAS 文件
# Read file from NAS without copying to local
# Output content for OpenClaw to analyze

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

# Step 4: Get file path from parameter or use default
param(
    [Parameter(Mandatory=$false)]
    [string]$FilePath = ""
)

# If no file path provided, search for resume files
if ([string]::IsNullOrEmpty($FilePath)) {
    Write-Host "=== Searching for files ===" -ForegroundColor Cyan
    
    try {
        $allDirs = Get-ChildItem $NasHomesWeng -Directory -ErrorAction Stop
        $targetDir = $allDirs | Where-Object { $_.Name -match "履歴|リレキ|レキ" } | Select-Object -First 1
        
        if ($targetDir) {
            $targetPath = $targetDir.FullName
            Write-Host "Found directory: $($targetDir.Name)" -ForegroundColor Green
            
            # List PDF files in the directory
            $pdfFiles = Get-ChildItem $targetPath -Filter "*.pdf" -ErrorAction Stop | Select-Object -First 5
            Write-Host "`nPDF files found:" -ForegroundColor Cyan
            foreach ($file in $pdfFiles) {
                Write-Host "  - $($file.Name)" -ForegroundColor Gray
            }
            
            # Use first PDF file if available
            if ($pdfFiles.Count -gt 0) {
                $FilePath = $pdfFiles[0].FullName
                Write-Host "`nReading file: $($pdfFiles[0].Name)" -ForegroundColor Yellow
            } else {
                Write-Host "No PDF files found" -ForegroundColor Yellow
                exit 1
            }
        } else {
            Write-Host "Target directory not found" -ForegroundColor Red
            exit 1
        }
    } catch {
        Write-Host "Error: $($_.Exception.Message)" -ForegroundColor Red
        exit 1
    }
}

# Step 5: Read file content
if (Test-Path $FilePath) {
    Write-Host "`n=== File Content ===" -ForegroundColor Cyan
    Write-Host "File: $FilePath" -ForegroundColor Gray
    Write-Host "Size: $((Get-Item $FilePath).Length) bytes" -ForegroundColor Gray
    Write-Host ""
    
    # For text files, read content directly
    $extension = [System.IO.Path]::GetExtension($FilePath).ToLower()
    
    if ($extension -in @(".txt", ".md", ".json", ".csv", ".log", ".ps1", ".py", ".js", ".html", ".xml")) {
        try {
            $content = Get-Content $FilePath -Encoding UTF8 -Raw -ErrorAction Stop
            [Console]::WriteLine($content)
        } catch {
            Write-Host "Error reading file: $($_.Exception.Message)" -ForegroundColor Red
            exit 1
        }
    } elseif ($extension -eq ".pdf") {
        Write-Host "PDF file detected. Content preview:" -ForegroundColor Yellow
        Write-Host "File: $FilePath" -ForegroundColor Gray
        Write-Host "Size: $((Get-Item $FilePath).Length / 1KB) KB" -ForegroundColor Gray
        Write-Host "Modified: $((Get-Item $FilePath).LastWriteTime)" -ForegroundColor Gray
        Write-Host ""
        Write-Host "Note: PDF content extraction requires additional tools." -ForegroundColor Yellow
        Write-Host "For PDF analysis, consider using:" -ForegroundColor Yellow
        Write-Host "  - PowerShell PDF parsing libraries" -ForegroundColor Gray
        Write-Host "  - External tools like pdftotext" -ForegroundColor Gray
    } else {
        Write-Host "File type: $extension" -ForegroundColor Yellow
        Write-Host "File info:" -ForegroundColor Cyan
        $fileInfo = Get-Item $FilePath
        [Console]::WriteLine("Name: $($fileInfo.Name)")
        [Console]::WriteLine("FullName: $($fileInfo.FullName)")
        [Console]::WriteLine("Size: $($fileInfo.Length) bytes")
        [Console]::WriteLine("Created: $($fileInfo.CreationTime)")
        [Console]::WriteLine("Modified: $($fileInfo.LastWriteTime)")
    }
} else {
    Write-Host "File does not exist: $FilePath" -ForegroundColor Red
    exit 1
}
