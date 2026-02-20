---
name: nas
description: Access and manage files on NAS (Network Attached Storage) via SMB/CIFS. Use when user mentions NAS, network storage, accessing files on \\nas, SMB shares, or network drives. Handles connection setup, path mapping, encoding issues with Japanese characters, and file operations.
---

# NAS Access

Access and manage files on Network Attached Storage (NAS) via SMB/CIFS protocol.

## ⚠️ Critical Rules

### Rule 1: No Notion API Keys
**DO NOT include Notion API keys or any Notion-related environment variables when executing NAS operations.** NAS access is completely independent from Notion and requires only SMB/CIFS credentials (`nas\weng` and password `19801502`).

### Rule 2: PowerShell Syntax - NO && or ||
**PowerShell does NOT support `&&` or `||` operators!**

**❌ WRONG:**
```powershell
chcp 65001 && $Nas = '\\nas\homes\weng'
chcp 65001 || echo "failed"
```

**✅ CORRECT - Use semicolons:**
```powershell
chcp 65001; $Nas = '\\nas\homes\weng'
```

**✅ CORRECT - Use separate commands:**
```powershell
chcp 65001
$Nas = '\\nas\homes\weng'
```

### Rule 3: Set Encoding BEFORE Variables
**Always set encoding BEFORE defining variables with Japanese characters.**

**❌ WRONG:**
```powershell
$Nas = '\\nas\homes\weng\履歴書'  # Encoding not set - Japanese chars become garbled
chcp 65001
```

**✅ CORRECT:**
```powershell
chcp 65001 | Out-Null
[Console]::OutputEncoding = [System.Text.Encoding]::UTF8
$OutputEncoding = [System.Text.Encoding]::UTF8
$Nas = '\\nas\homes\weng\履歴書'  # Now Japanese chars are correct
```

### Rule 4: Verify Variables Before Use
**Always verify path variables exist before using them.**

**❌ WRONG:**
```powershell
$filePath = Join-Path $Nas 'file.pdf'  # $Nas might be null
Get-Content $filePath  # Error: Parameter 'Path' cannot accept null
```

**✅ CORRECT:**
```powershell
chcp 65001 | Out-Null
[Console]::OutputEncoding = [System.Text.Encoding]::UTF8
$Nas = '\\nas\homes\weng\履歴書'
if ($Nas) {
    $filePath = Join-Path $Nas 'file.pdf'
    if (Test-Path $filePath) {
        Get-Content $filePath
    }
}
```

## Quick Start

### Using Mapped Drive M:\ (DIRECT PowerShell - RECOMMENDED)

**⚠️ IMPORTANT: PowerShell may not see mapped drives from File Explorer!**

**If `\\nas\homes` is mapped to `M:\` in File Explorer but PowerShell can't access it:**

**Problem**: File Explorer shows M:\ mapped, but PowerShell says "drive not found"

**Solution 1: Remap in PowerShell session (RECOMMENDED)**
```powershell
# Remap M:\ drive in current PowerShell session
net use M: \\nas\homes 19801502 /user:nas\weng /persistent:yes

# Verify it's accessible
Test-Path "M:\"
Get-ChildItem "M:\weng"
```

**Solution 2: Use UNC path directly (if remapping fails)**
```powershell
# Connect to UNC path directly
net use \\nas\homes 19801502 /user:nas\weng /persistent:yes

# Use UNC path instead of M:\
Get-ChildItem "\\nas\homes\weng\履歴書"
```

**If M:\ is accessible in PowerShell, use these commands:**

**List files:**
```powershell
# Set encoding first (for Japanese characters)
chcp 65001 | Out-Null
[Console]::OutputEncoding = [System.Text.Encoding]::UTF8
$OutputEncoding = [System.Text.Encoding]::UTF8

# Verify M:\ is accessible
if (Test-Path "M:\") {
    Write-Host "✅ M:\ drive is accessible" -ForegroundColor Green
    # List files in 履歴書 directory
    Get-ChildItem "M:\weng\履歴書"
} else {
    Write-Host "❌ M:\ drive not accessible in PowerShell" -ForegroundColor Red
    Write-Host "Remapping..." -ForegroundColor Yellow
    net use M: \\nas\homes 19801502 /user:nas\weng /persistent:yes
}
```

**List PDF files:**
```powershell
# Set encoding
chcp 65001 | Out-Null; [Console]::OutputEncoding = [System.Text.Encoding]::UTF8; $OutputEncoding = [System.Text.Encoding]::UTF8

# List all PDF files
Get-ChildItem "M:\weng\履歴書" -Filter "*.pdf" | Select-Object Name, Length, LastWriteTime
```

**Read PDF file directly:**
```powershell
# Set encoding
chcp 65001 | Out-Null; [Console]::OutputEncoding = [System.Text.Encoding]::UTF8; $OutputEncoding = [System.Text.Encoding]::UTF8

# Read PDF using Python script
$filePath = "M:\weng\履歴書\2025-04-10_職務経歴書.pdf"
if (Test-Path -LiteralPath $filePath) {
    python C:\Users\wengzheng\.openclaw\workspace\skills\nas\extract-pdf-text.py $filePath 10
} else {
    Write-Host "File not found. Available PDFs:" -ForegroundColor Yellow
    Get-ChildItem "M:\weng\履歴書" -Filter "*.pdf" | Select-Object Name
}
```

**One-line command to read PDF:**
```powershell
chcp 65001 | Out-Null; [Console]::OutputEncoding = [System.Text.Encoding]::UTF8; $OutputEncoding = [System.Text.Encoding]::UTF8; $filePath = "M:\weng\履歴書\2025-04-10_職務経歴書.pdf"; if (Test-Path -LiteralPath $filePath) { python C:\Users\wengzheng\.openclaw\workspace\skills\nas\extract-pdf-text.py $filePath 10 } else { Write-Host "File not found"; Get-ChildItem "M:\weng\履歴書" -Filter "*.pdf" | Select-Object Name }
```

### Connect to NAS (if M:\ not mapped)

**Correct syntax:**
```powershell
# Connect to homes share using Format 1: password after share path
net use \\nas\homes 19801502 /user:nas\weng /persistent:yes

# Verify connection
net use | Select-String "\\\\nas"
```

**⚠️ Common net use syntax errors:**

**❌ WRONG - Missing password:**
```powershell
net use \\nas\homes /user:nas\weng /persistent:yes
# Missing password - will prompt or fail
```

**❌ WRONG - Wrong parameter order:**
```powershell
net use /user:nas\weng \\nas\homes 19801502
# Wrong: /user must come after share path
```

**✅ CORRECT:**
```powershell
# Method 1: Password after share path
net use \\nas\homes 19801502 /user:nas\weng /persistent:yes

# Method 2: Password after /user (also valid)
net use \\nas\homes 19801502 /user:nas\weng /persistent:yes
```

### Access Files

```powershell
# List files in user directory
Get-ChildItem "\\nas\homes\weng"

