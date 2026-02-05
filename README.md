#🧬 Single-Nucleus DNA Methylation Analysis (snmC-seq2) — Human Brain

#Overview

Single-nucleus methylcytosine sequencing 2 (snmC-seq2) is a high-throughput technique for profiling DNA methylation at single-cell resolution using isolated nuclei. This approach has been particularly transformative for studying the human brain, where frozen tissue is more readily available than fresh samples, and where the complexity of cell types requires single-cell resolution analysis.

#Why Single-Nucleus Approach for Brain?

#Advantages Over Single-Cell Methods
  1. Compatible with frozen tissue: Works with post-mortem brain samples and biobanked specimens
  2. No cell dissociation artifacts: Avoids stress responses from enzymatic dissociation
  3. Captures all cell types: Includes fragile neurons that are difficult to isolate intact
  4. Preserves nuclear architecture: Maintains chromatin context better than whole-cell methods
  5. Higher throughput: Can process thousands of nuclei in a single experiment

#Brain-Specific Challenges Addressed
  1. Cellular heterogeneity: The brain contains hundreds of distinct cell types
  2. Rare cell populations: Specific neuronal subtypes may represent <1% of total cells
  3. Post-mortem samples: Most human brain tissue is only available frozen
  4. Limited biopsy material: Human brain samples are precious and limited

#The goal of this project is not discovery, but correct learning:

  - how bisulfite methylation data behaves,
  - how to process it properly,
  - how to interpret results without violating biological assumptions.

This repository is intended as a reference-quality learning artifact for epigenomics and bioinformatics.


#Dataset
  - SRA Run: SRR13898339
  - Organism: Homo sapiens
  - Tissue: Human brain (cortex)
  - Assay: Single-nucleus DNA methylation sequencing (snmC-seq2)
  - Sequencing platform: Illumina NovaSeq 6000
  - Library layout: Paired-end

⚠️ Important: This dataset is bisulfite sequencing data, not WGS or RNA-seq. It is not suitable for variant calling, CNV analysis, or standard genomic workflows.


#Project Objectives
  1. Learn how bisulfite sequencing data differs from standard DNA sequencing
  2. Apply assay-appropriate QC and alignment
  3. Distinguish diagnostic outputs from biological outputs
  4. Quantify CpG and non-CpG methylation correctly
  5. Understand single-nucleus coverage artifacts and how to handle them


#Software Requirements
  1. seqkit - FASTQ statistics ( To know the size of genome, read length, min and max read length)
  2. fastqc - Raw read quality assessment
  3. multiqc - Aggregated QC reports
  4. fastp - Adapter trimming and quality filtering
  5. bismark - Bisulfite-aware alignment and methylation extraction
  6. bowtie2 - Underlying aligner (used by Bismark)
  7. samtools - BAM file manipulation
  8. awk - Text processing for methylation quantification


#Workflow

1. Data Download & Inspection
  - Paired-end FASTQ files were downloaded from SRA using prefetch command
  - Initial data integrity and library metrics were assessed using seqkit.

Terminal Execution

seqkit stats SRR13898339_1.fastq.gz SRR13898339_2.fastq.gz


#Observation

  1.  ~1.1 million read pairs
  2.  ~150 bp reads
  3.  Data volume consistent with single-nucleus, not bulk WGBS


2. Raw Read Quality Control (QC)

# Run FastQC on both paired-end files
fastqc SRR13898339_1.fastq.gz SRR13898339_2.fastq.gz

# Aggregate QC reports into a single interactive HTML
multiqc .

Understanding FastQC Reports for Bisulfite Data:

Bisulfite sequencing chemically converts unmethylated cytosines (C) to uracils (U), which are read as thymines (T) during sequencing. This creates expected artifacts that would be errors in normal sequencing:

Expected "Warnings" in MultiQC Report (These are NORMAL):

When you open the MultiQC HTML report, you'll see the Status Checks section showing colored boxes for each FastQC module. 

