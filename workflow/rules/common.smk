from pathlib import Path
import pandas as pd

# read loci list
lb = pd.read_csv(config["lb_file"])

# Create a new column by concatenating
lb["snp"] = lb["SNPID"].str.replace(":", ".") # change colon with underscore in SNP identifers
lb["locus"]  = lb["chr"].astype(str) + "_" + lb["start"].astype(str) + "_" + lb["end"].astype(str)
lb["locuseq"] = lb["seqid"].astype(str) + "_" + lb["locus"].astype(str)+ "_" + lb["snp"].astype(str)

# Use only needed columns
my_lb = (
    pd.DataFrame(lb, columns=["locuseq", "seqid", "locus", "SNPID", "snp"])
    .drop_duplicates()
    .set_index("locuseq", drop=False)
    .sort_index()
)

# return features of each locus
def get_locus(wildcards):
    return str(my_lb.loc[wildcards, "locus"])

def get_snp(wildcards):
    return str(my_lb.loc[wildcards, "SNPID"])

# define the functions generating files' path
def ws_path(file_path):
    return str(Path(config.get("path_out"), file_path))

def get_gwas(wildcards):
    seqid = my_lb.loc[wildcards, "seqid"]
    file_path = f"{seqid}/{seqid}.gwaslab.tsv.bgz"
    return str(Path(config.get("path_gwas"), file_path))

# funtion creating the path toward conditional RDS file
def get_rds(wildcards):
    seqid = my_lb.loc[wildcards, "seqid"]
    locus = my_lb.loc[wildcards, "locus"]
    rds_path = f"cojo/{seqid}/conditional_data_{locus}.rds"
    return str(Path(config.get("path_rds"), rds_path))
