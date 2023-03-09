#!/usr/bin/env Rscript

'mpse diversity phylogenetic script

Usage:
  mpse_diversity_phylogenetic.R <method> <mpse> <group> <plot_prefix> <width> <height>
  mpse_diversity_phylogenetic.R (-h | --help)
  mpse_diversity_phylogenetic.R --version

Options:
  -h --help     Show this screen.
  --version     Show version.

' -> doc


library(magrittr)
library(ggplot2)
library(patchwork)


args <- docopt::docopt(doc, version = 'mpse diversity phylogenetic v0.1')

mpse <- readRDS(args$mpse)

if (args$method %in% c("qiime2", "dada2")) {
  mpse %<>%
    MicrobiotaProcess::mp_cal_pd_metric(
      .abundance = RareAbundance,
      metric = all
    )
} else if (args$method == "metaphlan") {
  mpse %<>%
    MicrobiotaProcess::mp_cal_pd_metric(
      .abundance = Abundance,
      metric = all
    )
}

p_pd_alpha <-
  mpse %>%
      MicrobiotaProcess::mp_plot_alpha(
         .alpha = c("PAE", "NRI", "NTI", "PD", "HAED", "EAED", "IAC"),
         .group = !!rlang::sym(args$group), 
      ) +
      #scale_fill_manual(values=cols)+
      #scale_color_manual(values=cols) +
      theme(legend.position="none",
            strip.background = element_rect(colour=NA, fill="grey"))


if (!dir.exists(dirname(args$plot_prefix))) {
  dir.create(dirname(args$plot_prefix), recursive = TRUE)
}

width <- as.numeric(args$width)
height <- as.numeric(args$height)

ggsave(stringr::str_c(args$plot_prefix, ".pdf"), p_pd_alpha,
    width = width, height = height, limitsize = FALSE)

ggsave(stringr::str_c(args$plot_prefix, ".svg"), p_pd_alpha,
    width = width, height = height, limitsize = FALSE)

ggsave(stringr::str_c(args$plot_prefix, ".png"), p_pd_alpha,
    width = width, height = height, limitsize = FALSE)