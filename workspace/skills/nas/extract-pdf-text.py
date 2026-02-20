#!/usr/bin/env python
# -*- coding: utf-8 -*-
"""
Extract text from PDF file on NAS
从 NAS 上的 PDF 文件提取文本
"""

import sys
import os

try:
    import PyPDF2
except ImportError:
    print("Error: PyPDF2 not installed.", file=sys.stderr)
    print("Install with: pip install PyPDF2", file=sys.stderr)
    print("Or run: python -m pip install PyPDF2", file=sys.stderr)
    sys.exit(1)

def extract_pdf_text(file_path, max_pages=10):
    """
    Extract text from PDF file
    
    Args:
        file_path: Path to PDF file
        max_pages: Maximum number of pages to extract (default: 10)
    
    Returns:
        Extracted text as string
    """
    try:
        with open(file_path, 'rb') as f:
            reader = PyPDF2.PdfReader(f)
            num_pages = len(reader.pages)
            pages_to_extract = min(max_pages, num_pages)
            
            text = ""
            for i in range(pages_to_extract):
                page = reader.pages[i]
                page_text = page.extract_text()
                if page_text:
                    text += f"\n--- Page {i+1} ---\n"
                    text += page_text + "\n"
            
            return text, num_pages
    except FileNotFoundError:
        return None, 0
    except Exception as e:
        return f"Error: {str(e)}", 0

if __name__ == "__main__":
    if len(sys.argv) < 2:
        print("Usage: python extract-pdf-text.py <pdf_file_path> [max_pages]", file=sys.stderr)
        sys.exit(1)
    
    file_path = sys.argv[1]
    max_pages = int(sys.argv[2]) if len(sys.argv) > 2 else 10
    
    # Verify file exists
    if not os.path.exists(file_path):
        print(f"Error: File not found: {file_path}", file=sys.stderr)
        sys.exit(1)
    
    # Extract text
    text, total_pages = extract_pdf_text(file_path, max_pages)
    
    if text is None:
        print(f"Error: Could not read file: {file_path}", file=sys.stderr)
        sys.exit(1)
    
    if isinstance(text, str) and text.startswith("Error:"):
        print(text, file=sys.stderr)
        sys.exit(1)
    
    # Output text
    print(f"=== PDF Text Extraction ===")
    print(f"File: {file_path}")
    print(f"Total pages: {total_pages}")
    print(f"Extracted pages: {min(max_pages, total_pages)}")
    print(f"\n=== Content ===\n")
    print(text)
