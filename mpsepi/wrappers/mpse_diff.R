#!/usr/bin/env Rscript

'mpse diff script

Usage:
  mpse_diff.R cal <method> <group> <mpse> <mpse_output> <lda_tsv> <first_test_method> <first_test_alpha> <filter_p> <strict> <fc_method> <second_test_method> <second_test_alpha> <subcl_min> <subcl_test> <ml_method> <ldascore>
  mpse_diff.R plot tree <group> <mpse> <plot_prefix> <height> <width>
  mpse_diff.R plot cladogram <group> <mpse> <plot_prefix> <height> <width>
  mpse_diff.R plot box_bar <group> <mpse> <plot_prefix> <height> <width>
  mpse_diff.R plot mahattan <group> <mpse> <plot_prefix> <height> <width>
  mpse_diff.R (-h | --help)
  mpse_diff.R --version

Options:
  -h --help     Show this screen.
  --version     Show version.

' -> doc

# biomarker discovery

## mp_diff_analysis
## ggdiffbox
## ggdiffclade
## ggeffectsize
## ggdifftaxbar
## mp_plot_diff_res
## mp_plot_diff_cladogram
## ggtree
## ggtreeExtra


library(magrittr)


args <- docopt::docopt(doc, version = 'mpse diff v0.1')

mpse <- readRDS(args$mpse)

sign_group <- stringr::str_c("Sign_", args$group)

# cal
if (args$cal) {
  library(coin)

  if (args$method %in% c("dada2", "qiime2")) {
    mpse %<>%
      MicrobiotaProcess::mp_diff_analysis(
        .abundance = RelRareAbundanceBySample,
        .group = !!rlang::sym(args$group),
        first.test.method = args$first_test_method,
        first.test.alpha = as.numeric(args$first_test_alpha),
        filter.p = args$filter_p,
        strict = as.logical(args$strict),
        fc.method = args$fc_method,
        second.test.method = args$second_test_method,
        second.test.alpha = as.numeric(args$second_test_alpha),
        subcl.min = as.numeric(args$subcl_min),
        subcl.test = as.logical(args$subcl_test),
        ml.method = args$ml_method,
        action = "add",
        ldascore = as.numeric(args$ldascore)
    )
  } else if (args$method == "metaphlan") {
    mpse %<>%
      MicrobiotaProcess::mp_diff_analysis(
        .abundance = Abundance,
        .group = !!rlang::sym(args$group),
        first.test.method = args$first_test_method,
        first.test.alpha = as.numeric(args$first_test_alpha),
        filter.p = args$filter_p,
        strict = as.logical(args$strict),
        fc.method = args$fc_method,
        second.test.method = args$second_test_method,
        second.test.alpha = as.numeric(args$second_test_alpha),
        subcl.min = as.numeric(args$subcl_min),
        subcl.test = as.logical(args$subcl_test),
        ml.method = args$ml_method,
        ldascore = as.numeric(args$ldascore),
        action = "add",
        force = TRUE
    )
  }

  # lda table
  taxa_tree <-
    mpse %>%
    MicrobiotaProcess::mp_extract_tree(type = "taxatree")

  taxa_tree_lda <- 
    taxa_tree %>%
    dplyr::select(
      label, nodeClass, LDAupper, LDAmean, LDAlower,
      !!rlang::sym(sign_group), pvalue, fdr) %>%
    dplyr::filter(!is.na(fdr)) %>%
    dplyr::filter(!is.na(LDAmean))


  if (!dir.exists(dirname(args$lda_tsv))) {
    dir.create(dirname(args$lda_tsv), recursive = TRUE)
  }
  readr::write_tsv(taxa_tree_lda, args$lda_tsv)

  if (!dir.exists(dirname(args$mpse_output))) {
    dir.create(dirname(args$mpse_output), recursive = TRUE)
  }
  saveRDS(mpse, args$mpse_output)
}


# plot
if (args$plot) {
  library(ggtree)
  library(ggtreeExtra)
  library(ggplot2)
  library(MicrobiotaProcess)
  library(tidytree)
  library(ggstar)
  library(forcats)

  if (!dir.exists(dirname(args$plot_prefix))) {
    dir.create(dirname(args$plot_prefix), recursive = TRUE)
  }

  height <- as.numeric(args$height)
  width <- as.numeric(args$width)

  if (args$tree) {
    plot <- mpse %>%
      mp_plot_diff_res(
        group.abun = TRUE,
        pwidth.abun = 0.1
      )
  }

  if (args$cladogram) {
    plot <- mpse %>%
      mp_plot_diff_cladogram(
        label.size = 2.5,
        hilight.alpha = .3,
        bg.tree.size = .5,
        bg.point.size = 2,
        bg.point.stroke = .25
      ) +
      scale_fill_diff_cladogram(values = c('deepskyblue', 'orange')) +
      scale_size_continuous(range = c(1, 4))
  }

  if (args$box_bar) {
    f_box <- mpse %>%
      mp_plot_diff_boxplot(.group = !!rlang::sym(args$group)) %>%
      set_diff_boxplot_color(
        values = c("deepskyblue", "orange"),
        guide = guide_legend(title = NULL)
      )
    f_bar <- mpse %>%
      mp_plot_diff_boxplot(
        taxa.class = c(Genus, OTU),
        group.abun = TRUE,
        removeUnknown = TRUE
      ) %>%
      set_diff_boxplot_color(
        values = c("deepskyblue", "orange"),
        guide = guide_legend(title = NULL)
      )
    plot <- aplot::plot_list(f_box, f_bar)
  }

  if (args$mahattan) {
    plot <- mpse %>%
      mp_plot_diff_manhattan(
        .group = !!rlang::sym(sign_group),
        .y = fdr,
        .size = 2.4,
        taxa.class = c('OTU', 'Genus'),
        anno.taxa.class = Phylum
    )
  }

  ggsave(stringr::str_c(args$plot_prefix, ".pdf"), plot,
    height=height, width=width, limitsize = FALSE)

  ggsave(stringr::str_c(args$plot_prefix, ".svg"), plot,
    height=height, width=width, limitsize = FALSE)

  ggsave(stringr::str_c(args$plot_prefix, ".png"), plot,
    height=height, width=width, limitsize = FALSE)
}