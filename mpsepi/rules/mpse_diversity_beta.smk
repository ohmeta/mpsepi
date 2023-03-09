rule mpse_diversity_beta_cal:
    input:
        os.path.join(config["output"]["diversity_alpha"], "mpse/mpse.rds")
    output:
        dist_tsv = os.path.join(config["output"]["diversity_beta"], "mpse/dist.tsv"),
        mpse = os.path.join(config["output"]["diversity_beta"], "mpse/mpse.rds")
    params:
        mpse_diversity_beta = os.path.join(WRAPPERS_DIR, "mpse_diversity_beta.R"),
        group = config["params"]["group"],
        method = config["params"]["import_from"],
        distmethod = config["params"]["diversity_beta"]["distmethod"]
    conda:
        config["envs"]["mpse"]
    shell:
        '''
        Rscript {params.mpse_diversity_beta} \
        cal \
        {params.method} \
        {params.distmethod} \
        {input} \
        {params.group} \
        {output.dist_tsv} \
        {output.mpse}
        '''


rule mpse_diversity_beta_plot_dist:
    input:
        mpse = os.path.join(config["output"]["diversity_beta"], "mpse/mpse.rds")
    output:
        dist_samples_plot = expand(os.path.join(
            config["output"]["diversity_beta"], "plot/dist_samples.{outformat}"),
            outformat=["pdf", "svg", "png"]),
        dist_groups_plot = expand(os.path.join(
            config["output"]["diversity_beta"], "plot/dist_groups.{outformat}"),
            outformat=["pdf", "svg", "png"])
    params:
        mpse_diversity_beta = os.path.join(WRAPPERS_DIR, "mpse_diversity_beta.R"),
        group = config["params"]["group"],
        method = config["params"]["import_from"],
        distmethod = config["params"]["diversity_beta"]["distmethod"],
        plot_outdir = os.path.join(config["output"]["diversity_beta"], "plot/"),
        height_samples = config["params"]["diversity_beta"]["plot"]["dist_samples"]["height"],
        width_samples = config["params"]["diversity_beta"]["plot"]["dist_samples"]["width"],
        height_groups = config["params"]["diversity_beta"]["plot"]["dist_groups"]["height"],
        width_groups = config["params"]["diversity_beta"]["plot"]["dist_groups"]["width"]
    conda:
        config["envs"]["mpse"]
    shell:
        '''
        Rscript {params.mpse_diversity_beta} \
        plot \
        dist \
        {params.method} \
        {params.distmethod} \
        {input} \
        {params.group} \
        {params.plot_outdir} \
        {params.height_samples} \
        {params.width_samples} \
        {params.height_groups} \
        {params.width_groups}
        '''


rule mpse_diversity_beta_plot_pca:
    input:
        mpse = os.path.join(config["output"]["diversity_beta"], "mpse/mpse.rds")
    output:
        pca_plot = expand(os.path.join(
            config["output"]["diversity_beta"], "plot/pca.{outformat}"),
            outformat=["pdf", "svg", "png"])
    params:
        mpse_diversity_beta = os.path.join(WRAPPERS_DIR, "mpse_diversity_beta.R"),
        group = config["params"]["group"],
        method = config["params"]["import_from"],
        distmethod = config["params"]["diversity_beta"]["distmethod"],
        plot_outdir = os.path.join(config["output"]["diversity_beta"], "plot/"),
        height = config["params"]["diversity_beta"]["plot"]["pca"]["height"],
        width = config["params"]["diversity_beta"]["plot"]["pca"]["width"]
    conda:
        config["envs"]["mpse"]
    shell:
        '''
        Rscript {params.mpse_diversity_beta} \
        plot \
        pca \
        {params.method} \
        {params.distmethod} \
        {input} \
        {params.group} \
        {params.plot_outdir} \
        {params.height} \
        {params.width}
        '''


