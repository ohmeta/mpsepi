#!/usr/bin/env Rscript

'mpse diff script

Usage:
  mpse_diff.R <method> <mpse> <group> <first_test_alpha> <lda_tsv> <tree_plot_prefix> <cladogram_plot_prefix> <box_bar_plot_prefix> <mahattan_plot_prefix> <image>
  mpse_diff.R (-h | --help)
  mpse_diff.R --version

Options:
  -h --help     Show this screen.
  --version     Show version.

' -> doc


library(ggtree)
library(ggtreeExtra)
library(ggplot2)
library(MicrobiotaProcess)
library(tidytree)
library(ggstar)
library(forcats)


args <- docopt::docopt(doc, version = 'mpse diff v0.1')

mpse <- readRDS(args$mpse)

if (args$method %in% c("dada2", "qiime2")) {
  mpse %<>%
    MicrobiotaProcess::mp_diff_analysis(
      .abundance = RelRareAbundanceBySample,
      .group = !!rlang::sym(args$group),
      first.test.alpha = args$first_test_alpha
  )
} else if (args$method == "metaphlan") {
  mpse %<>%
    MicrobiotaProcess::mp_diff_analysis(
      .abundance = Abundance,
      .group = !!rlang::sym(args$group),
      first.test.alpha = args$first_test_alpha,
      force = TRUE
  )
}


# lda table
taxa_tree <- mpse %>%
  mp_extract_tree(type = "taxatree")

sign_group <- stringr::str_c("Sign_", args$group)
taxa_tree_lda %>%
  taxa_tree %>%
  dplyr::select(label, nodeClass, LDAupper, LDAmean, LDAlower, sign_group, pvalue, fdr) %>%
  dplyr::filter(!is.na(fdr)) %>%
  dplyr::filter(!is.na(LDAmean))


if (!dir.exists(dirname(args$lda_tsv))) {
  dir.create(dirname(args$lda_tsv), recursive = TRUE)
}
readr::write_tsv(taxa_tree_lda, args$lda_tsv)


# plot
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
  mp_plot_diff_boxplot(.group = args$group) %>%
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
f_box_bar <- f_box + f_bar


f_mahattan <- mpse %>%
  mp_plot_diff_manhattan(
    .group = !!rlang::sym(sign_group),
    .y = fdr,
    .size = 2.4,
    taxa.class = c('OTU', 'Genus'),
    anno.taxa.class = Phylum
)


# save plot
t_prefix <- args$tree_plot_prefix
c_prefix <- args$cladogram_plot_prefix
b_prefix <- args$box_bar_plot_prefix
m_prefix <- args$mahattan_plot_prefix

if (!dir.exists(dirname(t_prefix))) {
  dir.create(dirname(t_prefix), recursive = TRUE)
}
if (!dir.exists(dirname(c_prefix))) {
  dir.create(dirname(c_prefix), recursive = TRUE)
}
if (!dir.exists(dirname(b_prefix))) {
  dir.create(dirname(b_prefix), recursive = TRUE)
}
if (!dir.exists(dirname(m_prefix))) {
  dir.create(dirname(m_prefix), recursive = TRUE)
}


ggsave(stringr::str_c(t_prefix, ".pdf"), p)
ggsave(stringr::str_c(t_prefix, ".svg"), p)
ggsave(stringr::str_c(t_prefix, ".png"), p)

ggsave(stringr::str_c(c_prefix, ".pdf"), f)
ggsave(stringr::str_c(c_prefix, ".svg"), f)
ggsave(stringr::str_c(c_prefix, ".png"), f)

ggsave(stringr::str_c(b_prefix, ".pdf"), f_box_bar)
ggsave(stringr::str_c(b_prefix, ".svg"), f_box_bar)
ggsave(stringr::str_c(b_prefix, ".png"), f_box_bar)

ggsave(stringr::str_c(m_prefix, ".pdf"), f_mahattan)
ggsave(stringr::str_c(m_prefix, ".svg"), f_mahattan)
ggsave(stringr::str_c(m_prefix, ".png"), f_mahattan)


if (!dir.exists(dirname(args$image))) {
  dir.create(dirname(args$image), recursive = TRUE)
}
save.image(args$image)