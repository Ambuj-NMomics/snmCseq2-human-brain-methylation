# Results

This section summarizes the quantitative outcomes of the single-nucleus
DNA methylation (snmC-seq2) analysis performed on human brain tissue.
All results are interpreted in the context of assay design and coverage
limitations inherent to single-nucleus data.

---

## Global Methylation

- Global cytosine methylation across all sequence contexts (CpG + CH)
  was approximately **0.40**.
- This value is lower than bulk whole-genome bisulfite sequencing
  estimates, which is expected due to sparse coverage in single-nucleus
  assays.

**Interpretation**  
The observed global methylation level reflects single-nucleus sampling
rather than biological hypomethylation.

---

## CpG Methylation

- Genome-wide CpG methylation was high (approximately **0.84**),
  consistent with differentiated human brain tissue.
- After applying a ≥5× coverage threshold, CpG methylation saturated
  at **1.0**.

**Interpretation**  
Only a small number of CpG sites reach high coverage in a single nucleus.
These sites are predominantly fully methylated, leading to saturation.
This is a sampling effect rather than a global biological property.

---

## Non-CpG (CH) Methylation

- Naive aggregation of all CH sites produced inflated methylation values.
- After applying a ≥5× coverage filter, non-CpG methylation converged
  to approximately **2%**.

**Interpretation**  
Low but non-zero CH methylation is a known hallmark of neuronal nuclei.
Coverage-aware filtering removes technical noise and reveals
biologically plausible signal.

---

## Summary

Together, these results demonstrate that:
- The dataset captures authentic neuronal DNA methylation signal.
- Coverage-aware interpretation is essential for meaningful conclusions.
- Single-nucleus methylation profiles differ fundamentally from bulk data.
