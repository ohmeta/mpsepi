def mpse_input():
    if config["params"]["import_from"] in ["qiime2", "dada2"]:
        return os.path.join(config["output"]["rarefied"], "mpse/mpse_rarefied.rds")
    elif config["params"]["import_from"] == "metaphlan":
        return os.path.join(config["output"]["import"], "mpse/mpse.rds")
    else:
        print("No import method for %s" % config["params"]["import_from"])
        sys.exit(1)


rule mpse_diversity_alpha:
    input:
        mpse_input
    output:
        alpha_tsv = os.path.join(config["output"]["diversity_alpha"], "mpse/diversity_alpha.tsv")
        plot = expand(os.path.join(
            config["output"]["diversity_alpha"], "plot/diversity_alpha.{format}",
            format=["pdf", "svg", "png"]))
    params:
        method = config["params"]["import_from"],
        group = config["params"]["group"],
        width = config["params"]["diversity_alpha"]["plot"]["width"],
        height = config["params"]["diversity_alpha"]["plot"]["height"]
    conda:
        config["envs"]["mpse"]
    shell:
        '''
        Rscript ../mpse_diversity_alpha.R {params.method} \
        {input} \
        {params.group} \
        {output.alpha_tsv} \
        {output.plot[0]} \
        {output.plot[1]} \
        {output.plot[2]} \
        {params.width} \
        {params.height}
        '''
