rule mpse_diversity_beta:
    input:
        mpse_input()
    output:
        dist_tsv = os.path.join(config["output"]["diversity_beta"], "mpse/dist.tsv"),
        dist_samples_plot = expand(os.path.join(
            config["output"]["diversity_beta"], "dist_plot/dist_samples.{outformat}"),
            outformat=["pdf", "svg", "png"]),
        dist_groups_plot = expand(os.path.join(
            config["output"]["diversity_beta"], "dist_plot/dist_groups.{outformat}"),
            outformat=["pdf", "svg", "png"]),
        pcoa_plot = expand(os.path.join(
            config["output"]["diversity_beta"], "pcoa_plot/pcoa.{outformat}"),
            outformat=["pdf", "svg", "png"]),
        clust_plot = expand(os.path.join(
            config["output"]["diversity_beta"], "clust_plot/clust.{outformat}"),
            outformat=["pdf", "svg", "png"]),
        image = os.path.join(config["output"]["diversity_beta"], "image/diversity_beta.RData")
    params:
        group = config["params"]["group"],
        method = config["params"]["import_from"],
        distmethod = config["params"]["diversity_beta"]["distmethod"],
        dist_samples_plot_prefix = os.path.join(config["output"]["diversity_beta"], "dist_plot/dist_samples"),
        dist_groups_plot_prefix = os.path.join(config["output"]["diversity_beta"], "dist_plot/dist_groups"),
        pcoa_plot_prefix = os.path.join(config["output"]["diversity_beta"], "pcoa_plot/pcoa"),
        clust_plot_prefix = os.path.join(config["output"]["diversity_beta"], "clust_plot/clust")
    conda:
        config["envs"]["mpse"]
    shell:
        '''
        Rscript ../wrappers/mpse_diversity_beta.R {params.method} \
        {params.distmethod} \
        {input} \
        {params.group} \
        {output.dist_tsv} \
        {params.dist_samples_plot_prefix} \
        {params.dist_groups_plot_prefix} \
        {params.pcoa_plot_prefix} \
        {params.clust_plot_prefix} \
        {output.image}
        '''


rule mpse_diversity_beta_all:
    input:
        rules.mpse_diversity_beta.output
 
