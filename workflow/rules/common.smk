from pathlib import Path
import pandas as pd

lb = pd.read_csv(config["lb_file"])
lb["locus"] = lb["chr"].astype(str) + "_" + lb["start"].astype(str) + "_" + lb["end"].astype(str)
lb["target"] = lb["locus"].astype(str) + "_" + lb["SNPID"].astype(str) + "_" + lb["locus"].astype(str)
lb = lb.set_index("phenotype_id", drop=False)
lb = lb.sort_index()


def get_locus(wildcards):
    chr_val = lb.loc[wildcards.seqid, "chr"]
    beg_val = lb.loc[wildcards.seqid, "start"]
    end_val = lb.loc[wildcards.seqid, "end"] 
    snp_val = lb.loc[wildcards.seqid, "SNPID"]
    loc_val = lb.loc[wildcards.seqid, "locus"] #str()
    tar_val = lb.loc[wildcards.seqid, "target"]
    return f"{tar_val}"
    #return f"{chr_val}_{beg_val}_{end_val}_{snp_val}_{loc_val}"
    
    # rows = lb.loc[wildcards.seqid]

    # # Create a list of row data strings
    # row_data_list = []
    
    # if isinstance(rows, pd.Series):
    #     # Single row
    #     #row_data = f"{str(rows[0])},{str(rows[1])},{str(rows[2])}"
    #     row_data = f"{rows[0]}_{rows[1]}_{rows[2]}"
    #     row_data_list.append(row_data)
    # else:
    #     # Multiple rows
    #     for _, row in rows.iterrows():
    #         #row_data = f"{str(row[0])},{str(row[1])},{str(row[2])}"
    #         row_data = f"{rows[0]}_{rows[1]}_{rows[2]}"
    #         row_data_list.append(row_data)
    
    # # Join the row data strings into a single comma-separated string
    # row_data_str = ','.join(row_data_list)
    # return row_data_str
    
# define the functions generating files' path
def ws_path(file_path):
    return str(Path(config.get("path_out"), file_path))

def gwas_path(file_path):
    return str(Path(config.get("gwas_file"), file_path))
