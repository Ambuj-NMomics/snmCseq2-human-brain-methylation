#!/usr/bin/env bash
set -euo pipefail

# Raw read quality control for snmC-seq2 data

fastqc SRR13898339_1.fastq.gz SRR13898339_2.fastq.gz
multiqc .
