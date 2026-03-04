
rule draw_plot:
    input:
        ld = ws_path("ld_reshaped/{locuseq}.ld"),
        gwas  = lambda wildcards: get_gwas(wildcards.locuseq),
    output:
        sentinel = ws_path("plot/{locuseq}.sentinel"),
    params:
        locus = lambda wildcards: get_locus(wildcards.locuseq),
        lead  = lambda wildcards: get_snp(wildcards.locuseq),
        prefix = "{locuseq}",
        outdir = ws_path("plot"),
        header = config.get("header"),
        tail = config.get("options").get("extn_window"),
        plab = config.get("options").get("plab"),
        snplab = config.get("options").get("snplab"),
        build = config.get("options").get("build"),
        measure = config.get("options").get("ld_measure"),
        recomb = config.get("options").get("show_recomb"),
        study = config.get("run").get("study"),
    #conda:
    #    "envs/environment.yml"
    resources:
        runtime=lambda wc, attempt: 120 + attempt * 60,
    script:
        "../scripts/draw_lz.sh"
