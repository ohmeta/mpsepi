#!/usr/bin/env Rscript

'mpse import script

Usage:
  mpse_import.R dada2 <metadatafile> <seqtabfile> <taxafile> <mpse_output>
  mpse_import.R qiime2 <metadatafile> <otuqzafile> <taxaqzafile> <mpse_output>
  mpse_import.R metaphlan <metadatafile> <profile> <mpse_output>
  mpse_import.R (-h | --help)
  mpse_import.R --version

Options:
  -h --help     Show this screen.
  --version     Show version.

' -> doc


# MPSE structure
#mpse <- MPSE(
#    assays  = assaysda,
#    colData = sampleda,
#    otutree = otutree,
#    refseq  = refseq,
#    taxatree = taxatree
#)


library(magrittr)


args <- docopt::docopt(doc, version = 'mpse import v0.1')

output <- FALSE

if (args$dada2) {
  mpse <- MicrobiotaProcess::mp_import_dada2(
    seqtab = readRDS(args$seqtabfile),
    taxa = readRDS(args$taxafile),
    sampleda = args$metadatafile)

  output <- TRUE

} else if (args$qiime2) {

  mpse <- MicrobiotaProcess::mp_import_qiime2(
    otuqza = args$otuqzafile,
    taxaqza = args$taxaqzafile,
    mapfilename = args$metadatafile)

  output <- TRUE

} else if(args$metaphlan) {

  mpse <- MicrobiotaProcess::mp_import_metaphlan(
    profile = args$profile, 
    mapfilename = args$metadatafile)

  output <- TRUE

} else {

  stop("mpse_import.R only support dada2, qiime2 and metaphlan as input")
  output <- FALSE
}

if (output) {
  if (!dir.exists(dirname(args$mpse_output))) {
    dir.create(dirname(args$mpse_output), recursive = TRUE)
  }
  saveRDS(mpse, args$mpse_output)
}