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
  readRDS(args$mpse)

  mpse %<>%
    MicrobiotaProcess:mp_rrarefy() %>% 
    MicrobiotaProcess:mp_cal_rarecurve(
      .abundance = RareAbundance, 
      chunks = chunks,
      action = "add")
 
  saveRDS(mpse, args$mpse_rarefied)
}


else if (args$plot) {
  readRDS(args$mpse_rarefied)

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

  ggsave(args$pdf, p, width = args$width, height = args$height)  
  ggsave(args$svg, p, width = args$width, height = args$height)  
  ggsave(args$png, p, width = args$width, height = args$height)  
}