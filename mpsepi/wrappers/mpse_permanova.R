#!/usr/bin/env Rscript

'mpse permanova script

Usage:
  mpse_permanova.R <distmethod> <mpse> <group> <tsv>
  mpse_permanova.R (-h | --help)
  mpse_permanova.R --version

Options:
  -h --help     Show this screen.
  --version     Show version.

' -> doc

library(magrittr)


args <- docopt::docopt(doc, version = 'mpse permanova v0.1')

mpse <- readRDS(args$mpse)

one_formula <- as.formula(stringr::str_c("~ ", args$group))

mpse %<>% 
  MicrobiotaProcess::mp_adonis(
    .abundance = hellinger,
    distmethod =  args$distmethod,
    .formula = one_formula,
    permutation = 9999,
    action = "add")

df <-
  mpse %>%
  MicrobiotaProcess::mp_extract_internal_attr(name = adonis) %>%
  MicrobiotaProcess::mp_fortify()

readr::write_tsv(df, args$tsv)
