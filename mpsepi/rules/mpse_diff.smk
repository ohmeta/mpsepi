rule mpse_diff:
    input:
        mpse_input()
    output:
        lda_tsv = os.path.join(config["output"]["diff"], "mpse/lda.tsv"),
        tree_plot = expand(os.path.join(
            config["output"]["diff"], "tree_plot/diff_tree.{outformat}"),
            outformat=["pdf", "svg", "png"]),
        cladogram_plot = expand(os.path.join(
            config["output"]["diff"], "cladogram_plot/diff_cladogram.{outformat}"),
            outformat=["pdf", "svg", "png"]),
        box_bar_plot = expand(os.path.join(
            config["output"]["diff"], "box_bar_plot/diff_box_bar.{outformat}"),
            outformat=["pdf", "svg", "png"]),
        mahattan_plot = expand(os.path.join(
            config["output"]["diff"], "mahattan_plot/diff_mahattan.{outformat}"),
            outformat=["pdf", "svg", "png"]),
        image = os.path.join(config["output"]["diff"], "image/diff.RData")
    params:
        mpse_diff = os.path.join(WRAPPERS_DIR, "mpse_diff.R"),
        group = config["params"]["group"],
        method = config["params"]["import_from"],
        first_test_alpha = config["params"]["diff"]["first_test_alpha"],
        tree_plot_prefix = os.path.join(config["output"]["diff"], "tree_plot/diff_tree"),
        cladogram_plot_prefix = os.path.join(config["output"]["diff"], "cladogram_plot/diff_cladogram"),
        box_bar_plot_prefix = os.path.join(config["output"]["diff"], "box_bar_plot/diff_box_bar"),
        mahattan_plot_prefix = os.path.join(config["output"]["diff"], "mahattan_plot/diff_mahattan")
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
        {params.cladogram_plot_prefix} \
        {params.box_bar_plot_prefix} \
        {params.mahattan_plot_prefix} \
        {output.image}
        '''


rule mpse_diff_all:
    input:
        rules.mpse_diff.output