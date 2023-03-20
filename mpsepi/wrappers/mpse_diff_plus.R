#!/usr/bin/env Rscript

'mpse diff plus script

Usage:
  mpse_diff_plus.R cal <method> <formula> <mpse> <tsv>
  mpse_diff_plus.R plot tree <group> <mpse> <plot_prefix> <height> <width>
  mpse_diff_plus.R plot cladogram <group> <mpse> <plot_prefix> <height> <width>
  mpse_diff_plus.R plot box_bar <group> <mpse> <plot_prefix> <height> <width>
  mpse_diff_plus.R plot mahattan <group> <mpse> <plot_prefix> <height> <width>
  mpse_diff_plus.R (-h | --help)
  mpse_diff_plus.R --version

Options:
  -h --help     Show this screen.
  --version     Show version.

' -> doc


library(magrittr)


args <- docopt::docopt(doc, version = 'mpse diff v0.1')

mpse <- readRDS(args$mpse)

one_formula <- as.formula(args$formula)


mpse %<>%
    tidybulk::test_differential_abundance(
        .abundance = Abundance,
        .method = args$method,
        .formula = one_formula)

diff_res <-
    mpse %>%
    MicrobiotaProcess::mp_extract_feature() #%>%
    #dplyr::filter(FDR <= .05 & abs(logFC) >= 2)


if (!dir.exists(dirname(args$tsv))) {
  dir.create(dirname(args$tsv), recursive = TRUE)
}
readr::write_tsv(diff_res, args$tsv)