if config["params"]["import_from"] in ["dada2", "qiime2"]:

    print("Doing rarefy")

    rule mpse_rarefy:
        input:
            os.path.join(config["output"]["import"], "mpse/mpse.rds")
        output:
            os.path.join(config["output"]["rarefied"], "mpse/mpse_rarefied.rds")
        benchmark:
            os.path.join(config["output"]["rarefied"], "benchmark/mpse_rarefy_benchmark.txt")
        params:
            mpse_rarefy = os.path.join(WRAPPERS_DIR, "mpse_rarefy.R"),
            chunks = config["params"]["rarefy"]["chunks"]
        conda:
            config["envs"]["mpse"]
        shell:
            '''
            Rscript {params.mpse_rarefy} rarefy \
            {input} \
            {params.chunks} \ 
            {output} 
            '''


    rule mpse_rarefy_plot:
        input:
            os.path.join(config["output"]["rarefied"], "mpse/mpse_rarefied.rds")
        output:
            expand(os.path.join(
                config["output"]["rarefied"], "plot/mpse_rarefied.{outformat}"),
                outformat=["pdf", "svg", "png"])
        benchmark:
            os.path.join(config["output"]["rarefied"], "benchmark/mpse_rarefy_plot_benchmark.txt")
        params:
            mpse_rarefy = os.path.join(WRAPPERS_DIR, "mpse_rarefy.R"),
            group = config["params"]["group"],
            width = config["params"]["rarefy"]["plot"]["width"],
            height = config["params"]["rarefy"]["plot"]["height"]
        conda:
            config["envs"]["mpse"]
        shell:
            '''
            Rscript {params.mpse_rarefy} plot \
            {input} \
            {params.group} \
            {output[0]} {output[1]} {output[2]} \
            {params.width} {params.height}
            '''


    rule mpse_rarefy_all:
        input:
            os.path.join(config["output"]["rarefied"], "mpse/mpse_rarefied.rds"),
            expand(os.path.join(
                config["output"]["rarefied"], "plot/mpse_rarefied.{outformat}"),
                outformat=["pdf", "svg", "png"])

else:
    rule mpse_rarefy_all:
        input:

