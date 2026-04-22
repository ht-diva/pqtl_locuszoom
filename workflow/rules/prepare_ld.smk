
rule compute_ld:
    output:
        ld = ws_path("ld/{locuseq}.ld"),
    params:
        locus = lambda wildcards: get_locus(wildcards.locuseq),
        lead  = lambda wildcards: get_snp(wildcards.locuseq),
        bfile = lambda wildcards: get_geno(wildcards.locuseq),
        buffer = config.get("options").get("buffer"),
        ldwind = config.get("options").get("ld_window"),
        ldwind_r2 = config.get("options").get("ld_window_r2"),
    resources:
        runtime=lambda wc, attempt: 120 + attempt * 60,
    script:
        "../scripts/pairwise_ld.sh"


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
