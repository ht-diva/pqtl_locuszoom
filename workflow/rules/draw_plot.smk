
rule draw_plot:
    input:
        ld = ws_path("ld_reshaped/{locuseq}.ld"),
        gwas = ws_path("data/{locuseq}.tsv.bgz"),
    output:
        sentinel = ws_path("plot_cond/{locuseq}.sentinel"),
    params:
        locus = lambda wildcards: get_locus(wildcards.locuseq),
        lead  = lambda wildcards: get_snp(wildcards.locuseq),
        prefix = "{locuseq}",
        outdir = ws_path("plot_cond"),
        tail = config.get("options").get("extn_window"),
        plab = config.get("options").get("plab"),
        snplab = config.get("options").get("snplab"),
        build = config.get("options").get("build"),
        measure = config.get("options").get("ld_measure"),
        recomb = config.get("options").get("show_recomb"),
    #conda:
    #    "envs/environment.yml"
    resources:
        runtime=lambda wc, attempt: 120 + attempt * 60,
    shell:
        """
        echo "Genomic region: {params.locus}"
       
        # index variant need to be formated readable for locuszoom 
        target=$(echo {params.lead} | sed -E 's/([0-9]+:[0-9]+):([A-Z]+):([A-Z]+)/\\1_\\2\/\\3/g')

        # take region bounaries from locus string
        chr=$(echo {params.locus} | cut -d'_' -f1)
        beg=$(echo {params.locus} | cut -d'_' -f2)
        end=$(echo {params.locus} | cut -d'_' -f3)
        
        # extend the boundaries by +/- 100 kbp
        beg_ext=$((beg - {params.tail}))
        end_ext=$((end + {params.tail}))
        
        # reformat locus to be readable for locuzoom
        region=${{chr}}:${{beg_ext}}-${{end_ext}}
        
        source /exchange/healthds/singularity_functions

        echo "target is: $target"
        echo "region is: $region"

        tabix  {input.gwas} $region -h | \
            sed -E 's/([0-9]+:[0-9]+):([A-Z]+):([A-Z]+)/\\1_\\2\/\\3/g' | \
                locuszoom  \
                    --metal - \
                    --markercol {params.snplab} \
                    --pvalcol {params.plab} \
                    --no-transform \
                    --refsnp $target \
                    --chr $chr \
                    --start $beg_ext \
                    --end $end_ext \
                    --build {params.build} \
                    --svg  \
                    --ld {input.ld} \
                    --ld-measure {params.measure} \
                    --plotonly  \
                    showRecomb={params.recomb} \
                    --prefix {params.prefix}
            
        # moving plots to the output directory
        mkdir -p {params.outdir}
        mv {params.prefix}* {params.outdir}

        touch {output.sentinel}
        """
