if config["params"]["import_from"] == "dada2":

    rule mpse_import_dada2:
        input:
            metadatafile = config["input"]["metadata"],
            seqtabfile = config["input"]["dada2"]["seqtabfile"],
            taxafile = config["input"]["dada2"]["taxafile"]
        output:
            os.path.join(config["output"]["import"], "mpse/mpse.rds")
        benchmark:
            os.path.join(config["output"]["import"], "benchmark/mpse_import_dada2_benchmark.txt")
        params:
            mpse_import = os.path.join(WRAPPERS_DIR, "mpse_import.R")
        conda:
            config["envs"]["mpse"]
        shell:
            '''
            Rscript {params.mpse_import} dada2 \
            {input.metadatafile} \
            {input.seqtabfile} \
            {input.taxafile} \
            {output}
            '''


elif config["params"]["import_from"] == "qiime2":

    rule mpse_import_qiime2:
        input:
            metadatafile = config["input"]["metadata"],
            otuqzafile = config["input"]["qiime2"]["otuqzafile"],
            taxaqzafile = config["input"]["qiime2"]["taxaqzafile"]
        output:
            os.path.join(config["output"]["import"], "mpse/mpse.rds")
        benchmark:
            os.path.join(config["output"]["import"], "benchmark/mpse_import_qiime2_benchmark.txt")
        params:
            mpse_import = os.path.join(WRAPPERS_DIR, "mpse_import.R")
        conda:
            config["envs"]["mpse"]
        shell:
            '''
            Rscript {params.mpse_import} qiime2 \
            {input.metadatafile} \
            {input.otuqzafile} \
            {input.taxaqzafile} \
            {output}
            '''


elif config["params"]["import_from"] == "metaphlan":

    rule mpse_import_metaphlan:
        input:
            metadatafile = config["input"]["metadata"],
            profile = config["input"]["metaphlan2"]["profile"],
        output:
            os.path.join(config["output"]["import"], "mpse/mpse.rds")
        benchmark:
            os.path.join(config["output"]["import"], "benchmark/mpse_import_metaphlan_benchmark.txt")
        params:
            mpse_import = os.path.join(WRAPPERS_DIR, "mpse_import.R")
        conda:
            config["envs"]["mpse"]
        shell:
            '''
            Rscript {params.mpse_import} metaphlan \
            {input.metadatafile} \
            {input.profile} \
            {output}
            '''


rule mpse_import_all:
    input:
        os.path.join(config["output"]["import"], "mpse/mpse.rds")