# Access subdirectory
Get-ChildItem "\\nas\homes\weng\履歴書"
```

## Configuration

- **NAS Share**: `\\nas\homes` (this is what you map to a drive letter)
- **NAS UNC Path**: `\\nas\homes\weng` (full path to user directory)
- **Mapped Drive**: `M:\` maps to `\\nas\homes` (if mapped)
- **Mapped Drive Path**: `M:\weng` = `\\nas\homes\weng` (after mapping)
- **Username**: `nas\weng`
- **Password**: `19801502`

**Mapping relationship:**
- Map: `net use M: \\nas\homes ...`
- Result: `M:\` = `\\nas\homes`
- Access: `M:\weng\履歴書` = `\\nas\homes\weng\履歴書`

**Preferred method**: Map `\\nas\homes` to `M:\` drive - simpler and more reliable.

## Common Operations

### List Files

**Using mapped drive M:\ (DIRECT - No net use needed):**
```powershell
# Set encoding
chcp 65001 | Out-Null
[Console]::OutputEncoding = [System.Text.Encoding]::UTF8
$OutputEncoding = [System.Text.Encoding]::UTF8

# List files directly from M:\
Get-ChildItem "M:\weng"

# List files in 履歴書 directory
Get-ChildItem "M:\weng\履歴書"

# List only PDF files
Get-ChildItem "M:\weng\履歴書" -Filter "*.pdf"
```

**Using UNC path (if M:\ not mapped):**
```powershell
# Connect first
net use \\nas\homes 19801502 /user:nas\weng /persistent:yes

# List files
Get-ChildItem "\\nas\homes\weng"
```

### Read File

**Simple text file:**
```powershell
Get-Content "\\nas\homes\weng\file.txt"
```

**File with Japanese characters in path:**
```powershell
# Set encoding first
chcp 65001 | Out-Null
[Console]::OutputEncoding = [System.Text.Encoding]::UTF8
$OutputEncoding = [System.Text.Encoding]::UTF8

# Connect to NAS
net use \\nas\homes 19801502 /user:nas\weng /persistent:yes

# Read file using full path
$filePath = "\\nas\homes\weng\履歴書\履歴書.docx"
Get-Content -LiteralPath $filePath
```

**Get file info (size, name, etc.):**
```powershell
$filePath = "\\nas\homes\weng\履歴書\履歴書.docx"
Get-ChildItem -LiteralPath $filePath | Select-Object Name, Length, LastWriteTime
```

### Read PDF Files

**⚠️ CRITICAL: PDF files are BINARY format - cannot be read as text!**

**DO NOT attempt these methods (they will NOT work):**
- ❌ `Get-Content "file.pdf"` - Shows binary garbage, not readable text
- ❌ `Get-Content "file.pdf" -First 10` - Still binary data
- ❌ Reading raw bytes - PDF structure is complex, bytes don't translate to text
- ❌ Using text editors - PDF requires parsing, not direct text reading

**✅ MUST use PDF extraction tools:**
- PyPDF2 (Python library)
- pdftotext (poppler-utils)
- Word COM object
- PDF parsing libraries

**Method 1: Using mapped drive M:\ (DIRECT PowerShell - EASIEST)**

**Direct PowerShell commands (no scripts needed):**

**Step 1: Set encoding and verify M:\ drive:**
```powershell
# Set encoding
chcp 65001 | Out-Null
[Console]::OutputEncoding = [System.Text.Encoding]::UTF8
$OutputEncoding = [System.Text.Encoding]::UTF8

# Verify M:\ drive exists
if (Test-Path "M:\") {
    Write-Host "✅ M:\ drive is available" -ForegroundColor Green
} else {
    Write-Host "❌ M:\ drive not found. Map it first:" -ForegroundColor Red
    Write-Host "  net use M: \\nas\homes 19801502 /user:nas\weng /persistent:yes" -ForegroundColor Yellow
}
```

**Step 2: List PDF files:**
```powershell
# Set encoding
chcp 65001 | Out-Null; [Console]::OutputEncoding = [System.Text.Encoding]::UTF8; $OutputEncoding = [System.Text.Encoding]::UTF8

# Check if M:\ drive exists
if (Test-Path "M:\") {
    Write-Host "Mapped drive M:\ is available" -ForegroundColor Green
    
    # List PDF files in 履歴書 directory
    $resumeDir = "M:\weng\履歴書"
    if (Test-Path -LiteralPath $resumeDir) {
        Write-Host "`nPDF files in $resumeDir:" -ForegroundColor Cyan
        Get-ChildItem -LiteralPath $resumeDir -Filter "*.pdf" | Select-Object Name, Length, LastWriteTime | Format-Table -AutoSize
    } else {
        Write-Host "Directory not found: $resumeDir" -ForegroundColor Red
    }
} else {
    Write-Host "Mapped drive M:\ not found. Please map \\nas\homes to M:\ first" -ForegroundColor Yellow
}
```

**Step 3: Read PDF file directly (DIRECT PowerShell):**
```powershell
# Set encoding
chcp 65001 | Out-Null; [Console]::OutputEncoding = [System.Text.Encoding]::UTF8; $OutputEncoding = [System.Text.Encoding]::UTF8

