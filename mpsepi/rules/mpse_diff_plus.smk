rule mpse_diff_cal_plus:
    input:
        os.path.join(config["output"]["diversity_alpha"], "mpse/mpse.rds")
    output:
        tsv = os.path.join(config["output"]["diff_plus"], "mpse/{method}/diff.tsv")
    params:
        mpse_diff_plus = os.path.join(WRAPPERS_DIR, "mpse_diff_plus.R"),
        method = "{method}",
        formula = config["params"]["diff_plus"]["formula"],
    conda:
        config["envs"]["mpse"]
    shell:
        '''
        Rscript {params.mpse_diff_plus} \
        cal \
        {params.method} \
        "{params.formula}" \
        {input} \
        {output.tsv}
        '''


rule mpse_diff_cal_plus_all:
    input:
        expand(
            os.path.join(config["output"]["diff_plus"], "mpse/{method}/diff.tsv"),
            method=config["params"]["diff_plus"]["methods"])


rule mpse_diff_plus_all:
    input:
        rules.mpse_diff_cal_plus_all.input