#!/usr/bin/env bash
set -euo pipefail

# Adapter trimming for bisulfite sequencing reads

fastp \
  -i SRR13898339_1.fastq.gz \
  -I SRR13898339_2.fastq.gz \
  -o trimmed_1.fastq.gz \
  -O trimmed_2.fastq.gz \
  --length_required 30 \
  --detect_adapter_for_pe \
  --html fastp.html \
  --json fastp.json
