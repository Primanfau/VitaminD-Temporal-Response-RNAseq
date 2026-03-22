#!/usr/bin/env Rscript

# Load libraries
library(DESeq2)
library(tidyverse)
library(biomaRt)
library(openxlsx)

# Set paths
counts_file <- "data/processed/counts/RNA_featurecounts.txt"
output_dir <- "results"
if (!dir.exists(output_dir)) dir.create(output_dir, recursive = TRUE)

# Read counts
count_data <- read.table(counts_file, header = TRUE, skip = 1, row.names = 1)
counts <- count_data[, 6:ncol(count_data)]

# Clean column names
colnames(counts) <- gsub("_Aligned.sortedByCoord.out.bam", "", colnames(counts))
colnames(counts) <- gsub(".*/", "", colnames(counts))  # Remove paths

# Metadata
metadata <- data.frame(
  sample = colnames(counts),
  condition = rep(c("125D", "EtOH"), each = 9, times = 3),  # adjust if order differs
  time = rep(rep(c("2.5h", "4h", "24h"), each = 6), times = 1)
)
# Reorder metadata to match counts order (assuming counts columns are in same order as SraRunTable)
metadata$time <- factor(metadata$time, levels = c("2.5h", "4h", "24h"))
metadata$condition <- factor(metadata$condition, levels = c("EtOH", "125D"))
rownames(metadata) <- metadata$sample

# Verify order
all(rownames(metadata) == colnames(counts))  # Should be TRUE

# Analyze each time point
analyze_time_point <- function(tp) {
  idx <- metadata$time == tp
  dds <- DESeqDataSetFromMatrix(
    countData = counts[, idx],
    colData = metadata[idx, ],
    design = ~ condition
  )
  keep <- rowSums(counts(dds)) >= 10
  dds <- dds[keep, ]
  dds <- DESeq(dds)
  res <- results(dds, contrast = c("condition", "125D", "EtOH"), alpha = 0.05)
  as.data.frame(res) %>%
    rownames_to_column("gene_id") %>%
    select(gene_id, log2FoldChange, pvalue, padj) %>%
    rename(
      !!paste0("log2FC_", tp) := log2FoldChange,
      !!paste0("pvalue_", tp) := pvalue,
      !!paste0("padj_", tp) := padj
    )
}

time_points <- c("2.5h", "4h", "24h")
results_list <- lapply(time_points, analyze_time_point)
combined_res <- reduce(results_list, full_join, by = "gene_id")

# Annotation
ensembl <- useMart("ensembl", dataset = "hsapiens_gene_ensembl")
annot <- getBM(
  attributes = c("ensembl_gene_id", "external_gene_name", "gene_biotype", "description"),
  filters = "ensembl_gene_id",
  values = combined_res$gene_id,
  mart = ensembl
) %>%
  rename(gene_id = ensembl_gene_id, gene_name = external_gene_name, gene_description = description)

final_table <- combined_res %>%
  left_join(annot, by = "gene_id")

# Save results
write.xlsx(final_table, file.path(output_dir, "deseq2_results.xlsx"))
write.csv(final_table, file.path(output_dir, "deseq2_results.csv"), row.names = FALSE)

cat("Analysis completed. Results saved in", output_dir, "\n")