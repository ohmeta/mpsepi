def mpse_input():
    if config["params"]["import_from"] in ["qiime2", "dada2"]:
        return os.path.join(config["output"]["rarefied"], "mpse/mpse_rarefied.rds")
    elif config["params"]["import_from"] == "metaphlan":
        return os.path.join(config["output"]["import"], "mpse/mpse.rds")
    else:
        print("No import method for %s" % config["params"]["import_from"])
        sys.exit(1)


def get_composition_plot_size(wildcards, plot, hw):
    return config["params"]["composition"]["plot"][plot][str(wildcards.level)][hw]


rule mpse_composition:
    input:
        mpse_input()
    output:
        abun_plot = expand(os.path.join(
            config["output"]["composition"], "plot/{{level}}/abun.{outformat}"),
            outformat=["pdf", "svg", "png"]),
        group_plot = expand(os.path.join(
            config["output"]["composition"], "plot/{{level}}/abun_group.{outformat}"),
            outformat=["pdf", "svg", "png"]),
        heatmap_plot = expand(os.path.join(
            config["output"]["composition"], "plot/{{level}}/heatmap.{outformat}"),
            outformat=["pdf", "svg", "png"])
    params:
        taxa = "{level}",
        mpse_composition = os.path.join(WRAPPERS_DIR, "mpse_composition.R"),
        method = config["params"]["import_from"],
        group = config["params"]["group"],
        abun_plot_prefix = os.path.join(config["output"]["composition"], "plot/{level}/"),
        group_plot_prefix = os.path.join(config["output"]["composition"], "plot/{level}/"),
        heatmap_plot_prefix = os.path.join(config["output"]["composition"], "plot/{level}/"),
        h1 = lambda wc: get_composition_plot_size(wc, "abundance", "height"),
        w1 = lambda wc: get_composition_plot_size(wc, "abundance", "width"),
        h2 = lambda wc: get_composition_plot_size(wc, "abundance_group", "height"),
        w2 = lambda wc: get_composition_plot_size(wc, "abundance_group", "width"),
        h3 = lambda wc: get_composition_plot_size(wc, "heatmap", "height"),
        w3 = lambda wc: get_composition_plot_size(wc, "heatmap", "width")
    conda:
        config["envs"]["mpse"]
    shell:
        '''
        Rscript {params.mpse_composition} {params.method} \
        {params.taxa} \
        {input} \
        {params.group} \
        {params.abun_plot_prefix} {params.h1} {params.w1} \
        {params.group_plot_prefix} {params.h2} {params.w2} \
        {params.heatmap_plot_prefix} {params.h3} {params.w3}
        '''


rule mpse_composition_all:
    input:
        expand([
            os.path.join(
                config["output"]["composition"], "plot/{level}/abun.{outformat}"),
            os.path.join(
                config["output"]["composition"], "plot/{level}/abun_group.{outformat}"),
            os.path.join(
                config["output"]["composition"], "plot/{level}/heatmap.{outformat}")],
                level=config["params"]["composition"]["level"],
                outformat=["pdf", "svg", "png"])
