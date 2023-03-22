#!/usr/bin/env Rscript

'mpse function script

Usage:
  mpse_function.R import <metafile> <funcfile> <mpse_output>
  mpse_function.R abundance cal <group> <mpse> <mpse_output>
  mpse_function.R abundance plot <group> <mpse> <plot_prefix> <h1> <w1> <h2> <w2> <h3> <w3>
  mpse_function.R enrichment cal <group> <mpse> <mpse_output> <enrichment_output>
  mpse_function.R enrichment plot <group> <mpse> <plot_prefix> <height> <width>
  mpse_function.R (-h | --help)
  mpse_function.R --version

Options:
  -h --help     Show this screen.
  --version     Show version.

' -> doc


# picrust2 reference
# https://github.com/picrust/picrust2/wiki/Full-pipeline-script

# EC_metagenome_out: Folder
## pred_metagenome_unstrat.tsv.gz: unstratified EC number metagenome predictions
## seqtab_norm.tsv.gz: sequence table normalized by predicted 16S copy number abundances
## weighted_nsti.tsv.gz: the per-sample NSTI values weighted by the abundance of each ASV 

# KO_metagenome_out: As EC_metagenome_out above, but for KO metagenomes

# path_metagenome_out: Folder containing predicted pathway abundances and coverages per-sample, based on predicted EC number abundances


library(magrittr)


args <- docopt::docopt(doc, version = 'mpse function v0.1')


if (args$import) {

  metadata_df <- readr::read_tsv(args$metafile)

  func_df <- readr::read_tsv(args$funcfile)
  func_df %<>% tibble::column_to_rownames(colnames(func_df)[1])

  mpse <- MicrobiotaProcess::MPSE(assays = list(Abundance = func_df))
  mpse %<>% dplyr::left_join(metadata_df, by=c("Sample" = "sample_name"))

  if (!dir.exists(dirname(args$mpse_output))) {
    dir.create(dirname(args$mpse_output), recursive = TRUE)
  }
  saveRDS(mpse, args$mpse_output)
}


if (args$abundance) {

  mpse <- readRDS(args$mpse)

  if (args$cal) {
    mpse %<>%
      MicrobiotaProcess::mp_cal_abundance(
        .abundance = Abundance,
        force = TRUE,
        add = TRUE
      ) %>%
      MicrobiotaProcess::mp_cal_abundance(
        .abundance = Abundance,
        .group = !!rlang::sym(args$group),
        force = TRUE,
        add = TRUE
      )
  
    if (!dir.exists(dirname(args$mpse_output))) {
      dir.create(dirname(args$mpse_output), recursive = TRUE)
    }
    saveRDS(mpse, args$mpse_output)
  }

  if (args$plot) {
    library(ggplot2)

    p_p <- mpse %>%
      MicrobiotaProcess::mp_plot_abundance(
        .abundance = Abundance,
        .group = !!rlang::sym(args$group), 
        #taxa.class = !!rlang::sym(args$taxa), 
        topn = 20,
        relative = FALSE,
        force = TRUE
      )

    f_p <- mpse %>%
      MicrobiotaProcess::mp_plot_abundance(
        .abundance = Abundance,
        .group = !!rlang::sym(args$group), 
        #taxa.class = !!rlang::sym(args$taxa), 
        topn = 20,
        relative = FALSE,
        force = TRUE,
        plot.group = TRUE
      )

    h_p <- mpse %>%
      MicrobiotaProcess::mp_plot_abundance(
        .abundance = Abundance,
        .group = !!rlang::sym(args$group),
        #taxa.class = !!rlang::sym(args$taxa), 
        relative = FALSE,
        force = TRUE,
        topn = 20,
        geom = 'heatmap',
        #features.dist = 'euclidean',
        #features.hclust = 'average',
        sample.dist = 'bray',
        sample.hclust = 'average'
      )

    if (!dir.exists(dirname(args$plot_prefix))) {
      dir.create(dirname(args$plot_prefix), recursive = TRUE)
    }

    h1 <- as.numeric(args$h1)
    w1 <- as.numeric(args$w1)
    h2 <- as.numeric(args$h2)
    w2 <- as.numeric(args$w2)
    h3 <- as.numeric(args$h3)
    w3 <- as.numeric(args$w3)
    
    ## abun plot
    ggsave(stringr::str_c(args$plot_prefix, "_abun.pdf"), p_p, height=h1, width=w1, limitsize = FALSE)
    ggsave(stringr::str_c(args$plot_prefix, "_abun.svg"), p_p, height=h1, width=w1, limitsize = FALSE)
    ggsave(stringr::str_c(args$plot_prefix, "_abun.png"), p_p, height=h1, width=w1, limitsize = FALSE)

    ## group plot
    ggsave(stringr::str_c(args$plot_prefix, "_abun_group.pdf"), f_p, height=h2, width=w2, limitsize = FALSE)
    ggsave(stringr::str_c(args$plot_prefix, "_abun_group.svg"), f_p, height=h2, width=w2, limitsize = FALSE)
    ggsave(stringr::str_c(args$plot_prefix, "_abun_group.png"), f_p, height=h2, width=w2, limitsize = FALSE)

    ## heatmap plot
    ggsave(stringr::str_c(args$plot_prefix, "_heatmap.pdf"), h_p, height=h3, width=w3, limitsize = FALSE)
    ggsave(stringr::str_c(args$plot_prefix, "_heatmap.svg"), h_p, height=h3, width=w3, limitsize = FALSE)
    ggsave(stringr::str_c(args$plot_prefix, "_heatmap.png"), h_p, height=h3, width=w3, limitsize = FALSE)
  }
}


if (args$enrichment) {

  mpse <- readRDS(args$mpse)

  sign_group <- stringr::str_c("Sign_", args$group)

  if (args$cal) {
    mpse %<>%
      MicrobiotaProcess::mp_diff_analysis(
       .abundance = Abundance,
       force = TRUE,
       relative = FALSE,
       .group = !!rlang::sym(args$group),
       filter.p = "pvalue"
      )

    # perform KEGG pathway analysis with clusterProfiler and MicrobiomeProfiler
    one_formula <- as.formula(stringr::str_c("OTU ~ ", sign_group))
    mpse_enrichment <-
      mpse %>%
      MicrobiotaProcess::mp_extract_feature() %>%
      dplyr::filter(!is.na(!!rlang::sym(sign_group))) %>% 
      clusterProfiler::compareCluster(
        one_formula,
        data = .,
        fun = MicrobiomeProfiler::enrichKO
      )

    if (!dir.exists(dirname(args$mpse_output))) {
      dir.create(dirname(args$mpse_output), recursive = TRUE)
    }
    saveRDS(mpse, args$mpse_output)

    if (!dir.exists(dirname(args$enrichment_output))) {
      dir.create(dirname(args$enrichment_output), recursive = TRUE)
    }
    saveRDS(mpse_enrichment, args$enrichment_output)
  }

}