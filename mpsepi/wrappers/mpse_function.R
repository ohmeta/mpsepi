#!/usr/bin/env Rscript

'mpse function script

Usage:
  mpse_function.R import <metafile> <funcfile> <mpse_output>
  mpse_function.R plot tree <group> <mpse> <plot_prefix> <height> <width>
  mpse_function.R plot cladogram <group> <mpse> <plot_prefix> <height> <width>
  mpse_function.R plot box_bar <group> <mpse> <plot_prefix> <height> <width>
  mpse_function.R plot mahattan <group> <mpse> <plot_prefix> <height> <width>
  mpse_function.R (-h | --help)
  mpse_function.R --version

Options:
  -h --help     Show this screen.
  --version     Show version.

' -> doc


# picrust2 reference
# https://github.com/picrust/picrust2/wiki/Full-pipeline-script

# EC_metagenome_out: Folder
## pred_metagenome_unstrat.tsv.gz: unstratified EC number metagenome predictions
## seqtab_norm.tsv.gz: sequence table normalized by predicted 16S copy number abundances
## weighted_nsti.tsv.gz: the per-sample NSTI values weighted by the abundance of each ASV 

# KO_metagenome_out: As EC_metagenome_out above, but for KO metagenomes

# path_metagenome_out: Folder containing predicted pathway abundances and coverages per-sample, based on predicted EC number abundances


library(magrittr)


args <- docopt::docopt(doc, version = 'mpse function v0.1')


if (args$import) {

  metadata_df <- readr::read_tsv(args$metafile)

  func_df <- readr::read_tsv(args$funcfile)
  func_df %<>% tibble::column_to_rownames(colnames(func_df)[1])

  mpse <- MicrobiotaProcess::MPSE(assays = list(Abundance = func_df))
  mpse %<>% dplyr::left_join(metadata_df, by=c("Sample" = "sample_name"))

  if (!dir.exists(dirname(args$mpse_output))) {
    dir.create(dirname(args$mpse_output), recursive = TRUE)
  }
  saveRDS(mpse, args$mpse_output)
}
