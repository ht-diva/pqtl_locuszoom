

rule take_data:
    input:
        cond_rds = lambda wildcards: get_rds(wildcards.locuseq),
    output:
        ofile = ws_path("data/{locuseq}.tsv")
    params:
        cojo_snp = lambda wildcards: get_snp(wildcards.locuseq),
    conda:
       "../envs/environment.yml"
    script:
        "scripts/grep_data.R"


rule index_data:
    input:
        data = ws_path("data/{locuseq}.tsv"),
    output:
        bgzip = ws_path("data/{locuseq}.tsv.bgz"),
        #index = ws_path("data/{locuseq}.tsv.bgz.tbi"),
    shell:
        """
        source /exchange/healthds/singularity_functions
        bgzip {input.data} -o {output.bgzip}
        tabix -s 1 -b 2 -e 2 {output.bgzip}
        """
