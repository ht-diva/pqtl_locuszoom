
rule compute_ld:
    output:
        ld = ws_path("ld/{locuseq}.ld"),
    params:
        locus = lambda wildcards: get_locus(wildcards.locuseq),
        lead  = lambda wildcards: get_snp(wildcards.locuseq),
        bfile = config["genotype"],
    resources:
        runtime=lambda wc, attempt: 120 + attempt * 60,
    shell:
        """
        echo "Coordinates: {params.locus}"

        # the index variant for pairwise ld computation
        snp={params.lead}

        # take region bounaries from locus string
        chr=$(echo {params.locus} | cut -d'_' -f1)
        beg=$(echo {params.locus} | cut -d'_' -f2)
        end=$(echo {params.locus} | cut -d'_' -f3)

        # remove ".ld" from ofile as plink add it by default
        # in this way, SMK can detect ofile to prevent from missing output error
        out_ld=$(echo {output.ld} | sed 's/.ld$//')

        # extend the boundaries by +/-100 kbp
        beg_ext=$((beg - 100000))
        end_ext=$((end + 100000))

        plink   \
            --bfile  {params.bfile}"$chr"  \
            --keep-allele-order \
            --ld-snp "$snp" \
            --chr "$chr" --from-bp "$beg_ext" --to-bp "$end_ext" \
            --r2  \
            --ld-window 99999  \
            --ld-window-r2 0  \
            --out "$out_ld"  \
            --threads 8  \
            --memory 16000
        """

# Here reshapes plink LD file to the desired structure by LZ (https://genome.sph.umich.edu/wiki/LocusZoom_Standalone#User-supplied_LD)
# First awk takes input, output of plink1 for a 1-to-all combinations of the SNPs within a region, and
# removes white spaces from columns and make it tab-separated.
# Second awk reorders 4 required columns of LD file for LZ after duplicating rsquare to replace with dprime -> 
# Note: Snakemake cannot interpret square bracet; it confilcts with internal SMK variable and retuens error once making DAG of jobs.
# First sed -e changes headers to snp1 (aby snp in the region), snp2 (reference snp), D` and R2 (LD measures)
# Second sed -E converts SNP id from chr:pos:ref:alt to chr:pos_ref/alt to allow merge with annotation in LZ sqlite database

rule reshape_ld:
    input:
        ld = ws_path("ld/{locuseq}.ld"),
    output:
        ofile = ws_path("ld_reshaped/{locuseq}.ld"),
    resources:
        runtime=lambda wc, attempt: 120 + attempt * 60,
    shell:
        """
        awk -v OFS="\t" '$1=$1' {input.ld} | awk '{{print $6"\t"$3"\t"$7"\t"$7}}' OFS="\t"  |  sed -e '1s/SNP_B/snp1/' -e '1s/SNP_A/snp2/' -e '1s/R2/dprime/' -e '1s/R2/rsquare/'  |  sed -E 's/([0-9]+:[0-9]+):([A-Z]+):([A-Z]+)/\\1_\\2\/\\3/g'  >  {output.ofile}           
        """
