def generate_multi_params(params_list, prefix):
    params = ""
    for i in params_list:
        if i != "":
            params = f"{params} {prefix} {i}"
    return params


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
            mpse_import = os.path.join(WRAPPERS_DIR, "mpse_import.R"),
            reftreefile = config["input"]["dada2"]["reftreefile"],
            min_abun = config["params"]["filter"]["min_abun"],
            min_prop = config["params"]["filter"]["min_prop"],
            filtered_phylum = generate_multi_params(config["params"]["filter"]["Phylum"], "-p"),
            filtered_class = generate_multi_params(config["params"]["filter"]["Class"], "-c"),
            filtered_order = generate_multi_params(config["params"]["filter"]["Order"], "-o"),
            filtered_family = generate_multi_params(config["params"]["filter"]["Family"], "-f"),
            filtered_genus = generate_multi_params(config["params"]["filter"]["Genus"], "-g"),
            filtered_otu = generate_multi_params(config["params"]["filter"]["OTU"], "-s")
        conda:
            config["envs"]["mpse"]
        shell:
            '''
            Rscript {params.mpse_import} dada2 \
            {input.metadatafile} \
            {input.seqtabfile} \
            {input.taxafile} \
            {params.reftreefile} \
            {output} \
            {params.min_abun} \
            {params.min_prop} \
            {params.filtered_phylum} \
            {params.filtered_class} \
            {params.filtered_order} \
            {params.filtered_family} \
            {params.filtered_genus} \
            {params.filtered_otu}
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
            mpse_import = os.path.join(WRAPPERS_DIR, "mpse_import.R"),
            treeqzafile = config["input"]["qiime2"]["treeqzafile"],
            min_abun = config["params"]["filter"]["min_abun"],
            min_prop = config["params"]["filter"]["min_prop"],
            filtered_phylum = generate_multi_params(config["params"]["filter"]["Phylum"], "-p"),
            filtered_class = generate_multi_params(config["params"]["filter"]["Class"], "-c"),
            filtered_order = generate_multi_params(config["params"]["filter"]["Order"], "-o"),
            filtered_family = generate_multi_params(config["params"]["filter"]["Family"], "-f"),
            filtered_genus = generate_multi_params(config["params"]["filter"]["Genus"], "-g"),
            filtered_otu = generate_multi_params(config["params"]["filter"]["OTU"], "-s")
        conda:
            config["envs"]["mpse"]
        shell:
            '''
            Rscript {params.mpse_import} qiime2 \
            {input.metadatafile} \
            {input.otuqzafile} \
            {input.taxaqzafile} \
            {params.treeqzafile} \
            {output} \
            {params.min_abun} \
            {params.min_prop} \
            {params.filtered_phylum} \
            {params.filtered_class} \
            {params.filtered_order} \
            {params.filtered_family} \
            {params.filtered_genus} \
            {params.filtered_otu}
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
            mpse_import = os.path.join(WRAPPERS_DIR, "mpse_import.R"),
            min_abun = config["params"]["filter"]["min_abun"],
            min_prop = config["params"]["filter"]["min_prop"],
            filtered_phylum = generate_multi_params(config["params"]["filter"]["Phylum"], "-p"),
            filtered_class = generate_multi_params(config["params"]["filter"]["Class"], "-c"),
            filtered_order = generate_multi_params(config["params"]["filter"]["Order"], "-o"),
            filtered_family = generate_multi_params(config["params"]["filter"]["Family"], "-f"),
            filtered_genus = generate_multi_params(config["params"]["filter"]["Genus"], "-g"),
            filtered_otu = generate_multi_params(config["params"]["filter"]["OTU"], "-s")
        conda:
            config["envs"]["mpse"]
        shell:
            '''
            Rscript {params.mpse_import} metaphlan \
            {input.metadatafile} \
            {input.profile} \
            {output} \
            {params.min_abun} \
            {params.min_prop} \
            {params.filtered_phylum} \
            {params.filtered_class} \
            {params.filtered_order} \
            {params.filtered_family} \
            {params.filtered_genus} \
            {params.filtered_otu}
            '''


rule mpse_import_all:
    input:
        os.path.join(config["output"]["import"], "mpse/mpse.rds")

