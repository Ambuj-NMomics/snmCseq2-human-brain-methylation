#!/usr/bin/env bash
set -euo pipefail

# Bisulfite-aware alignment using Bismark

bismark \
  --genome hg38 \
  -1 trimmed_1.fastq.gz \
  -2 trimmed_2.fastq.gz
