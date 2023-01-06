rule mpse_diversity_alpha:
    input:
        os.path.join(config["output"]["composition"], "mpse/mpse.rds")
    output:
        mpse = os.path.join(config["output"]["diversity_alpha"], "mpse/mpse.rds"),
        alpha_tsv = os.path.join(config["output"]["diversity_alpha"], "mpse/diversity_alpha.tsv"),
        plot = expand(os.path.join(
            config["output"]["diversity_alpha"], "plot/diversity_alpha.{outformat}"),
            outformat=["pdf", "svg", "png"]),
        image = os.path.join(config["output"]["diversity_alpha"], "image/diversity_alpha.RData")
    params:
        mpse_diversity_alpha = os.path.join(WRAPPERS_DIR, "mpse_diversity_alpha.R"),
        method = config["params"]["import_from"],
        group = config["params"]["group"],
        width = config["params"]["diversity_alpha"]["plot"]["width"],
        height = config["params"]["diversity_alpha"]["plot"]["height"]
    conda:
        config["envs"]["mpse"]
    shell:
        '''
        Rscript {params.mpse_diversity_alpha} {params.method} \
        {input} {output.mpse} \
        {params.group} \
        {output.alpha_tsv} \
        {output.plot[0]} \
        {output.plot[1]} \
        {output.plot[2]} \
        {params.width} \
        {params.height} \
        {output.image}
        '''


rule mpse_diversity_alpha_all:
    input:
        rules.mpse_diversity_alpha.output