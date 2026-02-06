# Command Line Workflow

This document lists the exact command-line steps used in this project,
in execution order. Commands are provided for reproducibility and
learning purposes.

---

## 1. Initial FASTQ Inspection

```bash
seqkit stats SRR13898339_1.fastq.gz SRR13898339_2.fastq.gz

## 2. Raw Read Quality Control

fastqc SRR13898339_1.fastq.gz SRR13898339_2.fastq.gz
multiqc .

## 3. Read Trimming
fastp \
  -i SRR13898339_1.fastq.gz \
  -I SRR13898339_2.fastq.gz \
  -o trimmed_1.fastq.gz \
  -O trimmed_2.fastq.gz \
  --length_required 30 \
  --detect_adapter_for_pe \
  --html fastp.html \
  --json fastp.json

## 4. Reference Genome Preparation
bismark_genome_preparation hg38/

## 5. Bisulfite-Aware Alignment
bismark \
  --genome hg38 \
  -1 trimmed_1.fastq.gz \
  -2 trimmed_2.fastq.gz

## 6. Methylation Extraction
bismark_methylation_extractor \
  --paired-end \
  --CX \
  trimmed_1_bismark_bt2_pe.bam

## 7. M-bias Inspection
less trimmed_1_bismark_bt2_pe.M-bias.txt

## 8. Global Methylation Calculation
zcat trimmed_1_bismark_bt2_pe.bismark.cov.gz \
| awk '$5+$6>0 {m+=$5; u+=$6} END {print m/(m+u)}'

## 9. Context-Specific Cytosine Report
bismark_methylation_extractor \
  --paired-end \
  --cytosine_report \
  --CX \
  --genome_folder hg38 \
  trimmed_1_bismark_bt2_pe.bam

## 10. CpG Methylation
awk '$6=="CG" && $4+$5>0 {m+=$4; u+=$5}
     END {print m/(m+u)}' \
trimmed_1_bismark_bt2_pe.CX_report.txt

## 11. Non-CpG (CH) Methylation
awk '($6=="CHG" || $6=="CHH") && $4+$5>0 {m+=$4; u+=$5}
     END {print m/(m+u)}' \
trimmed_1_bismark_bt2_pe.CX_report.txt

## 12. Coverage-Aware Filtering (≥5×)
CpG
awk '$6=="CG" && ($4+$5)>=5 {m+=$4; u+=$5}
     END {print m/(m+u)}' \
trimmed_1_bismark_bt2_pe.CX_report.txt

CH
awk '($6=="CHG" || $6=="CHH") && ($4+$5)>=5 {m+=$4; u+=$5}
     END {print m/(m+u)}' \
trimmed_1_bismark_bt2_pe.CX_report.txt


## Notes

Commands are shown exactly as executed.

- Output files are not committed to the repository.

- Coverage thresholds were chosen to illustrate single-nucleus artifacts.