rule mpse_diversity_beta_plot_pcoa:
    input:
        mpse = os.path.join(config["output"]["diversity_beta"], "mpse/mpse.rds")
    output:
        pcoa_plot = expand(os.path.join(
            config["output"]["diversity_beta"], "plot/pcoa.{outformat}"),
            outformat=["pdf", "svg", "png"])
    params:
        mpse_diversity_beta = os.path.join(WRAPPERS_DIR, "mpse_diversity_beta.R"),
        group = config["params"]["group"],
        method = config["params"]["import_from"],
        distmethod = config["params"]["diversity_beta"]["distmethod"],
        plot_outdir = os.path.join(config["output"]["diversity_beta"], "plot/"),
        height = config["params"]["diversity_beta"]["plot"]["pcoa"]["height"],
        width = config["params"]["diversity_beta"]["plot"]["pcoa"]["width"]
    conda:
        config["envs"]["mpse"]
    shell:
        '''
        Rscript {params.mpse_diversity_beta} \
        plot \
        pcoa \
        {params.method} \
        {params.distmethod} \
        {input} \
        {params.group} \
        {params.plot_outdir} \
        {params.height} \
        {params.width}
        '''


rule mpse_diversity_beta_plot_nmds:
    input:
        mpse = os.path.join(config["output"]["diversity_beta"], "mpse/mpse.rds")
    output:
        nmds_plot = expand(os.path.join(
            config["output"]["diversity_beta"], "plot/nmds.{outformat}"),
            outformat=["pdf", "svg", "png"])
    params:
        mpse_diversity_beta = os.path.join(WRAPPERS_DIR, "mpse_diversity_beta.R"),
        group = config["params"]["group"],
        method = config["params"]["import_from"],
        distmethod = config["params"]["diversity_beta"]["distmethod"],
        plot_outdir = os.path.join(config["output"]["diversity_beta"], "plot/"),
        height = config["params"]["diversity_beta"]["plot"]["nmds"]["height"],
        width = config["params"]["diversity_beta"]["plot"]["nmds"]["width"]
    conda:
        config["envs"]["mpse"]
    shell:
        '''
        Rscript {params.mpse_diversity_beta} \
        plot \
        nmds \
        {params.method} \
        {params.distmethod} \
        {input} \
        {params.group} \
        {params.plot_outdir} \
        {params.height} \
        {params.width}
        '''


rule mpse_diversity_beta_plot_clust:
    input:
        mpse = os.path.join(config["output"]["diversity_beta"], "mpse/mpse.rds")
    output:
        clust_plot = expand(os.path.join(
            config["output"]["diversity_beta"], "plot/clust.{outformat}"),
            outformat=["pdf", "svg", "png"])
    params:
        mpse_diversity_beta = os.path.join(WRAPPERS_DIR, "mpse_diversity_beta.R"),
        group = config["params"]["group"],
        method = config["params"]["import_from"],
        distmethod = config["params"]["diversity_beta"]["distmethod"],
        plot_outdir = os.path.join(config["output"]["diversity_beta"], "plot/"),
        height = config["params"]["diversity_beta"]["plot"]["clust"]["height"],
        width = config["params"]["diversity_beta"]["plot"]["clust"]["width"]
    conda:
        config["envs"]["mpse"]
    shell:
        '''
        Rscript {params.mpse_diversity_beta} \
        plot \
        clust \
        {params.method} \
        {params.distmethod} \
        {input} \
        {params.group} \
        {params.plot_outdir} \
        {params.height} \
        {params.width}
        '''


rule mpse_diversity_beta_all:
    input:
        rules.mpse_diversity_beta_cal.output,
        rules.mpse_diversity_beta_plot_dist.output,
        rules.mpse_diversity_beta_plot_pca.output,
        rules.mpse_diversity_beta_plot_pcoa.output,
        rules.mpse_diversity_beta_plot_nmds.output,
        rules.mpse_diversity_beta_plot_clust.output
 