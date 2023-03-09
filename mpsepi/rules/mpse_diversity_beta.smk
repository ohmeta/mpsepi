rule mpse_diversity_beta:
    input:
        os.path.join(config["output"]["diversity_alpha"], "mpse/mpse.rds")
    output:
        dist_tsv = os.path.join(config["output"]["diversity_beta"], "mpse/dist.tsv"),
        dist_samples_plot = expand(os.path.join(
            config["output"]["diversity_beta"], "plot/dist_samples.{outformat}"),
            outformat=["pdf", "svg", "png"]),
        dist_groups_plot = expand(os.path.join(
            config["output"]["diversity_beta"], "plot/dist_groups.{outformat}"),
            outformat=["pdf", "svg", "png"]),
        pca_plot = expand(os.path.join(
            config["output"]["diversity_beta"], "plot/pca.{outformat}"),
            outformat=["pdf", "svg", "png"]),
        pcoa_plot = expand(os.path.join(
            config["output"]["diversity_beta"], "plot/pcoa.{outformat}"),
            outformat=["pdf", "svg", "png"]),
        clust_plot = expand(os.path.join(
            config["output"]["diversity_beta"], "plot/clust.{outformat}"),
            outformat=["pdf", "svg", "png"]),
        image = os.path.join(config["output"]["diversity_beta"], "mpse/diversity_beta.RData")
    params:
        mpse_diversity_beta = os.path.join(WRAPPERS_DIR, "mpse_diversity_beta.R"),
        group = config["params"]["group"],
        method = config["params"]["import_from"],
        distmethod = config["params"]["diversity_beta"]["distmethod"],
        plot_outdir = os.path.join(config["output"]["diversity_beta"], "plot/"),
        h1 = config["params"]["diversity_beta"]["plot"]["dist_samples"]["height"],
        w1 = config["params"]["diversity_beta"]["plot"]["dist_samples"]["width"],
        h2 = config["params"]["diversity_beta"]["plot"]["dist_groups"]["height"],
        w2 = config["params"]["diversity_beta"]["plot"]["dist_groups"]["width"],
        h3 = config["params"]["diversity_beta"]["plot"]["pca"]["height"],
        w3 = config["params"]["diversity_beta"]["plot"]["pca"]["width"],
        h4 = config["params"]["diversity_beta"]["plot"]["pcoa"]["height"],
        w4 = config["params"]["diversity_beta"]["plot"]["pcoa"]["width"],
        h5 = config["params"]["diversity_beta"]["plot"]["clust"]["height"],
        w5 = config["params"]["diversity_beta"]["plot"]["clust"]["width"]
    conda:
        config["envs"]["mpse"]
    shell:
        '''
        Rscript {params.mpse_diversity_beta} {params.method} \
        {params.distmethod} \
        {input} \
        {params.group} \
        {output.dist_tsv} \
        {params.plot_outdir} \
        {output.image} \
        {params.h1} {params.w1} \
        {params.h2} {params.w2} \
        {params.h3} {params.w3} \
        {params.h4} {params.w4} \
        {params.h5} {params.w5}
        '''


rule mpse_diversity_beta_all:
    input:
        rules.mpse_diversity_beta.output
 