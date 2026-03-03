#!/usr/bin/Rscript

suppressMessages(library(data.table))
suppressMessages(library(tidyverse))


# recall inputs from snakemake
path_rds <- snakemake@input[["cond_rds"]]
cojo_snp <- snakemake@params[["cojo_snp"]]
myregion <- snakemake@params[["region"]]
ofile <- snakemake@output[["ofile"]]


# read conditional RDS file
df_rds <- readRDS(path_rds)

# trow number for the input COJO  variant
k <- which(df_rds$ind.snps$SNP == cojo_snp)

# extract region boundaries
my_beg <- str_split_fixed(myregion, "_", 3)[2] %>% as.integer()
my_end <- str_split_fixed(myregion, "_", 3)[3] %>% as.integer()

# store the right data from a list of conditional datasets
# only pick columns needed as like a METAL input for LZ standalone
df_cond <- df_rds$results[[k]] %>%
  dplyr::select(
    `##CHR` = Chr,
    POS = bp,
    SNPID = SNP,
    MAF = freq,
    BETA = b,
    SE = se,
    N = n,
    MLOG10P = mlog10pC
  ) %>%
  arrange(POS) %>%
  dplyr::filter(between(POS, my_beg, my_end))


# save reformatted conditional data
data.table::fwrite(df_cond, file = ofile, quote = F, row.names = F, sep = "\t")
