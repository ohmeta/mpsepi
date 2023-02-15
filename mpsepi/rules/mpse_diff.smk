rule mpse_diff:
    input:
        os.path.join(config["output"]["diversity_alpha"], "mpse/mpse.rds")
    output:
        lda_tsv = os.path.join(config["output"]["diff"], "mpse/lda.tsv"),
        tree_plot = expand(os.path.join(
            config["output"]["diff"], "plot/diff_tree.{outformat}"),
            outformat=["pdf", "svg", "png"]),
        cladogram_plot = expand(os.path.join(
            config["output"]["diff"], "plot/diff_cladogram.{outformat}"),
            outformat=["pdf", "svg", "png"]),
        box_bar_plot = expand(os.path.join(
            config["output"]["diff"], "plot/diff_box_bar.{outformat}"),
            outformat=["pdf", "svg", "png"]),
        #mahattan_plot = expand(os.path.join(
        #    config["output"]["diff"], "plot/diff_mahattan.{outformat}"),
        #    outformat=["pdf", "svg", "png"]),
        image = os.path.join(config["output"]["diff"], "mpse/diff.RData")
    params:
        mpse_diff = os.path.join(WRAPPERS_DIR, "mpse_diff.R"),
        group = config["params"]["group"],
        method = config["params"]["import_from"],
        first_test_alpha = config["params"]["diff"]["first_test_alpha"],
        tree_plot_prefix = os.path.join(config["output"]["diff"], "plot/diff_tree"),
        cladogram_plot_prefix = os.path.join(config["output"]["diff"], "plot/diff_cladogram"),
        box_bar_plot_prefix = os.path.join(config["output"]["diff"], "plot/diff_box_bar"),
        mahattan_plot_prefix = os.path.join(config["output"]["diff"], "plot/diff_mahattan"),
        h1 = config["params"]["diff"]["plot"]["tree"]["height"],
        w1 = config["params"]["diff"]["plot"]["tree"]["width"],
        h2 = config["params"]["diff"]["plot"]["cladogram"]["height"],
        w2 = config["params"]["diff"]["plot"]["cladogram"]["width"],
        h3 = config["params"]["diff"]["plot"]["box_bar"]["height"],
        w3 = config["params"]["diff"]["plot"]["box_bar"]["width"],
        h4 = config["params"]["diff"]["plot"]["mahattan"]["height"],
        w4 = config["params"]["diff"]["plot"]["mahattan"]["width"]
    conda:
        config["envs"]["mpse"]
    shell:
        '''
        Rscript {params.mpse_diff} {params.method} \
        {input} \
        {params.group} \
        {params.first_test_alpha} \
        {output.lda_tsv} \
        {params.tree_plot_prefix} \
        {params.h1} \
        {params.w1} \
        {params.cladogram_plot_prefix} \
        {params.h2} \
        {params.w2} \
        {params.box_bar_plot_prefix} \
        {params.h3} \
        {params.w3} \
        {output.image}
        '''


rule mpse_diff_all:
    input:
        rules.mpse_diff.output