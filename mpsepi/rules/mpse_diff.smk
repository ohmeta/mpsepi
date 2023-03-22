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
        fc_method = config["params"]["diff"]["fc_method"],
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
        {params.fc_method} \
        {params.second_test_method} \
        {params.second_test_alpha} \
        {params.subcl_min} \
        {params.subcl_test} \
        {params.ml_method} \
        {params.ldascore}
        '''


rule mpse_diff_plot_tree:
    input:
        os.path.join(config["output"]["diff"], "mpse/mpse.rds")
    output:
        cladogram_plot = expand(os.path.join(
            config["output"]["diff"], "plot/diff_tree.{outformat}"),
            outformat=["pdf", "svg", "png"]),
    params:
        mpse_diff = os.path.join(WRAPPERS_DIR, "mpse_diff.R"),
        group = config["params"]["group"],
        plot_prefix = os.path.join(config["output"]["diff"], "plot/diff_tree"),
        height = config["params"]["diff"]["plot"]["tree"]["height"],
        width = config["params"]["diff"]["plot"]["tree"]["width"]
    conda:
        config["envs"]["mpse"]
    shell:
        '''
        Rscript {params.mpse_diff} \
        plot \
        tree \
        {params.group} \
        {input} \
        {params.plot_prefix} \
        {params.height} \
        {params.width}
        '''


rule mpse_diff_plot_cladogram:
    input:
        os.path.join(config["output"]["diff"], "mpse/mpse.rds")
    output:
        cladogram_plot = expand(os.path.join(
            config["output"]["diff"], "plot/diff_cladogram.{outformat}"),
            outformat=["pdf", "svg", "png"]),
    params:
        mpse_diff = os.path.join(WRAPPERS_DIR, "mpse_diff.R"),
        group = config["params"]["group"],
        plot_prefix = os.path.join(config["output"]["diff"], "plot/diff_cladogram"),
        height = config["params"]["diff"]["plot"]["cladogram"]["height"],
        width = config["params"]["diff"]["plot"]["cladogram"]["width"]
    conda:
        config["envs"]["mpse"]
    shell:
        '''
        Rscript {params.mpse_diff} \
        plot \
        cladogram \
        {params.group} \
        {input} \
        {params.plot_prefix} \
        {params.height} \
        {params.width}
        '''


rule mpse_diff_plot_box_bar:
    input:
        os.path.join(config["output"]["diff"], "mpse/mpse.rds")
    output:
        cladogram_plot = expand(os.path.join(
            config["output"]["diff"], "plot/diff_box_bar.{outformat}"),
            outformat=["pdf", "svg", "png"]),
    params:
        mpse_diff = os.path.join(WRAPPERS_DIR, "mpse_diff.R"),
        group = config["params"]["group"],
        plot_prefix = os.path.join(config["output"]["diff"], "plot/diff_box_bar"),
        height = config["params"]["diff"]["plot"]["box_bar"]["height"],
        width = config["params"]["diff"]["plot"]["box_bar"]["width"]
    conda:
        config["envs"]["mpse"]
    shell:
        '''
        Rscript {params.mpse_diff} \
        plot \
        box_bar \
        {params.group} \
        {input} \
        {params.plot_prefix} \
        {params.height} \
        {params.width}
        '''


rule mpse_diff_plot_mahattan:
    input:
        os.path.join(config["output"]["diff"], "mpse/mpse.rds")
    output:
        cladogram_plot = expand(os.path.join(
            config["output"]["diff"], "plot/diff_mahattan.{outformat}"),
            outformat=["pdf", "svg", "png"]),
    params:
        mpse_diff = os.path.join(WRAPPERS_DIR, "mpse_diff.R"),
        group = config["params"]["group"],
        plot_prefix = os.path.join(config["output"]["diff"], "plot/diff_mahattan"),
        height = config["params"]["diff"]["plot"]["mahattan"]["height"],
        width = config["params"]["diff"]["plot"]["mahattan"]["width"]
    conda:
        config["envs"]["mpse"]
    shell:
        '''
        Rscript {params.mpse_diff} \
        plot \
        mahattan \
        {params.group} \
        {input} \
        {params.plot_prefix} \
        {params.height} \
        {params.width}
        '''


rule mpse_diff_all:
    input:
        rules.mpse_diff_cal.output,
        rules.mpse_diff_plot_tree.output,
        rules.mpse_diff_plot_cladogram.output,
        rules.mpse_diff_plot_box_bar.output,
        rules.mpse_diff_plot_mahattan.output
