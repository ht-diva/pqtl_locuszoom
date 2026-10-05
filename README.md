# pqtl_locuszoom
Regional association plot of the signals in the pQTL project

### Input preparation
To inform the pipeline which regions to plot, please consider similar data structure as locus breaker results (esp. for ht-diva/pqtl_conditional workflow users). Otherwise, a comma-separated file need to be created by the user requiring these columns respecting exact headers:
- chr
- start
- end
- SNPID
- MLOG10P
- seqid


The GWAS sumstats file must be indexed by tabix and the indexed sumstats file must contains the header row so that locusZoom can read the data. Otherwise, it is necessary to provide a tab-separated header file separately through the configuration file. For the harmonized sumstats for BELEIVE and INTERVAL studies you must introduce this file. Note that the indexed sumstats of Meta-analysis of INTERVAL and CHRIS PWASs are currently well indexed and the header file is not needed except otherwise shown. 


### Options
There are some options in the config:
- show_recomb: TRUE/FALSE  --> FALSE skips showing the recombination line.
- build: hg37/hg38  --> genomic build of the variants' coordinates
- conditional_plot: False will draw regional association plot using marginal SNPs coefficients from GWAS results.
[to be completed]