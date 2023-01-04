#!/usr/bin/env Rscript

'MPSE import script

Usage:
  MPSE_import.R dada2 <metadatafile> <seqtabfile> <taxafile> <mpse_output>
  MPSE_import.R qiime2 <metadatafile> <otuqzafile> <taxaqzafile> <mpse_output>
  MPSE_import.R metaphlan <metadatafile> <profile> <mpse_output>
  MPSE_import.R (-h | --help)
  MPSE_import.R --version

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


args <- docopt::docopt(doc, version = 'MPSE import 0.1')

output <- FALSE

if (args$dada2) {
  mpse <- MicrobiotaProcess::mp_import_dada2(
    seqtab = readRDS(args$seqtabfile),
    taxa = readRDS(args$taxafile),
    sampleda = args$metadatafile)

  output <- TRUE
}

else if (args$qiime2) {
  mpse <- MicrobiotaProcess::mp_import_qiime2(
    otuqza = args$otuqzafile,
    taxaqza = args$taxaqzafile,
    mapfilename = args$metadatafile)

  output <- TRUE
} 

else if(args$metaphlan) {
  mpse <- MicrobiotaProcess::mp_import_metaphlan(
    profile = args$profile, 
    mapfilename = args$metadatafile)

  output = TRUE
}

else {
  stop("MPSE_import.R only support dada2, qiime2 and metaphlan as input")
  output = FALSE
}


if (output) {
  saveRDS(mpse, args$mpse_output)
}