rule mpse_diff_zicoseq_cal:
    input:
        os.path.join(config["output"]["diff"], "mpse/mpse.rds")
    output:
        mpse = os.path.join(config["output"]["diff_zicoseq"], "mpse/mpse_zicoseq.rds"),
        lda_tsv = os.path.join(config["output"]["diff_zicoseq"], "mpse/lda.tsv")
    params:
        mpse_diff_zoceseq = os.path.join(WRAPPERS_DIR, "mpse_diff_zicoseq.R"),
        group = config["params"]["group"],
        method = config["params"]["import_from"]
    conda:
        config["envs"]["mpse"]
    shell:
        '''
        Rscript {params.mpse_diff_zoceseq} \
        cal \
        {params.method} \
        {params.group} \
        {input} \
        {output.mpse} \
        {output.lda_tsv}
        '''


rule mpse_diff_zicoseq_all:
    input:
        rules.mpse_diff_zicoseq_cal.output
