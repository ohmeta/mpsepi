rule mpse_permanova:
    input:
        mpse = os.path.join(config["output"]["diversity_beta"], "mpse/mpse.rds")
    output:
        os.path.join(config["output"]["permanova"], "permanova.tsv")
    params:
        mpse_permanova = os.path.join(WRAPPERS_DIR, "mpse_permanova.R"),
        group = config["params"]["group"],
        distmethod = config["params"]["diversity_beta"]["distmethod"]
    conda:
        config["envs"]["mpse"]
    shell:
        '''
        Rscript {params.mpse_permanova} \
        {params.distmethod} \
        {input} \
        {params.group} \
        {output}
        '''


rule mpse_permanova_all:
    input:
        rules.mpse_permanova.output
 