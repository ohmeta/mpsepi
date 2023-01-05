rule mpse_diversity_beta:
    input:
        mpse_input
    output:
        dist_tsv = os.path.join(config["output"]["diversity_beta"], "mpse/dist.tsv"),
        dist_plot = expand(os.path.join(
            config["output"]["diversity_beta"], "dist_plot/dist_samples.{format}",
            format=["pdf", "svg", "png"])),
        compare_plot = expand(os.path.join(
            config["output"]["diversity_beta"], "dist_plot/dist_compare.{format}",
            format=["pdf", "svg", "png"])),
        pcoa_plot = expand(os.path.join(
            config["output"]["diversity_beta"], "pcoa_plot/pcoa.{format}",
            format=["pdf", "svg", "png"])),
        image = os.path.join(config["output"]["diversity_beta"], "image/diversity_beta.RData")
    params:
        group = config["params"]["group"],
        distmethod = config["params"]["diversity_beta"]["distmethod"],
        dist_plot_prefix = config["output"]["diversity_beta"], "dist_plot/dist_samples",
        compare_plot_prefix = config["output"]["diversity_beta"], "dist_plot/dist_compare",
        pcoa_plot_prefix = config["output"]["diversity_beta"], "pcoa_plot/pcoa"
    conda:
        config["envs"]["mpse"]
    shell:
        '''
        Rscript ../mpse_diversity_beta.R \
        {params.distmethod} \
        {input} \
        {params.group} \
        {output.dist_tsv} \
        {params.dist_plot_prefix} \
        {params.compare_plot_prefix} \
        {params.pcoa_plot_prefix} \
        {output.image}
        '''
