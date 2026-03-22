# VitaminD-Temporal-Response-RNAseq
Complete RNA-seq analysis pipeline for 1,25-Dihydroxyvitamin D3 treatment in THP-1 cells (GSE69303). Includes data download, QC, STAR alignment, featureCounts, and DESeq2 analysis across three timepoints (2.5h, 4h, 24h).

## Project Description
This repository contains the analysis pipeline for bulk RNA-seq data from the THP-1 cell line treated with active compound 1,25-dihydroxyvitamin D3 (1,25D) or vehicle (EtOH) at three time points (2.5h, 4h, 24h). The data was obtained from GEO accession [GSE69303](https://www.ncbi.nlm.nih.gov/geo/query/acc.cgi?acc=GSE69303).

## Data Source
- **GEO**: GSE69303
- **SRA Run Table**

## Analysis Workflow
1. **Download raw data** using `sradownloader` (SRA Toolkit wrapper) with the SRA Run Table.
2. **Quality control** with FastQC and MultiQC.
3. **Alignment** to the human genome (GRCh38) using STAR.
4. **Quantification** with featureCounts using GENCODE v47 annotation.
5. **Differential expression** analysis with DESeq2 in R, stratified by time point.
6. **Gene annotation** with biomaRt.

## Dependencies
### Software & Tools
- [sradownloader](https://github.com/saketkc/sradownloader) or SRA Toolkit
- FastQC v0.11.9+
- MultiQC v1.11+
- STAR v2.7.10+
- featureCounts (from subread package) v2.0.3+
- R v4.2+ with packages: DESeq2, tidyverse, biomaRt, openxlsx
