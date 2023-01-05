if config["params"]["import_from"] in ["dada2", "qiime2"]:

    rule mpse_rarefy:
        input:
            os.path.join(config["output"]["import"], "mpse/mpse.rds")
        output:
            os.path.join(config["output"]["rarefied"], "mpse/mpse_rarefied.rds")
        benchmark:
            os.path.join(config["output"]["import"], "benchmark/mpse_rarefy_benchmark.txt")
        params:
            chunks = config["params"]["rarefy"]["chunks"]
        conda:
            config["envs"]["mpse"]
        shell:
            '''
            Rscript ../mpse_rarefy.R rarefy \
            {input} \
            {params.chunks} \ 
            {output} 
            '''


    rule mpse_rarefy_plot:
        input:
            os.path.join(config["output"]["rarefied"], "mpse/mpse_rarefied.rds")
        output:
            expand(os.path.join(
                config["output"]["rarefied"], "plot/mpse_rarefied.{format}"),
                format=["pdf", "svg", "png"])
        benchmark:
            os.path.join(config["output"]["import"], "benchmark/mpse_rarefy_plot_benchmark.txt")
        params:
            group = config["params"]["group"],
            width = config["params"]["rarefy"]["width"],
            height = config["params"]["rarefy"]["height"]
        conda:
            config["envs"]["mpse"]
        shell:
            '''
            Rscript ../mpse_rarefy.R plot \
            {input} \
            {params.group} \
            {output[0]} {output[1]} {output[2]} \
            {params.width} {params.height}
            '''
