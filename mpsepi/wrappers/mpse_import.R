#!/usr/bin/env Rscript

'mpse import script

Usage:
  mpse_import.R dada2 <metadatafile> <seqtabfile> <taxafile> <reftreefile> <mpse_output> <min_abun> <min_prop> [-p phylum...] [-c class...] [-o order...] [-f family...] [-g genus...] [-s OTU...]
  mpse_import.R qiime2 <metadatafile> <otuqzafile> <taxaqzafile> <treeqzafile> <mpse_output> <min_abun> <min_prop> [-p phylum...] [-c class...] [-o order...] [-f family...] [-g genus...] [-s OTU...]
  mpse_import.R metaphlan <metadatafile> <profile> <mpse_output> <min_abun> <min_prop> [-p phylum...] [-c class...] [-o order...] [-f family...] [-g genus...] [-s OTU...]

  -p=phylum     Phylum [default: ""]
  -c=class      Class  [default: ""]
  -o=order      Order  [default: ""]
  -f=family     Family [default: ""]
  -g=genus      Genus  [default: ""]
  -s=OTU        OTU    [default: ""]
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
  if (file.exists(args$reftreefile)) {
    mpse <- MicrobiotaProcess::mp_import_dada2(
      seqtab = readRDS(args$seqtabfile),
      taxa = readRDS(args$taxafile),
      sampleda = args$metadatafile,
      reftree = args$reftreefile
    )
 }
  else {
    mpse <- MicrobiotaProcess::mp_import_dada2(
      seqtab = readRDS(args$seqtabfile),
      taxa = readRDS(args$taxafile),
      sampleda = args$metadatafile
    )
  }
  output <- TRUE

} else if (args$qiime2) {
  if (file.exists(args$treeqzafile)) {
    mpse <- MicrobiotaProcess::mp_import_qiime2(
      otuqza = args$otuqzafile,
      taxaqza = args$taxaqzafile,
      mapfilename = args$metadatafile,
      treeqza = args$treeqzafile 
    )
  }
  else {
    mpse <- MicrobiotaProcess::mp_import_qiime2(
      otuqza = args$otuqzafile,
      taxaqza = args$taxaqzafile,
      mapfilename = args$metadatafile
    )
  }
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


# filter
mpse2 <-
  mpse %>%
  dplyr::filter(
    !Phylum %in% args$p &
    !Class %in% args$c &
    !Order %in% args$o &
    !Family %in% args$f &
    !Genus %in% args$g &
    !OTU %in% args$s
  ) %>% 
  MicrobiotaProcess::mp_filter_taxa(
    .abundance = Abundance,
    min.abun = as.numeric(args$min_abun),
    min.prop = as.numeric(args$min_prop)
  )

if (output) {
  if (!dir.exists(dirname(args$mpse_output))) {
    dir.create(dirname(args$mpse_output), recursive = TRUE)
  }
  saveRDS(mpse2, args$mpse_output)
}
