from pathlib import Path
import pandas as pd

# read loci list
lb = pd.read_csv(config["lb_file"])

# Create a new column by concatenating 
lb["locus"]  = lb["chr"].astype(str) + "_" + lb["start"].astype(str) + "_" + lb["end"].astype(str)
lb["locuseq"] = lb["phenotype_id"].astype(str) + "_" + lb["locus"].astype(str)

my_lb = (
    pd.DataFrame(lb, columns=["locuseq", "phenotype_id", "locus", "SNPID"])
    #.drop_duplicates(subset='top_cond_ab')
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
    seqid = my_lb.loc[wildcards, "phenotype_id"]
    file_path = f"{seqid}/{seqid}.gwaslab.tsv.bgz"
    return str(Path(config.get("path_gwas"), file_path))
