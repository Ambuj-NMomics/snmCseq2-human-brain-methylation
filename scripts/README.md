# Scripts

This directory contains modular shell scripts corresponding to each
stage of the snmC-seq2 analysis workflow.

## Script order

1. `01_qc.sh` — Raw read quality control
2. `02_trim.sh` — Adapter trimming
3. `03_align.sh` — Bisulfite-aware alignment
4. `04_extract.sh` — Methylation extraction
5. `05_summarize.sh` — Methylation summaries

Scripts are intentionally simple and mirror the commands documented in
`COMMANDS.md`. Output files are not tracked in the repository.
