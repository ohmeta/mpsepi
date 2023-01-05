#!/usr/bin/env Rscript

'mpse rarefy script

Usage:
  mpse_rarefy.R rarefy <mpse> <chunks> <mpse_rarefied>
  mpse_rarefy.R plot <mpse_rarefied> <group> <plot_pdf> <plot_svg> <plot_png> <width> <height>
  mpse_rarefy.R (-h | --help)
  mpse_rarefy.R --version

Options:
  -h --help     Show this screen.
  --version     Show version.

' -> doc


library(magrittr)
library(patchwork)
library(ggplot2)


args <- docopt::docopt(doc, version = 'mpse rarefy v0.1')


if (args$rarefy) {
  mpse <- readRDS(args$mpse)

  mpse %<>%
    MicrobiotaProcess::mp_rrarefy() %>% 
    MicrobiotaProcess::mp_cal_rarecurve(
      .abundance = RareAbundance, 
      chunks = as.integer(args$chunks),
      action = "add")

  if (!dir.exists(dirname(args$mpse_rarefied))) {
    dir.create(dirname(args$mpse_rarefied), recursive = TRUE)
  }
  saveRDS(mpse, args$mpse_rarefied)

} else if (args$plot) {

  mpse <- readRDS(args$mpse_rarefied)

  p1 <- mpse %>%
    MicrobiotaProcess::mp_plot_rarecurve(
      .rare = RareAbundanceRarecurve, 
      .alpha = Observe)

  p2 <- mpse %>%
    MicrobiotaProcess::mp_plot_rarecurve(
      .rare = RareAbundanceRarecurve, 
      .alpha = Observe, 
      .group = args$group)

  p3 <- mpse %>% 
    MicrobiotaProcess::mp_plot_rarecurve(
      .rare = RareAbundanceRarecurve, 
      .alpha = "Observe", 
      .group = args$group, 
      plot.group = TRUE
  )

  p <- p1 + p2 + p3


  if (!dir.exists(dirname(args$plot_pdf))) {
    dir.create(dirname(args$plot_pdf), recursive = TRUE)
  }

  if (!dir.exists(dirname(args$plot_svg))) {
    dir.create(dirname(args$plot_svg), recursive = TRUE)
  }
 
  if (!dir.exists(dirname(args$plot_png)) {
    dir.create(dirname(args$plot_png), recursive = TRUE)
  }
 
  ggsave(args$plot_pdf, p, width = args$width, height = args$height)  
  ggsave(args$plot_svg, p, width = args$width, height = args$height)  
  ggsave(args$plot_png, p, width = args$width, height = args$height)  
}