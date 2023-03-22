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


    rule mpse_function_all:
        input:
            rules.mpse_function_import.output


else:
    rule mpse_function_all:
        input: