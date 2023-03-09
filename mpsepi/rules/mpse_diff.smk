rule mpse_diff_cal:
    input:
        os.path.join(config["output"]["diversity_alpha"], "mpse/mpse.rds")
    output:
        mpse = os.path.join(config["output"]["diff"], "mpse/mpse.rds"),
        lda_tsv = os.path.join(config["output"]["diff"], "mpse/lda.tsv")
    params:
        mpse_diff = os.path.join(WRAPPERS_DIR, "mpse_diff.R"),
        group = config["params"]["group"],
        method = config["params"]["import_from"],
        first_test_method = config["params"]["diff"]["first_test_method"],
        first_test_alpha = config["params"]["diff"]["first_test_alpha"],
        filter_p = config["params"]["diff"]["filter_p"],
        strict = config["params"]["diff"]["strict"],
        second_test_method = config["params"]["diff"]["second_test_method"],
        second_test_alpha = config["params"]["diff"]["second_test_alpha"],
        subcl_min = config["params"]["diff"]["subcl_min"],
        subcl_test = config["params"]["diff"]["subcl_test"],
        ml_method = config["params"]["diff"]["ml_method"],
        ldascore = config["params"]["diff"]["ldascore"]
    conda:
        config["envs"]["mpse"]
    shell:
        '''
        Rscript {params.mpse_diff} \
        cal \
        {params.method} \
        {params.group} \
        {input} \
        {output.mpse} \
        {output.lda_tsv} \
        {params.first_test_method} \
        {params.first_test_alpha} \
        {params.filter_p} \
        {params.strict} \
        {params.second_test_method} \
        {params.second_test_alpha} \
        {params.subcl_min} \
        {params.subcl_test} \
        {params.ml_method} \
        {params.ldascore}
        '''


'''
rule mpse_diff_plot:
    input:
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
 
    output:
    params:
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
'''
 

rule mpse_diff_all:
    input:
        rules.mpse_diff_cal.output