#!/bin/bash

# Snakemake paramters
LD="${snakemake_output[ld]}"
GENOTYPE="${snakemake_params[bfile]}"
LOCUS="${snakemake_params[locus]}"
LEAD="${snakemake_params[lead]}"
TAIL="${snakemake_params[buffer]}"
WINDOW="${snakemake_params[ldwind]}"
R2="${snakemake_params[ldwind_r2]}"
THREADS=8
MEM=16000


# load libraries
source /exchange/healthds/singularity_functions

echo "Input coordinates: $LOCUS "
echo "Reference variant to compute pairwise LD: $LEAD "


# take region bounaries from locus string
chr=$(echo "$LOCUS" | cut -d'_' -f1)
beg=$(echo "$LOCUS" | cut -d'_' -f2)
end=$(echo "$LOCUS" | cut -d'_' -f3)

# remove ".ld" from ofile as plink add it by default
# in this way, SMK can detect ofile to prevent from missing output error
out_ld=$(echo "$LD" | sed 's/.ld$//')

# extend the boundaries by +/-100 kbp
beg_ext=$((beg - "$TAIL"))
end_ext=$((end + "$TAIL"))

plink   \
  --bfile  "$GENOTYPE""$chr"  \
  --keep-allele-order \
  --ld-snp "$LEAD" \
  --chr "$chr" --from-bp "$beg_ext" --to-bp "$end_ext" \
  --r2  \
  --ld-window "$WINDOW"  \
  --ld-window-r2 "$R2"  \
  --out "$out_ld"  \
  --threads "$THREADS"  \
  --memory "$MEM"
