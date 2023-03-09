if config["params"]["diversity_phylogenetic"]["do"]:
    rule mpse_diversity_phylogenetic:
        input:
            os.path.join(config["output"]["diversity_alpha"], "mpse/mpse.rds")
        output:
            plot = expand(os.path.join(
                config["output"]["diversity_phylogenetic"], "plot/diversity_phylogenetic.{outformat}"),
                outformat=["pdf", "svg", "png"])
        params:
            mpse_diversity_phylogenetic = os.path.join(WRAPPERS_DIR, "mpse_diversity_phylogenetic.R"),
            method = config["params"]["import_from"],
            group = config["params"]["group"],
            plot_prefix = os.path.join(config["output"]["diversity_phylogenetic"], "plot/diversity_phylogenetic"),
            width = config["params"]["diversity_phylogenetic"]["plot"]["width"],
            height = config["params"]["diversity_phylogenetic"]["plot"]["height"]
        conda:
            config["envs"]["mpse"]
        shell:
            '''
            Rscript {params.mpse_diversity_phylogenetic} \
            {params.method} \
            {input} \
            {params.group} \
            {params.plot_prefix} \
            {params.width} \
            {params.height}
            '''


    rule mpse_diversity_phylogenetic_all:
        input:
            rules.mpse_diversity_phylogenetic.output

        
else:
    rule mpse_diversity_phylogenetic_all:
        input:
 