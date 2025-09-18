#!/usr/bin/env python3
import os
import re
import requests
from docling.document_converter import DocumentConverter, PdfFormatOption
from docling.datamodel.base_models import InputFormat
from docling.datamodel.pipeline_options import PdfPipelineOptions


def download_arxiv_pdf(arxiv_id, download_dir="/tmp"):
    pdf_url = f"https://arxiv.org/pdf/{arxiv_id}.pdf"
    headers = {"User-Agent": "Mozilla/5.0"}
    r = requests.get(pdf_url, headers=headers, timeout=30)
    r.raise_for_status()
    pdf_path = os.path.join(download_dir, f"{arxiv_id}.pdf")
    with open(pdf_path, "wb") as f:
        f.write(r.content)
    return pdf_path, len(r.content)


def extract_text_with_docling(pdf_path):
    pipeline_options = PdfPipelineOptions()
    pipeline_options.do_ocr = True
    pipeline_options.do_table_structure = True
    pipeline_options.table_structure_options.do_cell_matching = True

    pdf_format_option = PdfFormatOption(pipeline_options=pipeline_options)
    converter = DocumentConverter(format_options={InputFormat.PDF: pdf_format_option})

    result = converter.convert(pdf_path)
    text = result.document.export_to_text()
    return {"success": True, "text": text}


def get_full_text_from_pdf(pdf_path):
    out = extract_text_with_docling(pdf_path)
    return out["text"] if out.get("success") else ""


def clean_research_text(text):
    s = text.replace("\r\n", "\n").replace("\r", "\n")
    s = re.sub(r"(\w+)-\n(\w+)", r"\1\2\n", s)
    lines = s.splitlines()

    n = len(lines)
    cutoff = int(n * 0.6)
    headings = {"references", "bibliography", "acknowledgments", "acknowledgements", "appendix"}
    cut_idx = None
    for i in range(cutoff, n):
        raw = lines[i].strip()
        t = re.sub(r"^[#\s\-\d\.:\)]+", "", raw).lower()
        if re.match(r"^(references|bibliography)\b", t):
            cut_idx = i
            break
        if re.match(r"^(acknowledgments|acknowledgements|appendix)\b", t):
            cut_idx = i
            break
    if cut_idx is not None:
        lines = lines[:cut_idx]
    else:
        ref_bullet = re.compile(r"^\s*([\-•]\s*\[\d+\]|\[\d+\]|\d+\.|\d+\))\s+")
        for i in range(cutoff, n):
            window = lines[i:i+7]
            hits = sum(1 for ln in window if ref_bullet.match(ln or ""))
            if hits >= 3:
                lines = lines[:i]
                break

    cleaned = []
    for ln in lines:
        t = ln.strip()
        if not t:
            cleaned.append("")
            continue
        if re.fullmatch(r"https?://\S+", t):
            continue
        if re.fullmatch(r"\d+|\d+\s*/\s*\d+|(?i:page)\s*\d+(\s*(?i:of)\s*\d+)?", t):
            continue
        if re.match(r"^(Figure|Fig\.|Table)\s+\d+([:.\s]|$)", t, re.IGNORECASE):
            continue
        t = re.sub(r"\S+@\S+", "", t)
        t = re.sub(r"\s{2,}", " ", t).strip()
        cleaned.append(t)

    s = "\n".join(cleaned)
    s = re.sub(r"\n{3,}", "\n\n", s).strip()
    return s


def main():
    arxiv_id = "1706.03762"
    print("Downloading…", arxiv_id)
    pdf_path, size = download_arxiv_pdf(arxiv_id)
    print("Saved:", pdf_path, f"({round(size/1024/1024,2)} MB)")

    print("Extracting full text…")
    text = get_full_text_from_pdf(pdf_path)
    if text:
        cleaned = clean_research_text(text)
        print("Chars:", len(cleaned))
        print("Words:", f"{len(cleaned.split()):,}")
        print("Preview:\n" + cleaned[:500] + "…")
        with open("extracted_text.txt", "w", encoding="utf-8") as f:
            f.write(cleaned)
        print("Saved full text to: extracted_text.txt")
    else:
        print("Extraction failed")


if __name__ == "__main__":
    main()