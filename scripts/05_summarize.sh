#!/usr/bin/env bash
set -euo pipefail

# Global methylation
zcat trimmed_1_bismark_bt2_pe.bismark.cov.gz \
| awk '$5+$6>0 {m+=$5; u+=$6} END {print "Global methylation =", m/(m+u)}'

# CpG methylation
awk '$6=="CG" && $4+$5>0 {m+=$4; u+=$5}
     END {print "CpG methylation =", m/(m+u)}' \
trimmed_1_bismark_bt2_pe.CX_report.txt

# CH methylation (>=5x coverage)
awk '($6=="CHG" || $6=="CHH") && ($4+$5)>=5 {m+=$4; u+=$5}
     END {print "CH methylation (>=5x) =", m/(m+u)}' \
trimmed_1_bismark_bt2_pe.CX_report.txt
