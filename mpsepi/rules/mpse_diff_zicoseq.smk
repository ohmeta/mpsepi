rule mpse_diff_zicoseq_cal:
    input:
        os.path.join(config["output"]["diff"], "mpse/mpse.rds")
    output:
        mpse = os.path.join(config["output"]["diff_zicoseq"], "mpse/mpse_zicoseq.rds"),
        lda_tsv = os.path.join(config["output"]["diff_zicoseq"], "mpse/lda.tsv")
    params:
        mpse_diff_zoceseq = os.path.join(WRAPPERS_DIR, "mpse_diff_zicoseq.R"),
        group = config["params"]["group"],
        method = config["params"]["import_from"]
    conda:
        config["envs"]["mpse"]
    shell:
        '''
        Rscript {params.mpse_diff_zoceseq} \
        cal \
        {params.method} \
        {params.group} \
        {input} \
        {output.mpse} \
        {output.lda_tsv}
        '''


rule mpse_diff_zicoseq_plot_tree:
    input:
        os.path.join(config["output"]["diff_zicoseq"], "mpse/mpse_zicoseq.rds")
    output:
        cladogram_plot = expand(os.path.join(
            config["output"]["diff_zicoseq"], "plot/diff_tree.{outformat}"),
            outformat=["pdf", "svg", "png"]),
    params:
        mpse_diff_zicoseq = os.path.join(WRAPPERS_DIR, "mpse_diff_zicoseq.R"),
        group = config["params"]["group"],
        plot_prefix = os.path.join(config["output"]["diff_zicoseq"], "plot/diff_tree"),
        height = config["params"]["diff_zicoseq"]["plot"]["tree"]["height"],
        width = config["params"]["diff_zicoseq"]["plot"]["tree"]["width"]
    conda:
        config["envs"]["mpse"]
    shell:
        '''
        Rscript {params.mpse_diff_zicoseq} \
        plot \
        tree \
        {params.group} \
        {input} \
        {params.plot_prefix} \
        {params.height} \
        {params.width}
        '''


rule mpse_diff_zicoseq_plot_cladogram:
    input:
        os.path.join(config["output"]["diff_zicoseq"], "mpse/mpse_zicoseq.rds")
    output:
        cladogram_plot = expand(os.path.join(
            config["output"]["diff_zicoseq"], "plot/diff_cladogram.{outformat}"),
            outformat=["pdf", "svg", "png"])
    params:
        mpse_diff_zicoseq = os.path.join(WRAPPERS_DIR, "mpse_diff_zicoseq.R"),
        group = config["params"]["group"],
        plot_prefix = os.path.join(config["output"]["diff_zicoseq"], "plot/diff_cladogram"),
        height = config["params"]["diff_zicoseq"]["plot"]["cladogram"]["height"],
        width = config["params"]["diff_zicoseq"]["plot"]["cladogram"]["width"]
    conda:
        config["envs"]["mpse"]
    shell:
        '''
        Rscript {params.mpse_diff_zicoseq} \
        plot \
        cladogram \
        {params.group} \
        {input} \
        {params.plot_prefix} \
        {params.height} \
        {params.width}
        '''


rule mpse_diff_zicoseq_plot_box_bar:
    input:
        os.path.join(config["output"]["diff_zicoseq"], "mpse/mpse_zicoseq.rds")
    output:
        cladogram_plot = expand(os.path.join(
            config["output"]["diff_zicoseq"], "plot/diff_box_bar.{outformat}"),
            outformat=["pdf", "svg", "png"])
    params:
        mpse_diff_zicoseq = os.path.join(WRAPPERS_DIR, "mpse_diff_zicoseq.R"),
        group = config["params"]["group"],
        plot_prefix = os.path.join(config["output"]["diff_zicoseq"], "plot/diff_box_bar"),
        height = config["params"]["diff_zicoseq"]["plot"]["box_bar"]["height"],
        width = config["params"]["diff_zicoseq"]["plot"]["box_bar"]["width"]
    conda:
        config["envs"]["mpse"]
    shell:
        '''
        Rscript {params.mpse_diff_zicoseq} \
        plot \
        box_bar \
        {params.group} \
        {input} \
        {params.plot_prefix} \
        {params.height} \
        {params.width}
        '''


rule mpse_diff_zicoseq_plot_mahattan:
    input:
        os.path.join(config["output"]["diff_zicoseq"], "mpse/mpse_zicoseq.rds")
    output:
        cladogram_plot = expand(os.path.join(
            config["output"]["diff_zicoseq"], "plot/diff_mahattan.{outformat}"),
            outformat=["pdf", "svg", "png"])
    params:
        mpse_diff_zicoseq = os.path.join(WRAPPERS_DIR, "mpse_diff_zicoseq.R"),
        group = config["params"]["group"],
        plot_prefix = os.path.join(config["output"]["diff_zicoseq"], "plot/diff_mahattan"),
        height = config["params"]["diff_zicoseq"]["plot"]["mahattan"]["height"],
        width = config["params"]["diff_zicoseq"]["plot"]["mahattan"]["width"]
    conda:
        config["envs"]["mpse"]
    shell:
        '''
        Rscript {params.mpse_diff_zicoseq} \
        plot \
        mahattan \
        {params.group} \
        {input} \
        {params.plot_prefix} \
        {params.height} \
        {params.width}
        '''


rule mpse_diff_zicoseq_all:
    input:
        rules.mpse_diff_zicoseq_cal.output,
        #rules.mpse_diff_zicoseq_plot_tree.output,
        rules.mpse_diff_zicoseq_plot_cladogram.output,
        #rules.mpse_diff_zicoseq_plot_box_bar.output,
        rules.mpse_diff_zicoseq_plot_mahattan.output
