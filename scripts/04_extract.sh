#!/usr/bin/env bash
set -euo pipefail

# Methylation extraction and M-bias diagnostics

bismark_methylation_extractor \
  --paired-end \
  --CX \
  trimmed_1_bismark_bt2_pe.bam
