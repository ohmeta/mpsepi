#!/usr/bin/env Rscript

'mpse diff script

Usage:
  mpse_diff.R cal <method> <group> <mpse> <mpse_output> <lda_tsv> <first_test_method> <first_test_alpha> <filter_p> <strict> <second_test_method> <second_test_alpha> <subcl_min> <subcl_test> <ml_method> <ldascore>
  mpse_diff.R plot <plot_outdir> <h1> <w1> <h2> <w2> <h3> <w3> <image>
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

  sign_group <- stringr::str_c("Sign_", args$group)
  taxa_tree_lda <- 
    taxa_tree %>%
    dplyr::select(label, nodeClass, LDAupper, LDAmean, LDAlower, !!rlang::sym(sign_group), pvalue, fdr) %>%
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


p <- mpse %>%
  mp_plot_diff_res(
    group.abun = TRUE,
    pwidth.abun = 0.1
  )


f <- mpse %>%
  mp_plot_diff_cladogram(
    label.size = 2.5,
    hilight.alpha = .3,
    bg.tree.size = .5,
    bg.point.size = 2,
    bg.point.stroke = .25
  ) +
  scale_fill_diff_cladogram(values = c('deepskyblue', 'orange')) +
  scale_size_continuous(range = c(1, 4))


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
#f_box_bar <- f_box + f_bar
f_box_bar <- aplot::plot_list(f_box, f_bar)


#f_mahattan <- mpse %>%
#  mp_plot_diff_manhattan(
#    .group = !!rlang::sym(sign_group),
#    .y = fdr,
#    .size = 2.4,
#    taxa.class = c('OTU', 'Genus'),
#    anno.taxa.class = Phylum
#)


# save plot
t_prefix <- args$tree_plot_prefix
c_prefix <- args$cladogram_plot_prefix
b_prefix <- args$box_bar_plot_prefix
#m_prefix <- args$mahattan_plot_prefix

if (!dir.exists(dirname(t_prefix))) {
  dir.create(dirname(t_prefix), recursive = TRUE)
}
if (!dir.exists(dirname(c_prefix))) {
  dir.create(dirname(c_prefix), recursive = TRUE)
}
if (!dir.exists(dirname(b_prefix))) {
  dir.create(dirname(b_prefix), recursive = TRUE)
}
#if (!dir.exists(dirname(m_prefix))) {
#  dir.create(dirname(m_prefix), recursive = TRUE)
#}

h1 <- as.numeric(args$h1)
w1 <- as.numeric(args$w1)
h2 <- as.numeric(args$h2)
w2 <- as.numeric(args$w2)
h3 <- as.numeric(args$h3)
w3 <- as.numeric(args$w3)

ggsave(stringr::str_c(t_prefix, ".pdf"), p, height=h1, width=w1, limitsize = FALSE)
ggsave(stringr::str_c(t_prefix, ".svg"), p, height=h1, width=w1, limitsize = FALSE)
ggsave(stringr::str_c(t_prefix, ".png"), p, height=h1, width=w1, limitsize = FALSE)

ggsave(stringr::str_c(c_prefix, ".pdf"), f, height=h2, width=w2, limitsize = FALSE)
ggsave(stringr::str_c(c_prefix, ".svg"), f, height=h2, width=w2, limitsize = FALSE)
ggsave(stringr::str_c(c_prefix, ".png"), f, height=h2, width=w2, limitsize = FALSE)

ggsave(stringr::str_c(b_prefix, ".pdf"), f_box_bar, height=h3, width=w3, limitsize = FALSE)
ggsave(stringr::str_c(b_prefix, ".svg"), f_box_bar, height=h3, width=w3, limitsize = FALSE)
ggsave(stringr::str_c(b_prefix, ".png"), f_box_bar, height=h3, width=w3, limitsize = FALSE)

#ggsave(stringr::str_c(m_prefix, ".pdf"), f_mahattan, height=args$h4, width=args$w4, limitsize = FALSE)
#ggsave(stringr::str_c(m_prefix, ".svg"), f_mahattan, height=args$h4, width=args$w4, limitsize = FALSE)
#ggsave(stringr::str_c(m_prefix, ".png"), f_mahattan, height=args$h4, width=args$w4, limitsize = FALSE)
}