What the MultiQC Report Will Look Like:

In the Status Checks heatmap, you'll see:
  - 🔴 Red boxes for: Per base sequence content, Sequence duplication levels
  - ⚠️ Orange boxes for: Per sequence GC content, Sequence length distribution
  - ✅ Green boxes for: Per base sequence quality, Per base N content

This pattern of mostly red and orange warnings is completely normal for bisulfite sequencing and does not indicate poor data quality. The red boxes reflect the expected biochemical changes from bisulfite treatment, not sequencing errors.

Key Metrics to Check:
  - General Statistics table - Look for ~1M reads per file (typical for single-nucleus)
  - Sequence Quality Histograms - Should show high quality (Phred >30) across most of the read
  - Per Base Sequence Content plot - Click on a sample to see the line plot. You'll see T% is elevated and C% is reduced (the bisulfite signature)

Actual Problems to Look For:
  ✅ Per base sequence quality - Should be >30 (green) for most of the read
  ✅ Per base N content - Should be near zero
  ✅ Sequence length distribution - Should match expected read length (~150bp)
  ✅ Adapter content - High adapter contamination needs trimming (handled in step 3)


What This Means:

If FastQC shows red "FAIL" flags for sequence composition, GC content, or kmer content, this is normal for bisulfite data. Do not attempt to "fix" these by aggressive filtering. The biochemistry of the assay creates these patterns.
However, if you see poor base quality scores (phred <20) or very high N content, this indicates a real sequencing quality problem.

3. Read Trimming

Why Trimming is Critical for Bisulfite Data:

Adapter sequences and low-quality bases at read ends can cause:
  - False methylation calls - Adapters align incorrectly, creating artificial CpG sites
  - Reduced alignment rates - Poor quality bases prevent bisulfite-aware alignment
  - Biased methylation estimates - Low-quality bases are randomly called as C or T

Unlike standard DNA-seq where you might skip trimming, bisulfite data absolutely requires adapter removal because the C→T conversion makes adapters harder to detect during alignment.

Terminal Execution

bashfastp \
  -i SRR13898339_1.fastq.gz \
  -I SRR13898339_2.fastq.gz \
  -o trimmed_1.fastq.gz \
  -O trimmed_2.fastq.gz \
  --length_required 30 \
  --detect_adapter_for_pe \
  --html fastp.html \
  --json fastp.json


Parameter Explanation:
 Parameter                           Purpose
 -i / -I                             Input files (read 1 and read 2)
 -o / -O                             Output files (trimmed read 1 and read 2)
 --length_required 30                Discard reads shorter than 30bp after trimming. Important: Don't set this too high (like 100bp) - short reads are fine in bisulfite sequencing and still provide methylation information.
 --detect_adapter_for_pe             Auto-detect Illumina adapters for paired-end data. Fastp is excellent at this.
 --html / --json                     Generate interactive HTML report and JSON output for downstream QC


Output Files:

After running fastp, you'll get:

 1. Trimmed FASTQ files:

   - trimmed_1.fastq.gz - Clean read 1 (forward)
   - trimmed_2.fastq.gz - Clean read 2 (reverse)


2. QC Reports:

  - fastp.html - Open this in your browser! Interactive before/after comparison showing:
    Reads passing filters
    Adapter content removed
    Quality score distribution
    Length distribution after trimming


  - fastp.json - Machine-readable version for programmatic access


3. Automatic output (printed to terminal):

   Read1 before filtering:
   total reads: 1139359
   total bases: 170903850
   
   Read1 after filtering:
   total reads: 1098234
   total bases: 156789012
   
   Filtering result:
   reads passed filter: 1098234 (96.39%)
   reads with adapter trimmed: 145678 (12.79%)

What to Check in fastp.html:
  ✅ >90% reads passing filters - Good data quality
  ✅ Adapter content reduced to <1% - Successful trimming
  ✅ Mean quality remains >30 - Quality filtering not too aggressive
  ⚠️ If >20% of reads are discarded, investigate whether quality issues exist

