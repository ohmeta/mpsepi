#!/usr/bin/env python

'mpse composition script

Usage:
  mpse_composition.R <method> <taxa> <mpse> <group> <prefix> <h1> <w1> <h2> <w2> <h3> <w3>
  mpse_composition.R (-h | --help)
  mpse_composition.R --version

Options:
  -h --help     Show this screen.
  --version     Show version.

' -> doc


library(magrittr)
library(ggplot2)
library(patchwork)


args <- docopt::docopt(doc, version = 'mpse composition v0.1')

mpse <- readRDS(args$mpse)

if (args$method %in% c("dada2", "qiime2")) {
  mpse %<>%
    MicrobiotaProcess::mp_cal_abundance(
      .abundance = RareAbundance,
      add = TRUE
    ) %>%
    MicrobiotaProcess::mp_cal_abundance(
      .abundance = RareAbundance,
      .group = !!rlang::sym(args$group),
      add = TRUE
    )

  p1 <- mpse %>%
    MicrobiotaProcess::mp_plot_abundance(
      .abundance = RareAbundance,
      .group = !!rlang::sym(args$group), 
      taxa.class = !!rlang::sym(args$taxa), 
      topn = 20,
      relative = TRUE)

  p2 <- mpse %>%
    MicrobiotaProcess::mp_plot_abundance(
      .abundance = RareAbundance,
      .group = !!rlang::sym(args$group),
      taxa.class = Phylum,
      topn = 20,
      relative = FALSE)

  p_p <- p1 / p2

  f1 <- mpse %>%
    MicrobiotaProcess::mp_plot_abundance(
      .abundance = RareAbundance, 
      .group = !!rlang::sym(args$group),
      taxa.class = !!rlang::sym(args$taxa), 
      topn = 20,
      plot.group = TRUE)

  f2 <- mpse %>%
    MicrobiotaProcess::mp_plot_abundance(
      .abundance = RareAbundance,
      .group = !!rlang::sym(args$group),
      taxa.class = !!rlang::sym(args$taxa), 
      topn = 20,
      relative = FALSE,
      plot.group = TRUE)

  f_p <- f1 / f2

  h1 <- mpse %>%
    MicrobiotaProcess::mp_plot_abundance(
      .abundance = RareAbundance,
      .group = !!rlang::sym(args$group),
      taxa.class = !!rlang::sym(args$taxa), 
      relative = TRUE,
      topn = 20,
      geom = 'heatmap',
      #features.dist = 'euclidean',
      #features.hclust = 'average',
      sample.dist = 'bray',
      sample.hclust = 'average') 

  h2 <- mpse %>%
    MicrobiotaProcess::mp_plot_abundance(
      .abundance = RareAbundance,
      .group = !!rlang::sym(args$group),
      taxa.class = !!rlang::sym(args$taxa), 
      relative = FALSE,
      topn = 20,
      geom = 'heatmap',
      #features.dist = 'euclidean',
      #features.hclust = 'average',
      sample.dist = 'bray',
      sample.hclust = 'average')

  h_p <- aplot::plot_list(gglist=list(h1, h2), tag_levels="A")

} else if (args$method == "metaphlan") {

  mpse %<>%
    MicrobiotaProcess::mp_cal_abundance( # for each samples
      .abundance = Abundance,
      add = TRUE
    ) %>%
    MicrobiotaProcess::mp_cal_abundance( # for each groups 
      .abundance = Abundance,
      .group = !!rlang::sym(args$group),
      add = TRUE
    )

  p_p <- mpse %>%
    MicrobiotaProcess::mp_plot_abundance(
      .abundance = Abundance,
      .group = !!rlang::sym(args$group), 
      taxa.class = !!rlang::sym(args$taxa), 
      topn = 20,
      relative = TRUE,
      force = TRUE
    )

  f_p <- mpse %>%
    MicrobiotaProcess::mp_plot_abundance(
      .abundance = Abundance,
      .group = !!rlang::sym(args$group), 
      taxa.class = !!rlang::sym(args$taxa), 
      topn = 20,
      relative = TRUE,
      force = TRUE,
      plot.group = TRUE
    )

  h_p <- mpse %>%
    MicrobiotaProcess::mp_plot_abundance(
      .abundance = Abundance,
      .group = !!rlang::sym(args$group),
      taxa.class = !!rlang::sym(args$taxa), 
      relative = TRUE,
      force = TRUE,
      topn = 20,
      geom = 'heatmap',
      #features.dist = 'euclidean',
      #features.hclust = 'average',
      sample.dist = 'bray',
      sample.hclust = 'average'
    )
} 


if (!dir.exists(dirname(args$prefix))) {
  dir.create(dirname(args$prefix), recursive = TRUE)
}


h1 <- as.integer(args$h1)
w1 <- as.integer(args$w1)
h2 <- as.integer(args$h2)
w2 <- as.integer(args$w2)
h3 <- as.integer(args$h3)
w3 <- as.integer(args$w3)
 
## abun plot
ggsave(stringr::str_c(args$prefix, "abun.pdf"), p_p, height=h1, width=w1, limitsize = FALSE)
ggsave(stringr::str_c(args$prefix, "abun.svg"), p_p, height=h1, width=w1, limitsize = FALSE)
ggsave(stringr::str_c(args$prefix, "abun.png"), p_p, heigth=h1, width=w1, limitsize = FALSE)

## group plot
ggsave(stringr::str_c(args$prefix, "abun_group.pdf"), f_p, height=h2, width=w2, limitsize = FALSE)
ggsave(stringr::str_c(args$prefix, "abun_group.svg"), f_p, height=h2, width=w2, limitsize = FALSE)
ggsave(stringr::str_c(args$prefix, "abun_group.png"), f_p, height=h2, width=w2, limitsize = FALSE)

## heatmap plot
ggsave(stringr::str_c(args$prefix, "heatmap.pdf"), h_p, height=h3, width=w3, limitsize = FALSE)
ggsave(stringr::str_c(args$prefix, "heatmap.svg"), h_p, height=h3, width=w3, limitsize = FALSE)
ggsave(stringr::str_c(args$prefix, "heatmap.png"), h_p, height=h3, width=w3, limitsize = FALSE)