Key Findings
Scientific

Validates neuronal non-CpG methylation signature
Demonstrates correct handling of snmC-seq2 data
Highlights differences between bulk and single-nucleus methylation profiles

Technical

Proper tool selection for bisulfite sequencing
Coverage-aware interpretation prevents false conclusions
Avoidance of invalid analyses (variant calling, CNV, naive PCA)

Educational

Builds assay literacy
Shows why naive aggregation fails in single-nucleus data
Demonstrates responsible analysis boundaries

What This Project Demonstrates
This analysis shows how biologically incorrect conclusions can arise from technically "valid" commands. It emphasizes:

Why single-nucleus data requires cautious aggregation
How to separate signal, noise, and bias
When scientific judgment matters more than computational scale

The key contribution is scientific judgment, not scale.
Limitations

Single nucleus only (not aggregated across cells)
No biological replication
No differential methylation analysis
No cell type clustering

These limitations are explicitly respected, not ignored.
What NOT to Do with This Data
❌ Variant calling (bisulfite conversion distorts SNP calls)
❌ CNV analysis (coverage is sparse and biased)
❌ Standard RNA-seq workflows
❌ Naive PCA without accounting for sparsity
Contributing
This is a methodological demonstration project. If you have suggestions for improving the interpretation or workflow, please open an issue.

Citation
If you use this workflow, please cite the original snmC-seq2 method:

Luo, C., et al. (2017). Single-nucleus multi-omics links human cortical cell regulatory genome diversity to disease risk variants. Nature Genetics.

Acknowledgments

Data from NCBI SRA (SRR13898339)
Bismark methylation analysis pipeline
snmC-seq2 methodology developers