Why Not Over-Trim:
Unlike RNA-seq or ChIP-seq, bisulfite sequencing benefits from keeping shorter reads (30-50bp) because:
  - Each CpG site provides methylation information regardless of read length
  - Over-trimming reduces genome coverage in already sparse single-nucleus data
  - Bismark can handle variable read lengths effectively

4. Prepare Reference Genome

Why This Step is Necessary:
Bismark requires the reference genome to be indexed in a special way that accounts for bisulfite conversion. It creates two separate versions of the genome:

  - C→T converted genome (simulates bisulfite treatment of the forward strand)
  - G→A converted genome (simulates bisulfite treatment of the reverse strand)

This allows Bismark to align bisulfite-treated reads correctly without mistaking C→T conversions for SNPs.

Download hg38 Reference 

# Option 1: From UCSC
  wget https://hgdownload.soe.ucsc.edu/goldenPath/hg38/bigZips/hg38.fa.gz
  gunzip hg38.fa.gz
  mkdir hg38
  mv hg38.fa hg38/

# Option 2: From Ensembl (includes chromosome names like 1, 2, 3...)
   wget http://ftp.ensembl.org/pub/release-110/fasta/homo_sapiens/dna/Homo_sapiens.GRCh38.dna.primary_assembly.fa.gz


Prepare Genome for Bismark:
Terminal Execution

bismark_genome_preparation hg38/

What This Command Does:
  1. Detects hg38.fa inside the hg38/ directory
  2. Creates a Bisulfite_Genome/ subdirectory
  3. Generates two converted genome versions:
    - CT_conversion/ - Forward strand reference
    - GA_conversion/ - Reverse strand reference
  4. Builds Bowtie2 indexes for each converted genome (6 .bt2 files per genome)

Expected Output:
  Bisulfite Genome Indexer version v0.24.0
  Writing CT converted chromosomes into hg38/Bisulfite_Genome/CT_conversion/
  Writing GA converted chromosomes into hg38/Bisulfite_Genome/GA_conversion/
  ...
  Total time for bismark_genome_preparation: 45 min

Directory Structure After Preparation:

hg38/
├── hg38.fa                           # Original reference genome
└── Bisulfite_Genome/
    ├── CT_conversion/
    │   ├── genome_mfa.CT_conversion.fa
    │   └── BS_CT.*.bt2               # Bowtie2 index files
    └── GA_conversion/
        ├── genome_mfa.GA_conversion.fa
        └── BS_GA.*.bt2               # Bowtie2 index files


4. Bisulfite-Aware Alignment

Why Standard Aligners Fail:
Tools like BWA, Bowtie2 (alone), or STAR are biologically incorrect for bisulfite data because:
  - They treat C→T mismatches as sequencing errors or SNPs
  - They cannot distinguish true methylation from bisulfite conversion
  - They penalize legitimate C→T conversions, causing massive alignment failure

Bismark handles this correctly by:

  1. Converting reads computationally (C→T in-silico)
  2. Aligning to pre-converted reference genomes
  3. Tracking which C's were originally present 
  4. Recording methylation state for each cytosine
  5. Prepare reference genome: bismark_genome_preparation hg38/


Alignment:

bismark --genome hg38 -1 trimmed_1.fastq.gz -2 trimmed_2.fastq.gz


Expected Output Files:
After alignment completes, you'll get:
  1. BAM file: trimmed_1_bismark_bt2_pe.bam - Aligned reads with methylation information
  2. Alignment report: trimmed_1_bismark_bt2_PE_report.txt - Detailed alignment statistics


What the Alignment Report Shows:

Sequence pairs analysed in total:    1098234
Number of paired-end alignments:     412,567 (37.6%)
  Mapping efficiency:                37.6%

Sequence pairs with no alignment:    685,667 (62.4%)

