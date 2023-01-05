def mpse_input():
    if config["params"]["import_from"] in ["qiime2", "dada2"]:
        return os.path.join(config["output"]["rarefied"], "mpse/mpse_rarefied.rds")
    elif config["params"]["import_from"] == "metaphlan":
        return os.path.join(config["output"]["import"], "mpse/mpse.rds")
    else:
        print("No import method for %s" % config["params"]["import_from"])
        sys.exit(1)


rule mpse_composition:
    input:
        mpse_input
    output:
        abun_plot = expand(os.path.join(
            config["output"]["composition"], "abun_plot/composition_{level}.{format}"),
            level=["phylum", "genus", "species"],
            format=["pdf", "svg", "png"]),
        group_plot = expand(os.path.join(
            config["output"]["composition"], "group_plot/composition_{level}.{format}"),
            level=["phylum", "genus", "species"],
            format=["pdf", "svg", "png"]),
        heatmap_plot = expand(os.path.join(
            config["output"]["composition"], "heatmap_plot/composition_{level}.{format}"),
            level=["phylum", "genus", "species"],
            format=["pdf", "svg", "png"]),
        image = os.path.join(config["output"]["composition"], "image/composition.RData")
    params:
        method = config["params"]["import_from"],
        group = config["params"]["group"],
        abun_plot_prefix = config["output"]["composition"], "abun_plot/composition_",
        group_plot_prefix = config["output"]["composition"], "group_plot/composition_",
        heatmap_plot_prefix = config["output"]["composition"], "heatmap_plot/composition_"
    conda:
        config["envs"]["mpse"]
    shell:
        '''
        Rscript ../mpse_composition.R {params.method} \
        {input} \
        {params.group} \
        {params.abun_plot_prefix} \
        {params.group_plot_prefix} \
        {params.heatmap_plot_prefix} \
        {output.image}
        '''
