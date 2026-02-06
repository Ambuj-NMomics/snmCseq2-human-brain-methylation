# Tools and Software Used

This document lists all tools used in the analysis, along with their
purpose in the snmC-seq2 single-nucleus DNA methylation workflow.

---

## Operating System
- Linux (Ubuntu)

---

## Core Bioinformatics Tools

### FastQC
- Purpose: Raw read quality control
- Used for: Identifying sequencing quality issues and bisulfite-induced bias
- Notes: FastQC warnings were interpreted in an assay-aware manner

### MultiQC
- Purpose: Aggregated QC reporting
- Used for: Summarizing FastQC outputs

### fastp
- Purpose: Read trimming and adapter removal
- Used for: Conservative trimming of bisulfite sequencing reads
- Output: Trimmed FASTQ files and QC reports

### Bismark
- Purpose: Bisulfite-aware alignment and methylation extraction
- Used for:
  - Alignment to hg38
  - Cytosine-level methylation calling
  - M-bias diagnostics
  - Context-specific methylation reports

### Bowtie2
- Purpose: Alignment backend for Bismark
- Used implicitly via Bismark

### samtools
- Purpose: BAM file handling
- Used for: Indexing and inspection of alignment files

---

## Supporting Tools

### seqkit
- Purpose: FASTQ inspection
- Used for: Verifying read counts and lengths

### awk
- Purpose: Lightweight data summarization
- Used for:
  - Global methylation calculation
  - Context-specific methylation summaries
  - Coverage-aware filtering

---

## Reference Data

- Human reference genome: hg38
- Reference prepared using `bismark_genome_preparation`

---

## Notes on Tool Choice

- Standard DNA aligners and variant callers were intentionally avoided,
  as they are biologically inappropriate for bisulfite sequencing data.
- Tool selection prioritized assay awareness over computational speed.