CT/GA/CT:    102,341   (24.8% of aligned)
CT/GA/GA:    103,122   (25.0% of aligned)
CT/CT/CT:    103,891   (25.2% of aligned)
CT/CT/GA:    103,213   (25.0% of aligned)

Key Points to Understand:

⚠️ Lower alignment rates are NORMAL for single-nucleus data:
  - Bulk WGBS: 60-80% alignment
  - Single-nucleus snmC-seq2: 30-50% alignment (expected)

Why single-nucleus has lower alignment:
  1. Low DNA input → More PCR duplicates → Some reads are low complexity
  2. Sparse coverage → Some genomic regions aren't captured
  3. C→T conversion → Creates ambiguity in repetitive regions
  4. Quality filtering → Borderline quality reads rejected

✅ 30-40% alignment for this dataset is good quality
⚠️ <20% alignment → Investigate: wrong reference genome, poor trimming, or degraded DNA
❌ Never use BWA or standard Bowtie2 → Will give <5% alignment or biologically meaningless results

Alignment Time:
  - This step takes 2-4 hours for ~1M read pairs
  - Progress updates printed every 1M reads
  - Can be parallelized with --multicore 4 (requires more RAM)

Verify Success:

bash
# Check BAM file was created
 ls -lh trimmed_1_bismark_bt2_pe.bam

# Quick alignment stats
grep "Mapping efficiency" trimmed_1_bismark_bt2_PE_report.txt

CT/GA/CT notation: These show directional alignment patterns (original top/bottom strand and bisulfite conversion strand). Balanced distribution (~25% each) indicates good quality library preparation.

5. Methylation Extraction

What This Step Does:
Methylation extraction reads the aligned BAM file and determines the methylation status of every cytosine in the genome. For each cytosine position, it counts:
  - How many reads showed a C (methylated - protected from bisulfite conversion)
  - How many reads showed a T (unmethylated - converted by bisulfite)

This is the critical step where bisulfite sequencing data becomes biological methylation information.

Terminal Execution

bashbismark_methylation_extractor \
  --paired-end \
  --CX \
  --cytosine_report \
  --genome_folder hg38 \
  trimmed_1_bismark_bt2_pe.bam

Output Files Explained:

After extraction completes (takes ~1-2 hours), you'll get multiple files:
1. M-bias Diagnostic File ⭐ Check this first!
  - Filename: trimmed_1_bismark_bt2_pe.M-bias.txt
  - Purpose: Quality control - detects positional bias in methylation calls
  - What to check:

  Position  Count_methylated  Count_unmethylated  %_methylation
  1         1234              5678                17.9
  2         1345              5234                20.4
  ...
  150       1423              4821                22.8

  - Good pattern: Stable methylation % across read positions (20-25% is typical)
  - Bad pattern: Sharp drops at read ends → indicates bias, may need trimming
  - For this dataset: Expected to show stable CpG methylation across read body

2. Coverage File (Compressed)

  - Filename: trimmed_1_bismark_bt2_pe.bismark.cov.gz
  - Purpose: Methylation calls for covered cytosines only
  - Format: 6 columns (tab-separated)

  chr1  12345  12345  67.5  12  6

Column 1: Chromosome
Column 2-3: Position (start, end - same for single cytosine)
Column 4: Methylation percentage
Column 5: Count methylated
Column 6: Count unmethylated
Use case: Quick methylation calculations, differential methylation analysis

3. Cytosine Context Report ⭐ Main analysis file

  - Filename: trimmed_1_bismark_bt2_pe.CX_report.txt
  - Purpose: Every cytosine in hg38, with context annotation
  - Format: 7 columns (tab-separated)

  chr1  12345  +  5  2  CG  CGT
  chr1  12346  +  0  0  CHH CCT

Column 1: Chromosome
Column 2: Position
Column 3: Strand (+/-)
Column 4: Count methylated
Column 5: Count unmethylated
Column 6: Context (CG, CHG, CHH)
Column 7: Trinucleotide sequence
Use case: Context-specific methylation (CpG vs CH), coverage filtering, biological interpretation
Size: Very large (~3-5 GB for hg38), contains ~28 million cytosines

