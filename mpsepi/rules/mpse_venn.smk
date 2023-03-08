rule mpse_venn:
    input:
        mpse_input()
    output:
        plot = expand(
            os.path.join(config["output"]["venn"], "plot/venn_upset.{outformat}"),
            outformat=["pdf", "svg", "png"])
    params:
        mpse_venn = os.path.join(WRAPPERS_DIR, "mpse_venn.R"),
        group = config["params"]["group"],
        method = config["params"]["import_from"],
        h = config["params"]["venn"]["plot"]["height"],
        w = config["params"]["venn"]["plot"]["width"],
        prefix = os.path.join(config["output"]["venn"], "plot/venn_upset")
    conda:
        config["envs"]["mpse"]
    shell:
        '''
        Rscript {params.mpse_venn} {params.method} \
        {input} \
        {params.group} \
        {params.h} {params.w} \
        {params.prefix}
        '''


rule mpse_venn_all:
    input:
        rules.mpse_venn.output
 