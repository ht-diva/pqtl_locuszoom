#!/bin/bash

source /exchange/healthds/singularity_functions

#seq=seq.12603.87
#seq=seq.17396.23
#seq=seq.25233.2

chr=$1
beg=$2
end=$3
snp=$4
seq=$5

# gwas
gwas_file=/exchange/healthds/pQTL/results/META_CHRIS_INTERVAL/qced_sumstats_digits_not_flipped_filtered/output/${seq}/${seq}.gwaslab.tsv.bgz
genotype="/scratch/giulia.pontali/genomics_QC_pipeline/results_scratch/bed/qc_recoded_harmonised/impute_recoded_selected_sample_filter_hq_var_new_id_alleles_"
# take locus breaker results
locus_file=/scratch/dariush.ghasemi/projects/pqtl_pipeline_finemap/results/meta_filtered/break/${seq}_loci.csv

#seqid=$(basename $gwas_file | cut -d. -f1-3)
#chr=$(tail -n+3 $locus_file | head -1 | cut -d, -f1)
#beg=$(tail -n+3 $locus_file | head -1 | cut -d, -f2)
#end=$(tail -n+4 $locus_file | head -1 | cut -d, -f3)
#pos=$(tail -n+4 $locus_file | head -1 | cut -d, -f4)
#snp=$(tail -n+4 $locus_file | head -1 | cut -d, -f5)

locus=${chr}_${beg}_${end}
echo $chr:$beg-$end
 # \ _${locus} \ 
plink   \
    --bfile  ${genotype}${chr}  \
    --keep-allele-order \
    --ld-snp $snp \
    --chr $chr --from-bp ${beg} --to-bp ${end} \
    --r2  \
    --ld-window 99999  \
    --ld-window-r2 0  \
    --out ${seq}  \
    --threads 8  \
    --memory 16000


# tabix ${gwas_file} \
#     $chr:$beg-$end \
#     -h --print-header | \
#     locuszoom --metal - \
#     --markercol SNPID \
#     --pvalcol MLOG10P \
#     --no-transform \
#     --refsnp $chr:$pos  \
#     --flank 0kbp  \
#     --build hg19 \
#     --source 1000G_March2012 \
#     --pop EUR \
#     --plotonly \
#     --prefix "23-Oct-24_ld_no"


#    --ld my_ld.txt  \ #    --ld-measure rsquare \
# change the delimiter
#tr ',' '-'

