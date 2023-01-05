#!/usr/bin/env Rscript

'mpse diversity alpha script

Usage:
  mpse_diversity_alpha.R <method> <mpse> <group> <alpha_tsv> <plot_pdf> <plot_svg> <plot_png> <width> <height> <image>
  mpse_diversity_alpha.R (-h | --help)
  mpse_diversity_alpha.R --version

Options:
  -h --help     Show this screen.
  --version     Show version.

' -> doc


library(magrittr)
library(ggplot2)
library(patchwork)


args <- docopt::docopt(doc, version = 'mpse diversity alpha v0.1')

readRDS(args$mpse)

if (args$method %in% c("qiime2", "dada2")) {
  mpse %<>% MicrobiotaProcess::mp_cal_alpha(.abundance = RareAbundance)

  f1 <- mpse %>%
    MicrobiotaProcess::mp_plot_alpha(
      .group = args$group, 
      .alpha = c(Observe, Chao1, ACE, Shannon, Simpson, Pielou))

  f2 <- mpse %>%
    MicrobiotaProcess::mp_plot_alpha(
      .alpha = c(Observe, Chao1, ACE, Shannon, Simpson, Pielou)

} else if (args$method == "metaphlan") {

  mpse %<>% MicrobiotaProcess::mp_cal_alpha(.abundance = Abundance)

  f1 <- mpse %>%
    MicrobiotaProcess::mp_plot_alpha(
      .group = args$group, 
      .alpha = c(Observe, Shannon, Simpson))

  f2 <- mpse %>%
    MicrobiotaProcess::mp_plot_alpha(
      .alpha = c(Observe, Shannon, Simpson)
}

alpha_df <- mpse %>% MicrobiotaProcess::mp_extract_sample()
readr::write_tsv(alpha_df, args$alpha_tsv)


f <- f1 / f2

ggsave(args$plot_pdf, f, width = args$width, height = args$height)
ggsave(args$plot_svg, f, width = args$width, height = args$height)
ggsave(args$plot_png, f, width = args$width, height = args$height)


save.image(args$image)