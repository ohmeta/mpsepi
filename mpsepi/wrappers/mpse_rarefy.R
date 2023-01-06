#!/usr/bin/env Rscript

'mpse rarefy script

Usage:
  mpse_rarefy.R rarefy <mpse> <chunks> <mpse_rarefied> [-f samples...]
  mpse_rarefy.R plot <mpse_rarefied> <group> <plot_pdf> <plot_svg> <plot_png> <width> <height>
  mpse_rarefy.R (-h | --help)
  mpse_rarefy.R --version

Options:
  -f=samples    Samples [default: ""]
  -h --help     Show this screen.
  --version     Show version.

' -> doc


library(magrittr)
library(patchwork)
library(ggplot2)
library(MicrobiotaProcess)

args <- docopt::docopt(doc, version = 'mpse rarefy v0.1')


if (args$rarefy) {
  mpse <- readRDS(args$mpse)

  # check the abundance distribution, be careful to control sample sample, remove low-quality samples
  print(mpse %>% mp_extract_assays(.abundance=Abundance) %>% colSums() %>% sort())

  print(args$f)

  saved_samples_list <- setdiff(colnames(mpse), args$f)

  mpse <- mpse[, saved_samples_list]

  mpse %<>%
    MicrobiotaProcess::mp_rrarefy()

  mpse %<>%
    MicrobiotaProcess::mp_cal_rarecurve(
      .abundance = RareAbundance, 
      chunks = as.integer(args$chunks),
      add = TRUE)

  #mpse %<>%
  #  MicrobiotaProcess::mp_cal_rarecurve(
  #    .abundance = Abundance, 
  #    chunks = as.integer(args$chunks),
  #    force = TRUE,
  #    add = TRUE)

  if (!dir.exists(dirname(args$mpse_rarefied))) {
    dir.create(dirname(args$mpse_rarefied), recursive = TRUE)
  }
  saveRDS(mpse, args$mpse_rarefied)

} else if (args$plot) {

  mpse <- readRDS(args$mpse_rarefied)

  p1 <- mpse %>%
    MicrobiotaProcess::mp_plot_rarecurve(
      .rare = RareAbundanceRarecurve, 
      .alpha = Observe
  )

  p2 <- mpse %>%
    MicrobiotaProcess::mp_plot_rarecurve(
      .rare = RareAbundanceRarecurve, 
      .alpha = Observe, 
      .group = !!rlang::sym(args$group)
  )

  p3 <- mpse %>% 
    MicrobiotaProcess::mp_plot_rarecurve(
      .rare = RareAbundanceRarecurve, 
      .alpha = Observe, 
      .group = !!rlang::sym(args$group),
      plot.group = TRUE
  )

  p <- p1 + p2 + p3


  if (!dir.exists(dirname(args$plot_pdf))) {
    dir.create(dirname(args$plot_pdf), recursive = TRUE)
  }

  if (!dir.exists(dirname(args$plot_svg))) {
    dir.create(dirname(args$plot_svg), recursive = TRUE)
  }
 
  if (!dir.exists(dirname(args$plot_png))) {
    dir.create(dirname(args$plot_png), recursive = TRUE)
  }

  width <- as.numeric(args$width)
  height <- as.numeric(args$height)

  ggsave(args$plot_pdf, p, width = width, height = height)  
  ggsave(args$plot_svg, p, width = width, height = height)  
  ggsave(args$plot_png, p, width = width, height = height)  
}