# Use mapped drive M:\ - no net use needed!
$filePath = "M:\weng\履歴書\2025-04-10_職務経歴書.pdf"
if (Test-Path -LiteralPath $filePath) {
    # Extract PDF text using Python script
    python C:\Users\wengzheng\.openclaw\workspace\skills\nas\extract-pdf-text.py $filePath 10
} else {
    Write-Host "File not found: $filePath" -ForegroundColor Red
    Write-Host "Available PDF files:" -ForegroundColor Yellow
    Get-ChildItem "M:\weng\履歴書" -Filter "*.pdf" | Select-Object Name, Length, LastWriteTime | Format-Table -AutoSize
}
```

**Complete one-line command (with auto-remapping if needed):**
```powershell
chcp 65001 | Out-Null; [Console]::OutputEncoding = [System.Text.Encoding]::UTF8; $OutputEncoding = [System.Text.Encoding]::UTF8; if (-not (Test-Path "M:\")) { Write-Host "Remapping M:\ drive..." -ForegroundColor Yellow; net use M: \\nas\homes 19801502 /user:nas\weng /persistent:yes }; if (Test-Path "M:\") { $filePath = "M:\weng\履歴書\2025-04-10_職務経歴書.pdf"; if (Test-Path -LiteralPath $filePath) { python C:\Users\wengzheng\.openclaw\workspace\skills\nas\extract-pdf-text.py $filePath 10 } else { Write-Host "File not found. Available PDFs:"; Get-ChildItem "M:\weng\履歴書" -Filter "*.pdf" | Select-Object Name } } else { Write-Host "M:\ drive not accessible. Using UNC path..."; net use \\nas\homes 19801502 /user:nas\weng /persistent:yes; $filePath = "\\nas\homes\weng\履歴書\2025-04-10_職務経歴書.pdf"; if (Test-Path -LiteralPath $filePath) { python C:\Users\wengzheng\.openclaw\workspace\skills\nas\extract-pdf-text.py $filePath 10 } }
```

**Advantages of using M:\ directly:**
- ✅ No `net use` command needed (if already mapped)
- ✅ Simpler paths
- ✅ Better tool compatibility
- ✅ Avoids encoding issues

**Method 2: Using PowerShell PDF extraction script**

**Option A: With automatic PyPDF2 installation**
```powershell
# This script will check and install PyPDF2 if needed
C:\Users\wengzheng\.openclaw\workspace\skills\nas\read-pdf-with-install.ps1 -FilePath "\\nas\homes\weng\履歴書\2025-04-10_職務経歴書.pdf"
```

**Option B: Manual script**
```powershell
# Use the dedicated PDF reading script (requires PyPDF2 installed)
C:\Users\wengzheng\.openclaw\workspace\skills\nas\read-nas-pdf.ps1 -FilePath "\\nas\homes\weng\履歴書\2025-04-10_職務経歴書.pdf"
```

**Method 2: Using Python with PyPDF2 or pdfplumber**

**Option A: PyPDF2 (Lightweight)**

**⚠️ IMPORTANT: Install PyPDF2 first!**
```powershell
# Install PyPDF2 module
pip install PyPDF2
```

**Complete workflow (RECOMMENDED - Use script):**
```powershell
# Method 1: Use dedicated analysis script (BEST - handles everything)
C:\Users\wengzheng\.openclaw\workspace\skills\nas\read-and-analyze-pdf.ps1 -FilePath "\\nas\homes\weng\履歴書\2025-04-10_職務経歴書.pdf"

# Method 2: Manual steps with script file (if you need more control)
chcp 65001 | Out-Null; [Console]::OutputEncoding = [System.Text.Encoding]::UTF8; $OutputEncoding = [System.Text.Encoding]::UTF8; net use \\nas\homes 19801502 /user:nas\weng /persistent:yes; $filePath = "\\nas\homes\weng\履歴書\2025-04-10_職務経歴書.pdf"; if (Test-Path -LiteralPath $filePath) { python C:\Users\wengzheng\.openclaw\workspace\skills\nas\extract-pdf-text.py $filePath 10 } else { Write-Host "File not found: $filePath" }
```

**⚠️ DO NOT use complex inline Python code - PowerShell will parse it incorrectly!**

**⚠️ IMPORTANT: Avoid inline Python with complex code**

**❌ WRONG - PowerShell will parse Python syntax incorrectly:**
```powershell
python -c "import PyPDF2; f=open(r'\\nas\homes\weng\履歴書\file.pdf','rb'); r=PyPDF2.PdfReader(f); for i, page in enumerate(r.pages): print(page.extract_text())"
# PowerShell will try to parse the Python code and fail
```

**✅ CORRECT - Use script file (RECOMMENDED):**
```powershell
# Set encoding and connect
chcp 65001 | Out-Null; [Console]::OutputEncoding = [System.Text.Encoding]::UTF8; $OutputEncoding = [System.Text.Encoding]::UTF8; net use \\nas\homes 19801502 /user:nas\weng /persistent:yes

# Use dedicated script
$filePath = "\\nas\homes\weng\履歴書\2025-04-10_職務経歴書.pdf"
if (Test-Path -LiteralPath $filePath) {
    python C:\Users\wengzheng\.openclaw\workspace\skills\nas\extract-pdf-text.py $filePath 10
} else {
    Write-Host "File not found"
}
```

**✅ CORRECT - Simple inline Python (only for very simple commands):**
```powershell
# Set encoding and connect
chcp 65001 | Out-Null; [Console]::OutputEncoding = [System.Text.Encoding]::UTF8; $OutputEncoding = [System.Text.Encoding]::UTF8; net use \\nas\homes 19801502 /user:nas\weng /persistent:yes

# Simple one-liner (no loops, no complex syntax)
$filePath = "\\nas\homes\weng\履歴書\2025-04-10_職務経歴書.pdf"
python -c "import PyPDF2; print(PyPDF2.PdfReader(open(r'$filePath','rb')).pages[0].extract_text())"
```

**Using the dedicated Python script:**
```powershell
# Set encoding and connect
chcp 65001 | Out-Null; [Console]::OutputEncoding = [System.Text.Encoding]::UTF8; $OutputEncoding = [System.Text.Encoding]::UTF8; net use \\nas\homes 19801502 /user:nas\weng /persistent:yes

# Run script
$filePath = "\\nas\homes\weng\履歴書\2025-04-10_職務経歴書.pdf"; if (Test-Path -LiteralPath $filePath) { python C:\Users\wengzheng\.openclaw\workspace\skills\nas\extract-pdf-text.py $filePath 10 } else { Write-Host "File not found" }
```

**Complete Python script for PDF extraction:**
```python
# Save as extract-pdf.py
import PyPDF2
import sys

file_path = r"\\nas\homes\weng\履歴書\2025-04-10_職務経歴書.pdf"

try:
    with open(file_path, 'rb') as f:
        reader = PyPDF2.PdfReader(f)
        text = ""
        for page in reader.pages[:10]:  # First 10 pages
            text += page.extract_text() + "\n"
        print(text)
except Exception as e:
    print(f"Error: {e}", file=sys.stderr)
    sys.exit(1)
```

**Execute Python script:**
```powershell
# Set encoding first
chcp 65001 | Out-Null
[Console]::OutputEncoding = [System.Text.Encoding]::UTF8
$OutputEncoding = [System.Text.Encoding]::UTF8

# Connect to NAS
net use \\nas\homes 19801502 /user:nas\weng /persistent:yes

# Verify file exists
$filePath = "\\nas\homes\weng\履歴書\2025-04-10_職務経歴書.pdf"
if (Test-Path -LiteralPath $filePath) {
    # Run Python script
    python C:\Users\wengzheng\.openclaw\workspace\skills\nas\extract-pdf-text.py $filePath 10
}
```

**One-line Python command (if PyPDF2 is installed):**
```powershell
# Set encoding and connect
chcp 65001 | Out-Null; [Console]::OutputEncoding = [System.Text.Encoding]::UTF8; $OutputEncoding = [System.Text.Encoding]::UTF8; net use \\nas\homes 19801502 /user:nas\weng /persistent:yes

# Extract PDF text
$filePath = "\\nas\homes\weng\履歴書\2025-04-10_職務経歴書.pdf"; if (Test-Path -LiteralPath $filePath) { python -c "import PyPDF2; f=open(r'$filePath','rb'); r=PyPDF2.PdfReader(f); [print(p.extract_text()) for p in r.pages[:10]]" }
```

**Option B: pdfplumber (Better text extraction, handles tables)**

**Install pdfplumber:**
```powershell
pip install pdfplumber
```

**Use pdfplumber (single-line command):**
```powershell
# Set encoding and connect
chcp 65001 | Out-Null; [Console]::OutputEncoding = [System.Text.Encoding]::UTF8; $OutputEncoding = [System.Text.Encoding]::UTF8; net use \\nas\homes 19801502 /user:nas\weng /persistent:yes

# Extract PDF text with pdfplumber
$filePath = "\\nas\homes\weng\履歴書\2025-04-10_職務経歴書.pdf"; if (Test-Path -LiteralPath $filePath) { python -c "import pdfplumber; f=pdfplumber.open(r'$filePath'); [print(f'--- Page {i+1} ---\n{p.extract_text()}') for i,p in enumerate(f.pages[:10])]; f.close()" } else { Write-Host "File not found" }
```

**Install PyPDF2 (REQUIRED before use):**
```powershell
# Check if PyPDF2 is installed
python -c "import PyPDF2; print('PyPDF2 installed')" 2>$null
if ($LASTEXITCODE -ne 0) {
    Write-Host "Installing PyPDF2..." -ForegroundColor Yellow
    pip install PyPDF2
}
```

**⚠️ Common Errors:**

**Error 1: "ModuleNotFoundError: No module named 'PyPDF2'"**
- **Solution**: Install PyPDF2: `pip install PyPDF2`
- **Verify**: `python -c "import PyPDF2; print('OK')"`

**Error 2: "ModuleNotFoundError: No module named 'pdfplumber'"**
- **Solution**: Install pdfplumber: `pip install pdfplumber`
- **Note**: pdfplumber requires additional dependencies, may take longer to install

**Error 3: "SyntaxError: unexpected character after line continuation character"**
- **Cause**: Multi-line Python code in single-line command with incorrect escaping
- **Solution**: Use single-line Python code or save to script file

**⚠️ PDF Files Cannot Be Read with Get-Content**
- PDF files are **binary format**, not text files
- `Get-Content` will show garbled binary data, not readable text
- **Must use PDF extraction tools** (PyPDF2, pdfplumber, pdftotext, Word COM, etc.)

**Method 2: Manual PowerShell with PDF library**
```powershell
# Set encoding
chcp 65001 | Out-Null
[Console]::OutputEncoding = [System.Text.Encoding]::UTF8
$OutputEncoding = [System.Text.Encoding]::UTF8

# Connect to NAS
net use \\nas\homes 19801502 /user:nas\weng /persistent:yes

# Install PDF library if needed (one-time)
# Install-Module -Name PdfSharp -Scope CurrentUser -Force

# Extract PDF text
$filePath = "\\nas\homes\weng\履歴書\2025-04-10_職務経歴書.pdf"
if (Test-Path -LiteralPath $filePath) {
    # Use PDF extraction method (see read-nas-pdf.ps1 for implementation)
    Write-Host "Extracting PDF content..."
    # PDF extraction code here
}
```

**Method 3: Using read-nas-file-direct.ps1 (shows file info only)**
```powershell
# This script shows PDF file metadata but cannot extract text
C:\Users\wengzheng\.openclaw\workspace\skills\nas\read-nas-file-direct.ps1 -FilePath "\\nas\homes\weng\履歴書\2025-04-10_職務経歴書.pdf"
```

**Supported file types for text extraction:**
- ✅ **Text files**: `.txt`, `.md`, `.json`, `.csv`, `.log`, `.ps1`, `.py`, `.js`, `.html`, `.xml`
- ✅ **PDF files**: `.pdf` (requires PDF extraction script)
- ⚠️ **Office files**: `.docx`, `.xlsx`, `.pptx` (may require additional tools)

### Using Read Tool (OpenClaw)

**⚠️ Important: Always verify path exists before calling read tool**

**Step 1: Verify file exists and get correct path**
```powershell
# Set encoding
chcp 65001 | Out-Null
[Console]::OutputEncoding = [System.Text.Encoding]::UTF8
$OutputEncoding = [System.Text.Encoding]::UTF8

# Connect
net use \\nas\homes 19801502 /user:nas\weng /persistent:yes

# Verify file exists
$filePath = "\\nas\homes\weng\履歴書\履歴書.docx"
if (Test-Path -LiteralPath $filePath) {
    $file = Get-ChildItem -LiteralPath $filePath
    Write-Host "File found: $($file.FullName)"
    Write-Host "Size: $($file.Length) bytes"
} else {
    Write-Host "File not found: $filePath" -ForegroundColor Red
    exit 1
}
```

**Step 2: Use read tool with verified path**
```json
{
  "path": "\\\\nas\\homes\\weng\\履歴書\\履歴書.docx"
}
```

**Common error: "read tool called without path"**
- **Cause**: Path variable is empty or undefined
- **Solution**: Always verify path exists first using `Test-Path` before calling read tool

**Best practice workflow:**
1. Set encoding
2. Connect to NAS
3. Verify file exists with `Test-Path`
4. Get full path from `Get-ChildItem`
5. Use read tool with verified path

### Copy File

```powershell
Copy-Item "\\nas\homes\weng\source.txt" -Destination "local.txt"
```

### Search Files

```powershell
Get-ChildItem "\\nas\homes\weng" -Recurse -Filter "*.pdf"
```

## Handling Japanese Characters

When accessing paths with Japanese characters, **ALWAYS follow these steps in order**:

```powershell
# Step 1: Set UTF-8 encoding (MUST be first, BEFORE any variables with Japanese chars)
[Console]::OutputEncoding = [System.Text.Encoding]::UTF8
$OutputEncoding = [System.Text.Encoding]::UTF8
chcp 65001 | Out-Null

# Step 2: Connect to NAS share (REQUIRED before accessing files)
# Format 1: Password after share path
net use \\nas\homes 19801502 /user:nas\weng /persistent:yes

# Step 3: Define paths with Japanese characters (AFTER encoding is set)
$targetPath = "\\nas\homes\weng\履歴書"

# Step 4: Access Japanese paths using the variable
Get-ChildItem $targetPath
```

### ⚠️ Critical: Encoding Must Be Set FIRST

**If encoding is not set BEFORE defining variables with Japanese characters, you'll get garbled text like `������`**

**Wrong order (will cause encoding errors):**
```powershell
# ❌ WRONG - Defining path before setting encoding
$Nas = "\\nas\homes\weng"
$path = "$Nas\履歴書"  # 履歴書 becomes ������
Get-ChildItem -LiteralPath "$path\履歴書.docx"  # All Japanese chars are garbled
```

**Correct order:**
```powershell
# ✅ CORRECT - Set encoding FIRST
chcp 65001 | Out-Null
[Console]::OutputEncoding = [System.Text.Encoding]::UTF8
$OutputEncoding = [System.Text.Encoding]::UTF8

# Now define paths with Japanese characters
$Nas = "\\nas\homes\weng"
$path = "$Nas\履歴書"  # Japanese chars are preserved correctly
Get-ChildItem -LiteralPath "$path\履歴書.docx"
```

### ⚠️ Set-Location with Japanese Paths

**While `Set-Location` may work if encoding is set correctly, it's NOT recommended:**

**Not recommended (may fail in some contexts):**
```powershell
Set-Location -Path "$Nas\履歴書"  # May work, but risky
Dir "履歴書.docx"
```

**Recommended (more reliable):**
```powershell
# Use full path directly with -LiteralPath
$fullPath = "$Nas\履歴書\履歴書.docx"
Get-ChildItem -LiteralPath $fullPath
```

**Why avoid Set-Location:**
- Current directory changes can cause issues in scripts
- Path resolution may fail if encoding isn't perfect
- Full paths are more explicit and debuggable

### Complete Example: List Files in Japanese Directory

**Simple single-line command:**
```powershell
[Console]::OutputEncoding = [System.Text.Encoding]::UTF8; $OutputEncoding = [System.Text.Encoding]::UTF8; chcp 65001 | Out-Null; net use \\nas\homes 19801502 /user:nas\weng /persistent:yes; $path = "\\nas\homes\weng\履歴書"; if (Test-Path $path) { Get-ChildItem $path -Force -Recurse | Select-Object FullName, Name } else { Write-Host "路径不存在: $path" }
```

**Robust script with connection check and retry:**
```powershell
# Step 1: Set UTF-8 encoding
[Console]::OutputEncoding = [System.Text.Encoding]::UTF8
$OutputEncoding = [System.Text.Encoding]::UTF8
chcp 65001 | Out-Null

# Step 2: Define paths
$nasShare = "\\nas\homes"
$userPath = "\\nas\homes\weng"
$targetPath = "\\nas\homes\weng\履歴書"

# Step 3: Clean existing connections (prevent permission conflicts)
net use \\nas\* /delete /yes 2>$null
net use * /delete /yes 2>$null

# Step 4: Establish new connection
net use $nasShare 19801502 /user:nas\weng /persistent:yes

# Step 5: Verify connection
if (-not (Test-Path $userPath)) {
    Write-Host "错误: 无法连接到 $nasShare" -ForegroundColor Red
    Write-Host "请检查网络连接和凭据" -ForegroundColor Yellow
    exit 1
}

# Step 6: Access target directory
if (Test-Path $targetPath) {
    $files = Get-ChildItem $targetPath -Force -Recurse
    if ($files.Count -gt 0) {
        $files | Select-Object FullName, Name, Length, LastWriteTime | Format-Table -AutoSize
    } else {
        Write-Host "目录存在但为空: $targetPath"
    }
} else {
    Write-Host "路径不存在: $targetPath" -ForegroundColor Yellow
    Write-Host "可用目录:" -ForegroundColor Cyan
    Get-ChildItem $userPath -Directory | Select-Object Name
}
```

**Single-line version (for JSON/API calls) - WITH encoding:**
```powershell
chcp 65001 | Out-Null; [Console]::OutputEncoding = [System.Text.Encoding]::UTF8; $OutputEncoding = [System.Text.Encoding]::UTF8; net use \\nas\* /delete /yes 2>$null; net use \\nas\homes 19801502 /user:nas\weng /persistent:yes; $path = "\\nas\homes\weng\履歴書"; if (Test-Path $path) { Get-ChildItem $path -Force | Format-List Name, FullName } else { Write-Host "路径不存在: $path" }
```

**Note:** In single-line commands, encoding MUST be the first thing executed, and paths with Japanese characters should be stored in variables AFTER encoding is set.

**Important Notes:**
- `Test-Path` returns `$true`/`$false`, NOT exit codes - use `if (-not (Test-Path ...))` not `$LASTEXITCODE`
- Always use double quotes for paths with variables: `"$path"` not `'$path'`
- Check connection BEFORE accessing files

**Alternative methods**:
- Use variable: `$path = "\\nas\homes\weng\履歴書"; Get-ChildItem $path`
- Use -LiteralPath: `Get-ChildItem -LiteralPath "\\nas\homes\weng\履歴書"`
- Use backtick escape: `Get-ChildItem "`\\nas\homes\weng\履歴書"`

## Common Mistakes to Avoid

### ❌ Error 1: Missing Connection Step

**Wrong:**
```powershell
# Missing net use connection
Get-ChildItem "\\nas\homes\weng\履歴書"
```

**Correct:**
```powershell
net use \\nas\homes 19801502 /user:nas\weng /persistent:yes
Get-ChildItem "\\nas\homes\weng\履歴書"
```

### ❌ Error 2: Variable Not Expanding in Single Quotes

**Wrong:**
```powershell
$path = '\\nas\homes\weng\履歴書'
Write-Host '路径为：$path 不存在'  # $path won't expand
```

**Correct:**
```powershell
$path = "\\nas\homes\weng\履歴書"
Write-Host "路径为：$path 不存在"  # Use double quotes
```

### ❌ Error 3: Wrong Order of Operations

**Wrong:**
```powershell
# Accessing files before connecting
Get-ChildItem "\\nas\homes\weng\履歴書"
net use \\nas\homes 19801502 /user:nas\weng
```

**Correct:**
```powershell
# Connect first, then access
net use \\nas\homes 19801502 /user:nas\weng /persistent:yes
Get-ChildItem "\\nas\homes\weng\履歴書"
```

### ❌ Error 4: Using $LASTEXITCODE with Test-Path

**Wrong:**
```powershell
Test-Path $path | Out-Null
if ($LASTEXITCODE -ne 0) { ... }  # Test-Path doesn't set exit codes!
```

**Correct:**
```powershell
if (-not (Test-Path $path)) {  # Test-Path returns boolean
    Write-Host "路径不存在: $path"
}
```

### ❌ Error 5: Wrong Path in net use Command

**Wrong:**
```powershell
# Using wrong share path
net use \\nas\home 19801502 /user:nas\weng  # Should be \\nas\homes
```

**Correct:**
```powershell
# Use correct share path
net use \\nas\homes 19801502 /user:nas\weng /persistent:yes
```

### ❌ Error 6: Incorrect net use DELETE Syntax

**Wrong:**
```powershell
net use \\\\nas\\\\homes\\*/DELETE/YES  # Wrong: extra backslashes, wrong format
```

**Correct:**
```powershell
# Delete all connections to nas
net use \\nas\* /delete /yes

# Or delete specific share
net use \\nas\homes /delete /yes
```

### ❌ Error 7: Encoding Not Set Before Japanese Characters

**Wrong:**
```powershell
# Defining path with Japanese chars before encoding
$Nas = "\\nas\homes\weng"
$path = "$Nas\履歴書"  # 履歴書 becomes ������ (garbled)
Get-ChildItem "$path\履歴書.docx"  # Error: path not found (garbled chars)
```

**Correct:**
```powershell
# Set encoding FIRST
chcp 65001 | Out-Null
[Console]::OutputEncoding = [System.Text.Encoding]::UTF8
$OutputEncoding = [System.Text.Encoding]::UTF8

# Then define paths
$Nas = "\\nas\homes\weng"
$path = "$Nas\履歴書"  # Japanese chars preserved correctly
Get-ChildItem -LiteralPath "$path\履歴書.docx"
```

### ❌ Error 8: Using Set-Location with Japanese Paths (Not Recommended)

**While this may work in some cases, it's unreliable:**
```powershell
Set-Location -Path "$Nas\履歴書"  # May work but risky
Dir "履歴書.docx"  # May fail if encoding isn't perfect
```

**Recommended approach:**
```powershell
# Use full path directly with -LiteralPath (more reliable)
$fullPath = "$Nas\履歴書\履歴書.docx"
Get-ChildItem -LiteralPath $fullPath
```

**Why avoid Set-Location:**
- Current directory context can cause issues in scripts/APIs
- Path resolution failures are harder to debug
- Full paths are explicit and work consistently

### ❌ Error 9: Read Tool Called Without Path

**Error message:**
```
read tool called without path: toolCallId=... argsType=object
```

**Cause:**
- Path variable is empty or undefined
- Path verification failed before calling read tool
- Encoding issue caused path to be empty/garbled

**Solution:**
```powershell
# Step 1: Set encoding FIRST
chcp 65001 | Out-Null
[Console]::OutputEncoding = [System.Text.Encoding]::UTF8
$OutputEncoding = [System.Text.Encoding]::UTF8

# Step 2: Connect
net use \\nas\homes 19801502 /user:nas\weng /persistent:yes

# Step 3: Verify path exists BEFORE calling read tool
$filePath = "\\nas\homes\weng\履歴書\履歴書.docx"
if (-not (Test-Path -LiteralPath $filePath)) {
    Write-Host "Error: File not found: $filePath" -ForegroundColor Red
    # List available files instead
    Get-ChildItem "\\nas\homes\weng\履歴書" | Select-Object Name, FullName
    exit 1
}

# Step 4: Get verified full path
$verifiedPath = (Get-ChildItem -LiteralPath $filePath).FullName
Write-Host "Verified path: $verifiedPath"

# Step 5: Now safe to use read tool with $verifiedPath
```

**Key points:**
- Always verify path exists before calling read tool
- Use `Test-Path` to check existence
- Get full path from `Get-ChildItem` result
- Never call read tool with empty/undefined path variable

### ❌ Error 10: Using && or || in PowerShell

**Error message:**
```
'&&' は、このオペレーティング システムでは有効なステートメント区切り文字ではありません。
```

**Wrong:**
```powershell
chcp 65001 && $Nas = '\\nas\homes\weng'
cd C:\path && dir
chcp 65001 || echo "failed"
```

**Correct:**
```powershell
# Use semicolon (;)
chcp 65001; $Nas = '\\nas\homes\weng'
cd C:\path; dir

# Or separate commands
chcp 65001
$Nas = '\\nas\homes\weng'

# Using mapped drive M:\ (no cd needed)
chcp 65001 | Out-Null; [Console]::OutputEncoding = [System.Text.Encoding]::UTF8; $OutputEncoding = [System.Text.Encoding]::UTF8; Get-ChildItem "M:\weng\履歴書"
```

### ❌ Error 11: Variable is Null When Used

**Error message:**
```
パラメーター 'Path' に null を指定できないため、パラメーター 'Path' にバインドできません。
```

**Cause:**
- Variable defined in different command scope
- Encoding not set before defining variable with Japanese chars
- Variable assignment failed silently

**Wrong:**
```powershell
# Command 1
chcp 65001

# Command 2 (separate exec call)
$Nas = '\\nas\homes\weng\履歴書'  # May fail if encoding not set

# Command 3 (separate exec call)
$filePath = Join-Path $Nas 'file.pdf'  # $Nas is null!
Get-Content $filePath  # Error: Path cannot be null
```

**Correct:**
```powershell
# Single command block with all steps
chcp 65001 | Out-Null
[Console]::OutputEncoding = [System.Text.Encoding]::UTF8
$OutputEncoding = [System.Text.Encoding]::UTF8
$Nas = '\\nas\homes\weng\履歴書'
if ($Nas -and (Test-Path $Nas)) {
    $filePath = Join-Path $Nas 'file.pdf'
    if (Test-Path $filePath) {
        Get-Content $filePath
    }
}
```

### ❌ Error 12: Trying to Read PDF with Get-Content

**Error**: PDF files are binary, not text files. `Get-Content` will show garbled data.

**Wrong:**
```powershell
# This will NOT work - PDF is binary format
Get-Content "\\nas\homes\weng\履歴書\2025-04-10_職務経歴書.pdf" -First 20
```

**Correct:**
```powershell
# Use PDF extraction tool
python -c "import PyPDF2; f=open(r'\\nas\homes\weng\履歴書\2025-04-10_職務経歴書.pdf','rb'); r=PyPDF2.PdfReader(f); print(r.pages[0].extract_text())"
```

### ❌ Error 13: PowerShell Parsing Python Code Incorrectly

**Error messages:**
```
パラメーターリストに予期しない文字があります
Missing '(' after 'for'
Missing argument
```

**Cause**: PowerShell tries to parse Python code as PowerShell commands when using `python -c` with complex syntax.

**Wrong (PowerShell will parse Python syntax):**
```powershell
python -c "import PyPDF2; f=open(r'\\nas\homes\weng\履歴書\file.pdf','rb'); r=PyPDF2.PdfReader(f); for i, page in enumerate(r.pages): print(page.extract_text())"
# PowerShell sees 'for' and tries to parse it as PowerShell syntax
```

**Correct (use script file - RECOMMENDED):**
```powershell
# Use dedicated script - no parsing issues
python C:\Users\wengzheng\.openclaw\workspace\skills\nas\extract-pdf-text.py "\\nas\homes\weng\履歴書\2025-04-10_職務経歴書.pdf" 10
```

**Correct (simple inline - only for very simple commands):**
```powershell
# Simple one-liner without loops or complex syntax
python -c "import PyPDF2; print(PyPDF2.PdfReader(open(r'\\nas\homes\weng\履歴書\file.pdf','rb')).pages[0].extract_text())"
```

**Best Practice**: Always use script files for complex Python code to avoid PowerShell parsing issues.

### ❌ Error 14: PyPDF2 Module Not Found

**Error message:**
```
ModuleNotFoundError: No module named 'PyPDF2'
```

**Solution:**
```powershell
# Install PyPDF2
pip install PyPDF2

# Verify installation
python -c "import PyPDF2; print('PyPDF2 installed successfully')"
```

**Complete installation and usage:**
```powershell
# Check and install if needed
python -c "import PyPDF2" 2>$null; if ($LASTEXITCODE -ne 0) { pip install PyPDF2 }

# Then use it
$filePath = "\\nas\homes\weng\履歴書\2025-04-10_職務経歴書.pdf"
python -c "import PyPDF2; f=open(r'$filePath','rb'); r=PyPDF2.PdfReader(f); [print(p.extract_text()) for p in r.pages[:10]]"
```

### ❌ Error 15: pdfplumber Module Not Found

**Error message:**
```
ModuleNotFoundError: No module named 'pdfplumber'
```

**Solution:**
```powershell
# Install pdfplumber
pip install pdfplumber

# Verify installation
python -c "import pdfplumber; print('pdfplumber installed successfully')"
```

**Note**: pdfplumber is better for extracting tables and formatted text, but requires more dependencies.

### ❌ Error 16: Script Path Error - Missing 'nas' Directory

**Error messages:**
```
ENOENT: no such file or directory, access 'C:\Users\wengzheng\.openclaw\workspace\skills\read-and-analyze-pdf.ps1'
EISDIR: illegal operation on a directory, read
```

**Cause**: Script path is missing the `nas` directory name.

**Wrong:**
```powershell
# Missing 'nas' in path
C:\Users\wengzheng\.openclaw\workspace\skills\read-and-analyze-pdf.ps1
```

**Correct:**
```powershell
# Include 'nas' directory
C:\Users\wengzheng\.openclaw\workspace\skills\nas\read-and-analyze-pdf.ps1
```

**All script paths must include `\nas\`:**
- ✅ `C:\Users\wengzheng\.openclaw\workspace\skills\nas\verify-pdf-access.ps1`
- ✅ `C:\Users\wengzheng\.openclaw\workspace\skills\nas\read-and-analyze-pdf.ps1`
- ✅ `C:\Users\wengzheng\.openclaw\workspace\skills\nas\extract-pdf-text.py`

### ❌ Error 17: Wrong Network Drive Mapping

**Error**: Mapping subdirectory instead of share, or wrong path format.

**Wrong:**
```powershell
# Mapping subdirectory (wrong)
net use M: \\nas\homes\weng /user:nas\weng 19801502

# Missing backslash (wrong)
net use M: \nas\homes /user:nas\weng 19801502
```

**Correct:**
```powershell
# Map the share (\\nas\homes), not subdirectory
net use M: \\nas\homes 19801502 /user:nas\weng /persistent:yes

# Then access: M:\weng\履歴書 (not M:\履歴書)
```

**Key points:**
- Map `\\nas\homes` (the share) to `M:\`
- Access files as `M:\weng\履歴書\file.pdf`
- `M:\` = `\\nas\homes`, so `M:\weng` = `\\nas\homes\weng`

### ❌ Error 18: net use Command Syntax Error

**Error message:**
```
このコマンドの構文は次のとおりです:
NET USE [devicename | *] [\\computername\sharename[\volume] [password | *]]
```

**Cause**: Incorrect `net use` command syntax - missing password or wrong parameter order.

**Wrong:**
```powershell
# Missing password
net use \\nas\homes /user:nas\weng /persistent:yes

# Wrong parameter order
net use /user:nas\weng \\nas\homes 19801502
```

**Correct:**
```powershell
# Method 1: Password after share path
net use \\nas\homes 19801502 /user:nas\weng /persistent:yes

# Method 2: Password after /user (also valid)
net use \\nas\homes 19801502 /user:nas\weng /persistent:yes
```

**Key points:**
- Share path (`\\nas\homes`) must come first
- Password can be before or after `/user:` parameter
- `/persistent:yes` should be last
- All parameters must be on the same line

### ❌ Error 19: Permission Errors - Not Cleaning Old Connections

**Wrong:**
```powershell
# Trying to connect without cleaning old connections first
net use \\nas\homes 19801502 /user:nas\weng
# May fail with "网络路径的访问因权限不足而终止"
```

**Correct:**
```powershell
# Clean first, then connect
net use \\nas\* /delete /yes 2>$null
net use \\nas\homes 19801502 /user:nas\weng /persistent:yes
```

## Troubleshooting

### Permission Errors ("网络路径的访问因权限不足而终止")

If you encounter permission errors, clean existing connections first:

```powershell
# Step 1: Clean all existing NAS connections
net use \\nas\* /delete /yes 2>$null

# Step 2: Reconnect with credentials
net use \\nas\homes 19801502 /user:nas\weng /persistent:yes

# Step 3: Verify connection
if (Test-Path "\\nas\homes\weng") {
    Write-Host "连接成功" -ForegroundColor Green
} else {
    Write-Host "连接失败，请检查网络和凭据" -ForegroundColor Red
}
```

### Connection Issues

```powershell
# Clean existing connections (all methods)
net use * /delete /yes 2>$null
net use \\nas\* /delete /yes 2>$null

# Reconnect
net use \\nas\homes 19801502 /user:nas\weng /persistent:yes

# Verify
net use | Select-String "\\\\nas"
```

### Path Not Found

```powershell
# List all directories to verify name
Get-ChildItem "\\nas\homes\weng" -Directory | Select-Object Name

# Search for directory
Get-ChildItem "\\nas\homes\weng" -Directory | Where-Object { $_.Name -like "*履歴*" }
```

### Encoding Issues (Garbled Japanese Characters: `������`)

If you see garbled characters like `������` instead of Japanese text, encoding was not set correctly:

**Symptoms:**
- Error: `パス '\\nas\homes\weng\������\������.docx' が見つかりません`
- Japanese characters appear as `������` or `?????`

**Solution:**
```powershell
# MUST set encoding FIRST, before any variables with Japanese characters
chcp 65001 | Out-Null
[Console]::OutputEncoding = [System.Text.Encoding]::UTF8
$OutputEncoding = [System.Text.Encoding]::UTF8

# Then define paths
$Nas = "\\nas\homes\weng"
$path = "$Nas\履歴書"  # Now Japanese chars will be correct

# Access files
Get-ChildItem -LiteralPath "$path\履歴書.docx"
```

**Common mistakes:**
1. ❌ Defining variables with Japanese chars before setting encoding
2. ❌ Using `Set-Location` with Japanese paths (use full paths instead)
3. ❌ Not setting all three encoding settings (`chcp`, `Console::OutputEncoding`, `$OutputEncoding`)

## Best Practices

1. **Always connect first**: Use `net use` to establish SMB connection BEFORE accessing files
2. **Set encoding first**: Always set UTF-8 encoding BEFORE connecting when working with non-ASCII characters
3. **Use correct order**: Encoding → Connection → File Access
4. **Verify paths**: Use `Test-Path` to check if path exists before operations
5. **Use variables**: Store paths in variables for better handling of special characters
6. **Verify before read tool**: Always verify file exists with `Test-Path` before calling read tool
7. **Get full path**: Use `Get-ChildItem` to get verified full path before passing to read tool

## Command Execution Order

**CRITICAL**: When executing NAS commands with Japanese characters, follow this exact order:

1. ✅ **Set UTF-8 encoding FIRST** (MUST be before any variables with Japanese chars)
   ```powershell
   chcp 65001 | Out-Null
   [Console]::OutputEncoding = [System.Text.Encoding]::UTF8
   $OutputEncoding = [System.Text.Encoding]::UTF8
   ```

2. ✅ **Clean old connections** (prevent permission conflicts)
   ```powershell
   net use \\nas\* /delete /yes 2>$null
   ```

3. ✅ **Connect using `net use` (Format 1)**
   ```powershell
   net use \\nas\homes 19801502 /user:nas\weng /persistent:yes
   ```

4. ✅ **Define paths with Japanese characters** (AFTER encoding is set)
   ```powershell
   $path = "\\nas\homes\weng\履歴書"
   ```

5. ✅ **Verify variables exist** (before using them)
   ```powershell
   if ($path -and (Test-Path $path)) {
       # Use the path
   }
   ```

6. ✅ **Access files using variables** (don't use Set-Location)
   ```powershell
   Get-ChildItem -LiteralPath "$path\履歴書.docx"
   ```

7. ✅ **For Python code - Use script files** (avoid inline complex Python)
   ```powershell
   # ✅ CORRECT - Use script file
   python C:\Users\wengzheng\.openclaw\workspace\skills\nas\extract-pdf-text.py $filePath
   
   # ❌ WRONG - Complex inline Python will be parsed incorrectly by PowerShell
   python -c "for i, page in enumerate(...): ..."
   ```

**DO NOT:**
- ❌ Skip encoding step
- ❌ Define variables with Japanese chars before setting encoding
- ❌ Use `Set-Location` with Japanese paths
- ❌ Access files directly without connecting first (unless using mapped drive M:\)
- ❌ Use `&&` or `||` operators (PowerShell doesn't support them - use `;` instead)
- ❌ Use `cd` with `&&` (use `cd C:\path; command` or just use full paths)
- ❌ Split variable definition and usage across separate exec calls
- ❌ Use complex inline Python code (PowerShell will parse it incorrectly)
- ❌ Use Python loops, conditionals, or complex syntax in `python -c` commands

**✅ DO:**
- ✅ Use semicolons (`;`) to chain commands in PowerShell
- ✅ Use mapped drive `M:\` if available (simpler, no net use needed)
- ✅ Use full paths instead of `cd` when possible
- ✅ Use script files for complex operations

## Complete Workflow: Reading Files with Read Tool

**Safe workflow to avoid "read tool called without path" error:**

```powershell
# Step 1: Set encoding (MUST be first)
chcp 65001 | Out-Null
[Console]::OutputEncoding = [System.Text.Encoding]::UTF8
$OutputEncoding = [System.Text.Encoding]::UTF8

# Step 2: Clean and connect
net use \\nas\* /delete /yes 2>$null
net use \\nas\homes 19801502 /user:nas\weng /persistent:yes

# Step 3: Define target path
$targetDir = "\\nas\homes\weng\履歴書"
$fileName = "履歴書.docx"
$filePath = "$targetDir\$fileName"

# Step 4: Verify path exists
if (Test-Path -LiteralPath $filePath) {
    # Get verified full path
    $verifiedPath = (Get-ChildItem -LiteralPath $filePath).FullName
    Write-Host "✅ File found: $verifiedPath"
    
    # Now safe to use read tool
    # read tool path: $verifiedPath
} else {
    Write-Host "❌ File not found: $filePath" -ForegroundColor Red
    Write-Host "Available files:" -ForegroundColor Yellow
    Get-ChildItem $targetDir | Select-Object Name, FullName
}
```

**Key checklist before calling read tool:**
- [ ] Encoding is set
- [ ] NAS connection established
- [ ] Path verified with `Test-Path`
- [ ] Full path obtained from `Get-ChildItem`
- [ ] Path variable is not empty

## PDF and Office File Reading

### PDF Files

**⚠️ OpenClaw's read tool cannot directly read PDF files - they are binary format**

**Use the PDF extraction script:**
```powershell
# Extract text from PDF file
C:\Users\wengzheng\.openclaw\workspace\skills\nas\read-nas-pdf.ps1 -FilePath "\\nas\homes\weng\履歴書\2025-04-10_職務経歴書.pdf"
```

**The script will:**
1. Connect to NAS
2. Verify PDF file exists
3. Attempt to extract text using available tools:
   - `pdftotext` (if installed via poppler-utils)
   - Word COM object (if Microsoft Word is installed)
   - PDF libraries (if installed)
4. Output extracted text to console for OpenClaw to analyze

**Installing PDF extraction tools:**

**Option 1: Install poppler-utils (pdftotext)**
```powershell
# Using Chocolatey
choco install poppler

# Or download from: https://github.com/oschwartz10612/poppler-windows/releases
```

**Option 2: Install PowerShell PDF module**
```powershell
Install-Module -Name PdfSharp -Scope CurrentUser -Force
```

### Office Files (.docx, .xlsx, .pptx)

**For Word documents (.docx):**
```powershell
# Use Word COM object (requires Microsoft Word)
$word = New-Object -ComObject Word.Application
$word.Visible = $false
$doc = $word.Documents.Open("\\nas\homes\weng\履歴書\履歴書.docx")
$content = $doc.Content.Text
$doc.Close()
$word.Quit()
Write-Host $content
```

**For Excel files (.xlsx):**
```powershell
# Use Excel COM object (requires Microsoft Excel)
$excel = New-Object -ComObject Excel.Application
$excel.Visible = $false
$workbook = $excel.Workbooks.Open("\\nas\homes\weng\file.xlsx")
$worksheet = $workbook.Worksheets.Item(1)
$content = $worksheet.UsedRange.Value2
$workbook.Close()
$excel.Quit()
Write-Host $content
```

## Additional Resources

For detailed troubleshooting and advanced scenarios, see [NAS-ACCESS-GUIDE.md](NAS-ACCESS-GUIDE.md).

**Available scripts (all in `nas` directory):**
- `verify-pdf-access.ps1` - **Verify PDF file access and script setup (RECOMMENDED first step)**
- `read-nas-file-direct.ps1` - Read text files from NAS
- `read-nas-pdf.ps1` - Extract text from PDF files (requires PyPDF2)
- `read-pdf-with-install.ps1` - Extract PDF with auto PyPDF2 installation
- `read-and-analyze-pdf.ps1` - **Read PDF and output for AI analysis (RECOMMENDED for OpenClaw)**
- `extract-pdf-text.py` - Python script for PDF text extraction
- `get-nas-files.ps1` - List files on NAS

**⚠️ IMPORTANT: All scripts are in the `nas` directory!**

**Correct script paths:**
```powershell
# ✅ CORRECT - includes 'nas' directory
C:\Users\wengzheng\.openclaw\workspace\skills\nas\verify-pdf-access.ps1
C:\Users\wengzheng\.openclaw\workspace\skills\nas\read-and-analyze-pdf.ps1
C:\Users\wengzheng\.openclaw\workspace\skills\nas\extract-pdf-text.py
```

**❌ WRONG - missing 'nas' directory:**
```powershell
# ❌ This will fail - file not found
C:\Users\wengzheng\.openclaw\workspace\skills\read-and-analyze-pdf.ps1
```

**Quick verification (check setup before reading):**
```powershell
# Verify PDF file access and script setup
C:\Users\wengzheng\.openclaw\workspace\skills\nas\verify-pdf-access.ps1
```

**For OpenClaw AI Analysis:**

**Option 1: Direct PowerShell (RECOMMENDED - Simple):**
```powershell
# Direct PowerShell command - no scripts needed
chcp 65001 | Out-Null; [Console]::OutputEncoding = [System.Text.Encoding]::UTF8; $OutputEncoding = [System.Text.Encoding]::UTF8; $filePath = "M:\weng\履歴書\2025-04-10_職務経歴書.pdf"; if (Test-Path -LiteralPath $filePath) { python C:\Users\wengzheng\.openclaw\workspace\skills\nas\extract-pdf-text.py $filePath 10 } else { Write-Host "File not found"; Get-ChildItem "M:\weng\履歴書" -Filter "*.pdf" | Select-Object Name }
```

**Option 2: Use analysis script:**
```powershell
# Script handles everything automatically
C:\Users\wengzheng\.openclaw\workspace\skills\nas\read-and-analyze-pdf.ps1 -FilePath "M:\weng\履歴書\2025-04-10_職務経歴書.pdf"
```

**Note**: If using mapped drive `M:\`, you don't need `net use` - the drive is already connected! Just use `M:\` paths directly.

**Quick Start - Read PDF (Easiest Method):**
```powershell
# Use the script that auto-installs PyPDF2 if needed
C:\Users\wengzheng\.openclaw\workspace\skills\nas\read-pdf-with-install.ps1 -FilePath "\\nas\homes\weng\履歴書\2025-04-10_職務経歴書.pdf"
```

This script will:
1. ✅ Set UTF-8 encoding
2. ✅ Connect to NAS
3. ✅ Verify file exists
4. ✅ Check and install PyPDF2 if needed
5. ✅ Extract text from PDF
6. ✅ Output readable text content

## Read PDF and Analyze with OpenClaw

**For AI analysis and understanding, use the analysis script:**

```powershell
# Read PDF and output for AI analysis
C:\Users\wengzheng\.openclaw\workspace\skills\nas\read-and-analyze-pdf.ps1 -FilePath "\\nas\homes\weng\履歴書\2025-04-10_職務経歴書.pdf" -MaxPages 10
```

**Or let it auto-find the latest PDF:**
```powershell
# Automatically finds and reads the latest PDF file
C:\Users\wengzheng\.openclaw\workspace\skills\nas\read-and-analyze-pdf.ps1
```

**This script:**
1. ✅ Connects to NAS automatically
2. ✅ Finds PDF files (or uses provided path)
3. ✅ Installs PyPDF2 if needed
4. ✅ Extracts text from PDF
5. ✅ Outputs formatted text for AI analysis
6. ✅ Provides summary information

**After extraction, the AI can:**
- Analyze the content
- Extract key information (skills, experience, etc.)
- Summarize the document
- Answer questions about the content
- Generate structured output based on understanding

**Example workflow:**
```powershell
# Step 1: Extract PDF text
C:\Users\wengzheng\.openclaw\workspace\skills\nas\read-and-analyze-pdf.ps1 -FilePath "\\nas\homes\weng\履歴書\2025-04-10_職務経歴書.pdf"

# Step 2: AI will analyze the extracted text automatically
# The output from Step 1 will be available for AI to understand and process
```
