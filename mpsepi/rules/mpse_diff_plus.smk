rule mpse_diff_plus_cal:
    input:
        os.path.join(config["output"]["diff"], "mpse/mpse.rds")
    output:
        mpse = os.path.join(config["output"]["diff_plus"], "mpse/{method}/mpse.rds"),
        tsv = os.path.join(config["output"]["diff_plus"], "mpse/{method}/diff.tsv")
    params:
        mpse_diff_plus = os.path.join(WRAPPERS_DIR, "mpse_diff_plus.R"),
        import_method = config["params"]["import_from"],
        diff_method = "{method}",
        dist_method = config["params"]["diversity_beta"]["distmethod"],
        formula = config["params"]["diff_plus"]["formula"],
    conda:
        config["envs"]["mpse"]
    shell:
        '''
        Rscript {params.mpse_diff_plus} \
        cal \
        {params.import_method} \
        {params.diff_method} \
        {params.dist_method} \
        "{params.formula}" \
        {input} \
        {output.mpse} \
        {output.tsv}
        '''


rule mpse_diff_plus_cal_all:
    input:
        expand([
            os.path.join(config["output"]["diff_plus"], "mpse/{method}/mpse.rds"),
            os.path.join(config["output"]["diff_plus"], "mpse/{method}/diff.tsv")],
            method=config["params"]["diff_plus"]["methods"])


rule mpse_diff_plus_plot_abundance:
    input:
        os.path.join(config["output"]["diff_plus"], "mpse/{method}/mpse.rds")
    output:
        expand(os.path.join(
            config["output"]["diff_plus"], "plot/{{method}}/abundance_heatmap.{outformat}"),
            outformat=["pdf", "svg", "png"])
    params:
        mpse_diff_plus = os.path.join(WRAPPERS_DIR, "mpse_diff_plus.R"),
        import_method = config["params"]["import_from"],
        diff_method = "{method}",
        dist_method = config["params"]["diversity_beta"]["distmethod"],
        group = config["params"]["group"],
        plot_prefix = os.path.join(config["output"]["diff_plus"], "plot/{method}/abundance_heatmap"),
        height = config["params"]["diff_plus"]["plot"]["abundance"]["height"],
        width = config["params"]["diff_plus"]["plot"]["abundance"]["width"]
    conda:
        config["envs"]["mpse"]
    shell:
        '''
        Rscript {params.mpse_diff_plus} \
        plot \
        abundance \
        {params.import_method} \
        {params.diff_method} \
        {params.dist_method} \
        {params.group} \
        {input} \
        {params.plot_prefix} \
        {params.height} \
        {params.width}
        '''


if config["params"]["diff_plus"]["plot"]["abundance"]["do"]:
    rule mpse_diff_plus_plot_abundance_all:
        input:
            expand(os.path.join(
                config["output"]["diff_plus"], "plot/{method}/abundance_heatmap.{outformat}"),
                outformat=["pdf", "svg", "png"],
                method=config["params"]["diff_plus"]["methods"])
else:
    rule mpse_diff_plus_plot_abundance_all:
        input:


rule mpse_diff_plus_plot_sample_tree:
    input:
        os.path.join(config["output"]["diff_plus"], "mpse/{method}/mpse.rds")
    output:
        expand(os.path.join(
            config["output"]["diff_plus"], "plot/{{method}}/sample_tree.{outformat}"),
            outformat=["pdf", "svg", "png"])
    params:
        mpse_diff_plus = os.path.join(WRAPPERS_DIR, "mpse_diff_plus.R"),
        import_method = config["params"]["import_from"],
        diff_method = "{method}",
        dist_method = config["params"]["diversity_beta"]["distmethod"],
        group = config["params"]["group"],
        plot_prefix = os.path.join(config["output"]["diff_plus"], "plot/{method}/sample_tree"),
        height = config["params"]["diff_plus"]["plot"]["sample_tree"]["height"],
        width = config["params"]["diff_plus"]["plot"]["sample_tree"]["width"]
    conda:
        config["envs"]["mpse"]
    shell:
        '''
        Rscript {params.mpse_diff_plus} \
        plot \
        sample_tree \
        {params.import_method} \
        {params.diff_method} \
        {params.dist_method} \
        {params.group} \
        {input} \
        {params.plot_prefix} \
        {params.height} \
        {params.width}
        '''


if config["params"]["diff_plus"]["plot"]["sample_tree"]["do"]:
    rule mpse_diff_plus_plot_sample_tree_all:
        input:
            expand(os.path.join(
                config["output"]["diff_plus"], "plot/{method}/sample_tree.{outformat}"),
                outformat=["pdf", "svg", "png"],
                method=config["params"]["diff_plus"]["methods"])
else:
    rule mpse_diff_plus_plot_sample_tree_all:
        input:

 
rule mpse_diff_plus_plot_otu_tree:
    input:
        os.path.join(config["output"]["diff_plus"], "mpse/{method}/mpse.rds")
    output:
        expand(os.path.join(
            config["output"]["diff_plus"], "plot/{{method}}/otu_tree.{outformat}"),
            outformat=["pdf", "svg", "png"])
    params:
        mpse_diff_plus = os.path.join(WRAPPERS_DIR, "mpse_diff_plus.R"),
        import_method = config["params"]["import_from"],
        diff_method = "{method}",
        dist_method = config["params"]["diversity_beta"]["distmethod"],
        group = config["params"]["group"],
        plot_prefix = os.path.join(config["output"]["diff_plus"], "plot/{method}/otu_tree"),
        height = config["params"]["diff_plus"]["plot"]["otu_tree"]["height"],
        width = config["params"]["diff_plus"]["plot"]["otu_tree"]["width"]
    conda:
        config["envs"]["mpse"]
    shell:
        '''
        Rscript {params.mpse_diff_plus} \
        plot \
        sample_tree \
        {params.import_method} \
        {params.diff_method} \
        {params.dist_method} \
        {params.group} \
        {input} \
        {params.plot_prefix} \
        {params.height} \
        {params.width}
        '''


if config["params"]["diff_plus"]["plot"]["otu_tree"]["do"]:
    rule mpse_diff_plus_plot_otu_tree_all:
        input:
            expand(os.path.join(
                config["output"]["diff_plus"], "plot/{method}/otu_tree.{outformat}"),
                outformat=["pdf", "svg", "png"],
                method=config["params"]["diff_plus"]["methods"])
else:
    rule mpse_diff_plus_plot_otu_tree_all:
        input:


rule mpse_diff_plus_all:
    input:
        rules.mpse_diff_plus_cal_all.input,
        rules.mpse_diff_plus_plot_abundance_all.input,
        rules.mpse_diff_plus_plot_sample_tree_all.input,
        rules.mpse_diff_plus_plot_otu_tree_all.input