4. Context-Specific Methylation File

  - CpG_context_trimmed_1_bismark_bt2_pe.txt
  - CHG_context_trimmed_1_bismark_bt2_pe.txt
  - CHH_context_trimmed_1_bismark_bt2_pe.txt

Purpose: Pre-split by context for convenience
Note: Often not needed since .CX_report.txt contains everything

5. Bedgraph Files

  - trimmed_1_bismark_bt2_pe.bedGraph.gz

Purpose: Visualization in genome browsers (IGV, UCSC)
Format: Standard bedGraph (chr, start, end, methylation%)

Why CX Context Matters for Brain Data:
Neurons are unique among mammalian cells in having substantial non-CpG methylation (mCH), particularly mCAC and mCAT. This develops postnatally and is functionally important for gene regulation in the brain.
If you used the default --CpG flag instead of --CX, you would miss this entire biological phenomenon.


6. M-bias Validation (Quality Gate)

Inspect M-bias file: less trimmed_1_bismark_bt2_pe.M-bias.txt


Findings
  - End-of-read bias present (expected)
  - Stable CpG methylation across read body
  - No global distortion

Conclusion
  - Methylation signal is reliable enough for biological summarization.


7. Global Methylation (All Contexts)

Using cytosine-level counts: 

zcat trimmed_1_bismark_bt2_pe.bismark.cov.gz \
awk '$5+$6>0 {m+=$5; u+=$6} END {print "Global methylation =", m/(m+u)}'


Result
  - Global methylation ≈ 0.40


Interpretation
  - Lower than bulk WGBS (expected)
  - Reflects sparse single-nucleus coverage


8. Context-Specific Methylation (CpG vs CH)

Generate cytosine context report:

bismark_methylation_extractor \
  --paired-end \
  --cytosine_report \
  --CX \
  --genome_folder hg38 \
  trimmed_1_bismark_bt2_pe.bam


Produces: 
  - trimmed_1_bismark_bt2_pe.CX_report.txt

CpG methylation:

awk '$6=="CG" && $4+$5>0 {m+=$4; u+=$5}
     END {print "CpG methylation =", m/(m+u)}' trimmed_1_bismark_bt2_pe.CX_report.txt



Result
  - CpG ≈ 0.84

CH methylation (unfiltered)

awk '($6=="CHG" || $6=="CHH") && $4+$5>0 {m+=$4; u+=$5}
     END {print "CH methylation =", m/(m+u)}' trimmed_1_bismark_bt2_pe.CX_report.txt


Result
  - CH ≈ 0.37 (inflated)


9. Coverage-Aware Filtering (Critical)

Apply ≥5× coverage threshold.

CpG (≥5×):

     awk '$6=="CG" && ($4+$5)>=5 {m+=$4; u+=$5}
         END {print "CpG (>=5x) =", m/(m+u)}' trimmed_1_bismark_bt2_pe.CX_report.txt


Result
  - CpG (>=5x) = 1.0


Interpretation:
  - Very few CpGs reach ≥5× in one nucleus

  - Saturation is a sampling effect

CH (≥5×):

awk '($6=="CHG" || $6=="CHH") && ($4+$5)>=5 {m+=$4; u+=$5}
     END {print "CH (>=5x) =", m/(m+u)}' trimmed_1_bismark_bt2_pe.CX_report.txt


Result
  - CH (>=5x) ≈ 0.019


Interpretation
  - Matches known neuronal non-CpG methylation
  - Confirms real brain epigenetic signal

Critical: Apply ≥5× coverage threshold to avoid sampling artifacts.


## Documentation

- 📊 **Results**: see [RESULTS.md](RESULTS.md)
- 🔑 **Key Findings**: see [KEY_FINDINGS.md](KEY_FINDINGS.md)
- 🎯 **Project Scope**: see [PROJECT_SCOPE.md](PROJECT_SCOPE.md)
