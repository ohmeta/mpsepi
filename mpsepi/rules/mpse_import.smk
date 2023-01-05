if config["params"]["import_from"] == "dada2":

    rule mpse_import_dada2:
        input:
            metadatafile = config["input"]["metadata"],
            seqtabfile = config["input"]["seqtabfile"],
            taxafile = config["input"]["taxafile"]
        output:
            os.path.join(config["output"]["import"], "mpse/mpse.rds")
        benchmark:
            os.path.join(config["output"]["import"], "benchmark/mpse_import_dada2_benchmark.txt")
        conda:
            config["envs"]["mpse"]
        shell:
            '''
            Rscript ../wrappers/mpse_import.R dada2 \
            {input.metadatafile} \
            {input.seqtabfile} \
            {input.taxafile} \
            {output}
            '''


elif config["params"]["import_from"] == "qiime2":

    rule mpse_import_qiime2:
        input:
            metadatafile = config["input"]["metadata"],
            otuqzafile = config["input"]["otuqzafile"],
            taxaqzafile = config["input"]["taxaqzafile"]
        output:
            os.path.join(config["output"]["import"], "mpse/mpse.rds")
        benchmark:
            os.path.join(config["output"]["import"], "benchmark/mpse_import_qiime2_benchmark.txt")
        conda:
            config["envs"]["mpse"]
        shell:
            '''
            Rscript ../wrappers/mpse_import.R qiime2 \
            {input.metadatafile} \
            {input.otuqzafile} \
            {input.taxaqzafile} \
            {output}
            '''


elif config["params"]["import_from"] == "metaphlan":

    rule mpse_import_metaphlan:
        input:
            metadatafile = config["input"]["metadata"],
            profile = config["input"]["profile"],
        output:
            os.path.join(config["output"]["import"], "mpse/mpse.rds")
        benchmark:
            os.path.join(config["output"]["import"], "benchmark/mpse_import_metaphlan_benchmark.txt")
        conda:
            config["envs"]["mpse"]
        shell:
            '''
            Rscript ../wrappers/mpse_import.R metaphlan \
            {input.metadatafile} \
            {input.profile} \
            {output}
            '''
