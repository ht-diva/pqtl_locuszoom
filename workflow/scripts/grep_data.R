#!/usr/bin/Rscript

suppressMessages(library(data.table))
suppressMessages(library(tidyverse))


# recall inputs from snakemake
path_rds <- snakemake@input[["cond_rds"]]
cojo_snp <- snakemake@params[["cojo_snp"]]
ofile <- snakemake@output[["ofile"]]

#"/scratch/dariush.ghasemi/projects/pqtl_pipeline_finemap/results/meta_correct_sdy/cojo/seq.8528.74/conditional_data_17_7063650_7173279.rds"
#cojo_snp <- "17:7063667:C:T"

# read conditional RDS file
df_rds <- readRDS(path_rds)

# trow number for the input COJO  variant
k <- which(df_rds$ind.snps$SNP == cojo_snp)

# store the right data from a list of conditional datasets
# only pick columns needed as like a METAL input for LZ standalone
df_cond <- df_rds$results[[k]] %>%
  dplyr::select(
    CHROM = Chr,
    POS = bp,
    SNPID = SNP,
    MAF = freq,
    BETA = b,
    SE = se,
    N = n,
    MLOG10P = mlog10pC
  )


# save reformatted conditional data
data.table::fwrite(df_cond, file = ofile, quote = F, row.names = F, sep = "\t")
