#!/bin/bash

# Snakemake paramters
GWAS="${snakemake_input[gwas]}"
LD="${snakemake_input[ld]}"
SENTINEL="${snakemake_output[sentinel]}"
HEADER="${snakemake_params[header]}"
PREFIX="${snakemake_params[prefix]}"
OUTDIR="${snakemake_params[outdir]}"
STUDY="${snakemake_params[study]}"
SNPLAB="${snakemake_params[snplab]}"
PLAB="${snakemake_params[plab]}"
LOCUS="${snakemake_params[locus]}"
LEAD="${snakemake_params[lead]}"
TAIL="${snakemake_params[tail]}"
BUILD="${snakemake_params[build]}"
MEASURE="${snakemake_params[measure]}"
RECOMB="${snakemake_params[recomb]}"

# load libraries
source /exchange/healthds/singularity_functions

echo "Genomic region: $LOCUS"
       
# index variant need to be formated readable for locuszoom 
target=$(echo "$LEAD" | sed -E 's/([0-9]+:[0-9]+):([A-Z]+):([A-Z]+)/\\1_\\2\/\\3/g')

# take region bounaries from locus string
chr=$(echo "$LOCUS" | cut -d'_' -f1)
beg=$(echo "$LOCUS" | cut -d'_' -f2)
end=$(echo "$LOCUS" | cut -d'_' -f3)

# extend the boundaries by +/- 100 kbp
beg_ext=$((beg - "$TAIL"))
end_ext=$((end + "$TAIL"))

# reformat locus to be readable for locuzoom
region=${{chr}}:${{beg_ext}}-${{end_ext}}

echo "target is: $target"
echo "region is: $region"

# specify which command to use for different study
if [ "$STUDY" = "Believe" ]; then
    CMD="cat $HEADER <(tabix $GWAS $region)"
elif [ "$STUDY" = "Meta_Interval" ]; then
    CMD="tabix $GWAS $region -h"
else
    echo "ERROR: Unknown study $STUDY " >&2 
    exit 1
fi

eval $CMD | \
    sed -E 's/([0-9]+:[0-9]+):([A-Z]+):([A-Z]+)/\\1_\\2\/\\3/g' | \
        locuszoom  \
            --metal - \
            --markercol "$SNPLAB" \
            --pvalcol "$PLAB"  \
            --no-transform \
            --refsnp $target \
            --chr $chr \
            --start $beg_ext \
            --end $end_ext \
            --build "$BUILD" \
            --svg  \
            --ld "$LD" \
            --ld-measure "$MEASURE" \
            --plotonly  \
            showRecomb="$RECOMB" \
            --prefix "$PREFIX"
    
# moving plots to the output directory
mkdir -p "$OUTDIR"
mv "$PREFIX"* "$OUTDIR"

touch "$SENTINEL"
