# pqtl_locuszoom
Regional association plot of the signals in the pQTL project

### Input preparation
To inform the pipeline which regions to plot, please consider similar data structure as locus breaker results (esp. for pQTL Fine-mapping pipe users). Otherwise, a comma-separated file need to be created by the user requiring these columns respecting exact headers:
- chr
- start
- end
- SNPID
- MLOG10P
- seqid


### Options
There are some options in the config:
- show_recomb: TRUE/FALSE  --> FALSE skips showing the recombination line.
- build: hg37/hg38  --> genomic build of the variants' coordinates
[to be completed]