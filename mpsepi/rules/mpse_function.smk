if config["params"]["function"]["do"]:
    rule mpse_function_import:
        input:
            metadatafile = config["input"]["metadata"],
            ecprofile = config["input"]["picrust2"]["ecprofile"],
            koprofile = config["input"]["picrust2"]["koprofile"],
            pathprofile = config["input"]["picrust2"]["pathprofile"]
        output:
            mpse_ec = os.path.join(config["output"]["function"], "mpse/mpse_ec.rds"),
            mpse_ko = os.path.join(config["output"]["function"], "mpse/mpse_ko.rds"),
            mpse_path = os.path.join(config["output"]["function"], "mpse/mpse_path.rds")
        params:
            mpse_function = os.path.join(WRAPPERS_DIR, "mpse_function.R")
        conda:
            config["envs"]["mpse"]
        shell:
            '''
            Rscript {params.mpse_function} \
            import {input.metadatafile} {input.ecprofile} {output.mpse_ec}
            
            Rscript {params.mpse_function} \
            import {input.metadatafile} {input.koprofile} {output.mpse_ko}
 
            Rscript {params.mpse_function} \
            import {input.metadatafile} {input.pathprofile} {output.mpse_path}
            '''


    rule mpse_function_abundance_cal:
        input:
            mpse_ec = os.path.join(config["output"]["function"], "mpse/mpse_ec.rds"),
            mpse_ko = os.path.join(config["output"]["function"], "mpse/mpse_ko.rds"),
            mpse_path = os.path.join(config["output"]["function"], "mpse/mpse_path.rds")
        output:
            mpse_ec = os.path.join(config["output"]["function"], "mpse/mpse_ec_caled.rds"),
            mpse_ko = os.path.join(config["output"]["function"], "mpse/mpse_ko_caled.rds"),
            mpse_path = os.path.join(config["output"]["function"], "mpse/mpse_path_caled.rds")
        params:
            mpse_function = os.path.join(WRAPPERS_DIR, "mpse_function.R"),
            group = config["params"]["group"]
        conda:
            config["envs"]["mpse"]
        shell:
            '''
            Rscript {params.mpse_function} \
            abundance cal {params.group} {input.mpse_ec} {output.mpse_ec}
            
            Rscript {params.mpse_function} \
            abundance cal {params.group} {input.mpse_ko} {output.mpse_ko}
 
            Rscript {params.mpse_function} \
            abundance cal {params.group} {input.mpse_path} {output.mpse_path}
            '''


    rule mpse_function_abundance_plot:
        input:
            mpse_ec = os.path.join(config["output"]["function"], "mpse/mpse_ec_caled.rds"),
            mpse_ko = os.path.join(config["output"]["function"], "mpse/mpse_ko_caled.rds"),
            mpse_path = os.path.join(config["output"]["function"], "mpse/mpse_path_caled.rds")
        output:
            expand(
                os.path.join(config["output"]["function"], "plot/abundance/{func}_{target}.{outformat}"),
                func=["ec", "ko", "path"],
                #target=["abun", "abun_group", "heatmap"],
                target=["abun", "heatmap"],
                outformat=["pdf", "svg", "png"]
            )
        params:
            mpse_function = os.path.join(WRAPPERS_DIR, "mpse_function.R"),
            group = config["params"]["group"],
            plot_prefix_ec = os.path.join(config["output"]["function"], "plot/abundance/ec"),
            plot_prefix_ko = os.path.join(config["output"]["function"], "plot/abundance/ko"),
            plot_prefix_path = os.path.join(config["output"]["function"], "plot/abundance/path"),
            ec_h1 = config["params"]["function"]["abundance"]["plot"]["abundance"]["ec"]["height"],
            ec_w1 = config["params"]["function"]["abundance"]["plot"]["abundance"]["ec"]["width"],
            #ec_h2 = config["params"]["function"]["abundance"]["plot"]["abundance_group"]["ec"]["height"],
            #ec_w2 = config["params"]["function"]["abundance"]["plot"]["abundance_group"]["ec"]["width"],
            ec_h3 = config["params"]["function"]["abundance"]["plot"]["heatmap"]["ec"]["height"],
            ec_w3 = config["params"]["function"]["abundance"]["plot"]["heatmap"]["ec"]["width"],
            ko_h1 = config["params"]["function"]["abundance"]["plot"]["abundance"]["ko"]["height"],
            ko_w1 = config["params"]["function"]["abundance"]["plot"]["abundance"]["ko"]["width"],
            #ko_h2 = config["params"]["function"]["abundance"]["plot"]["abundance_group"]["ko"]["height"],
            #ko_w2 = config["params"]["function"]["abundance"]["plot"]["abundance_group"]["ko"]["width"],
            ko_h3 = config["params"]["function"]["abundance"]["plot"]["heatmap"]["ko"]["height"],
            ko_w3 = config["params"]["function"]["abundance"]["plot"]["heatmap"]["ko"]["width"],
            path_h1 = config["params"]["function"]["abundance"]["plot"]["abundance"]["path"]["height"],
            path_w1 = config["params"]["function"]["abundance"]["plot"]["abundance"]["path"]["width"],
            #path_h2 = config["params"]["function"]["abundance"]["plot"]["abundance_group"]["path"]["height"],
            #path_w2 = config["params"]["function"]["abundance"]["plot"]["abundance_group"]["path"]["width"],
            path_h3 = config["params"]["function"]["abundance"]["plot"]["heatmap"]["path"]["height"],
            path_w3 = config["params"]["function"]["abundance"]["plot"]["heatmap"]["path"]["width"]
        conda:
            config["envs"]["mpse"]
        shell:
            '''
            Rscript {params.mpse_function} \
            abundance plot \
            {params.group} \
            {input.mpse_ec} \
            {params.plot_prefix_ec} \
            {params.ec_h1} \
            {params.ec_w1} \
            {params.ec_h3} \
            {params.ec_w3}

            Rscript {params.mpse_function} \
            abundance plot \
            {params.group} \
            {input.mpse_ko} \
            {params.plot_prefix_ko} \
            {params.ko_h1} \
            {params.ko_w1} \
            {params.ko_h3} \
            {params.ko_w3}

            Rscript {params.mpse_function} \
            abundance plot \
            {params.group} \
            {input.mpse_path} \
            {params.plot_prefix_path} \
            {params.path_h1} \
            {params.path_w1} \
            {params.path_h3} \
            {params.path_w3}
            '''
 

    rule mpse_function_all:
        input:
            rules.mpse_function_import.output,
            rules.mpse_function_abundance_cal.output,
            rules.mpse_function_abundance_plot.output            


else:
    rule mpse_function_all:
        input: