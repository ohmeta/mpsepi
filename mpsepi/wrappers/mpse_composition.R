#!/usr/bin/env python

'mpse composition script

Usage:
  mpse_composition.R <method> <mpse> <group> <abun_plot_prefix> <group_plot_prefix> <heatmap_plot_prefix> <image>
  mpse_composition.R (-h | --help)
  mpse_composition.R --version

Options:
  -h --help     Show this screen.
  --version     Show version.

' -> doc


library(magrittr)
library(ggplot2)
library(patchwork)


args <- docopt::docopt(doc, version = 'mpse composition v0.1')

mpse <- readRDS(args$mpse)

p_prefix <- args$abun_plot_prefix
f_prefix <- args$group_plot_prefix
h_prefix <- args$heatmap_plot_prefix

if (args$method %in% c("dada2", "qiime2")) {
  mpse %<>%
    MicrobiotaProcess::mp_cal_abundance(
      .abundance = RareAbundance
    ) %>%
    MicrobiotaProcess::mp_cal_abundance(
      .abundance = RareAbundance,
      .group = args$group
    )

  p1_p <- mpse %>%
    MicrobiotaProcess::mp_plot_abundance(
      .abundance = RareAbundance,
      .group = args$group, 
      taxa.class = Phylum, 
      topn = 20,
      relative = TRUE
    )
  p2_p <- mpse %>%
    MicrobiotaProcess::mp_plot_abundance(
      .abundance = RareAbundance,
      .group = args$group,
      taxa.class = Phylum,
      topn = 20,
      relative = FALSE
    )
  p_p <- p1_p / p2_p

  p1_g <- mpse %>%
    MicrobiotaProcess::mp_plot_abundance(
      .abundance = RareAbundance,
      .group = args$group, 
      taxa.class = Genus, 
      topn = 20,
      relative = TRUE
    )
  p2_g <- mpse %>%
    MicrobiotaProcess::mp_plot_abundance(
      .abundance = RareAbundance,
      .group = args$group,
      taxa.class = Genus,
      topn = 20,
      relative = FALSE
    )
  p_g <- p1_g / p2_g

  p1_s <- mpse %>%
    MicrobiotaProcess::mp_plot_abundance(
      .abundance = RareAbundance,
      .group = args$group, 
      taxa.class = OTU, 
      topn = 20,
      relative = TRUE
    )
  p2_s <- mpse %>%
    MicrobiotaProcess::mp_plot_abundance(
      .abundance = RareAbundance,
      .group = args$group,
      taxa.class = OTU,
      topn = 20,
      relative = FALSE
    )
  p_s <- p1_s / p2_s


  f1_p <- mpse %>%
    MicrobiotaProcess::mp_plot_abundance(
      .abundance = RareAbundance, 
      .group = args$group,
      taxa.class = Phylum,
      topn = 20,
      plot.group = TRUE
    )
  f2_p <- mpse %>%
    MicrobiotaProcess::mp_plot_abundance(
      .abundance = RareAbundance,
      .group = args$group,
      taxa.class = Phylum,
      topn = 20,
      relative = FALSE,
      plot.group = TRUE
    )
  f_p <- f1_p / f2_p

  f1_g <- mpse %>%
    MicrobiotaProcess::mp_plot_abundance(
      .abundance = RareAbundance, 
      .group = args$group,
      taxa.class = Genus,
      topn = 20,
      plot.group = TRUE
    )
  f2_g <- mpse %>%
    MicrobiotaProcess::mp_plot_abundance(
      .abundance = RareAbundance,
      .group = args$group,
      taxa.class = Genus,
      topn = 20,
      relative = FALSE,
      plot.group = TRUE
    )
  f_g <- f1_g / f2_g

  f1_s <- mpse %>%
    MicrobiotaProcess::mp_plot_abundance(
      .abundance = RareAbundance, 
      .group = args$group,
      taxa.class = OTU,
      topn = 20,
      plot.group = TRUE
    )
  f2_s <- mpse %>%
    MicrobiotaProcess::mp_plot_abundance(
      .abundance = RareAbundance,
      .group = args$group,
      taxa.class = OTU,
      topn = 20,
      relative = FALSE,
      plot.group = TRUE
    )
  f_s <- f1_s / f2_s


  h1_p <- mpse %>%
    MicrobiotaProcess::mp_plot_abundance(
      .abundance = RareAbundance,
      .group = args$group,
      taxa.class = Phylum,
      relative = TRUE,
      topn = 20,
      geom = 'heatmap',
      features.dist = 'euclidean',
      features.hclust = 'average',
      sample.dist = 'bray',
      sample.hclust = 'average'
    ) 
  h2_p <- mpse %>%
    MicrobiotaProcess::mp_plot_abundance(
      .abundance = RareAbundance,
      .group = args$group,
      taxa.class = Phylum,
      relative = FALSE,
      topn = 20,
      geom = 'heatmap',
      features.dist = 'euclidean',
      features.hclust = 'average',
      sample.dist = 'bray',
      sample.hclust = 'average'
  )
  h_p <- h1_p / h2_p

  h1_g <- mpse %>%
    MicrobiotaProcess::mp_plot_abundance(
      .abundance = RareAbundance,
      .group = args$group,
      taxa.class = Genus,
      relative = TRUE,
      topn = 20,
      geom = 'heatmap',
      features.dist = 'euclidean',
      features.hclust = 'average',
      sample.dist = 'bray',
      sample.hclust = 'average'
    ) 
  h2_g <- mpse %>%
    MicrobiotaProcess::mp_plot_abundance(
      .abundance = RareAbundance,
      .group = args$group,
      taxa.class = Genus,
      relative = FALSE,
      topn = 20,
      geom = 'heatmap',
      features.dist = 'euclidean',
      features.hclust = 'average',
      sample.dist = 'bray',
      sample.hclust = 'average'
  )
  h_g <- h1_g / h2_g

  h1_s <- mpse %>%
    MicrobiotaProcess::mp_plot_abundance(
      .abundance = RareAbundance,
      .group = args$group,
      taxa.class = OTU,
      relative = TRUE,
      topn = 20,
      geom = 'heatmap',
      features.dist = 'euclidean',
      features.hclust = 'average',
      sample.dist = 'bray',
      sample.hclust = 'average'
    ) 
  h2_s <- mpse %>%
    MicrobiotaProcess::mp_plot_abundance(
      .abundance = RareAbundance,
      .group = args$group,
      taxa.class = OTU,
      relative = FALSE,
      topn = 20,
      geom = 'heatmap',
      features.dist = 'euclidean',
      features.hclust = 'average',
      sample.dist = 'bray',
      sample.hclust = 'average'
  )
  h_s <- h1_s / h2_s

} else if (args$method == "metaphlan") {

  mpse %<>%
    MicrobiotaProcess::mp_cal_abundance( # for each samples
      .abundance = Abundance
    ) %>%
    MicrobiotaProcess::mp_cal_abundance( # for each groups 
      .abundance = Abundance,
      .group = args$group
    )

  p_p <- mpse %>%
    MicrobiotaProcess::mp_plot_abundance(
      .abundance = Abundance,
      .group = args$group, 
      taxa.class = Phylum, 
      topn = 20,
      relative = TRUE,
      force = TRUE
    )

  p_g <- mpse %>%
    MicrobiotaProcess::mp_plot_abundance(
      .abundance = Abundance,
      .group = args$group, 
      taxa.class = Genus, 
      topn = 20,
      relative = TRUE,
      force = TRUE
    )

  p_s <- mpse %>%
    MicrobiotaProcess::mp_plot_abundance(
      .abundance = Abundance,
      .group = args$group, 
      taxa.class = OTU, 
      topn = 20,
      relative = TRUE,
      force = TRUE
    )


  f_p <- mpse %>%
    MicrobiotaProcess::mp_plot_abundance(
      .abundance = Abundance,
      .group = args$group, 
      taxa.class = Phylum, 
      topn = 20,
      relative = TRUE,
      force = TRUE,
      plot.group = TRUE
    )

  f_g <- mpse %>%
    MicrobiotaProcess::mp_plot_abundance(
      .abundance = Abundance,
      .group = args$group, 
      taxa.class = Genus, 
      topn = 20,
      relative = TRUE,
      force = TRUE,
      plot.group = TRUE
    )

  f_s <- mpse %>%
    MicrobiotaProcess::mp_plot_abundance(
      .abundance = Abundance,
      .group = args$group, 
      taxa.class = OTU, 
      topn = 20,
      relative = TRUE,
      force = TRUE,
      plot.group = TRUE
    )


  h_p <- mpse %>%
    MicrobiotaProcess::mp_plot_abundance(
      .abundance = Abundance,
      .group = args$group,
      taxa.class = Phylum,
      relative = TRUE,
      force = TRUE,
      topn = 20,
      geom = 'heatmap',
      features.dist = 'euclidean',
      features.hclust = 'average',
      sample.dist = 'bray',
      sample.hclust = 'average'
    ) 

  h_g <- mpse %>%
    MicrobiotaProcess::mp_plot_abundance(
      .abundance = Abundance,
      .group = args$group,
      taxa.class = Genus,
      relative = TRUE,
      force = TRUE,
      topn = 20,
      geom = 'heatmap',
      features.dist = 'euclidean',
      features.hclust = 'average',
      sample.dist = 'bray',
      sample.hclust = 'average')

  h_s <- mpse %>%
    MicrobiotaProcess::mp_plot_abundance(
      .abundance = Abundance,
      .group = args$group,
      taxa.class = OTU,
      relative = TRUE,
      force = TRUE,
      topn = 20,
      geom = 'heatmap',
      features.dist = 'euclidean',
      features.hclust = 'average',
      sample.dist = 'bray',
      sample.hclust = 'average')
}

if (!dir.exists(dirname(p_prefix))) {
  dir.create(dirname(p_prefix), recursive = TRUE)
}

if (!dir.exists(dirname(f_prefix))) {
  dir.create(dirname(f_prefix), recursive = TRUE)
}

if (!dir.exists(dirname(h_prefix))) {
  dir.create(dirname(h_prefix), recursive = TRUE)
}
 
 
## abun plot
ggsave(stringr::str_c(p_prefix, "phylum.pdf"), p_p)
ggsave(stringr::str_c(p_prefix, "phylum.svg"), p_p)
ggsave(stringr::str_c(p_prefix, "phylum.png"), p_p)

ggsave(stringr::str_c(p_prefix, "genus.pdf"), p_g)
ggsave(stringr::str_c(p_prefix, "genus.svg"), p_g)
ggsave(stringr::str_c(p_prefix, "genus.png"), p_g)

ggsave(stringr::str_c(p_prefix, "species.pdf"), p_s)
ggsave(stringr::str_c(p_prefix, "species.svg"), p_s)
ggsave(stringr::str_c(p_prefix, "species.png"), p_s)


## group plot
ggsave(stringr::str_c(f_prefix, "phylum.pdf"), f_p)
ggsave(stringr::str_c(f_prefix, "phylum.svg"), f_p)
ggsave(stringr::str_c(f_prefix, "phylum.png"), f_p)

ggsave(stringr::str_c(f_prefix, "genus.pdf"), f_g)
ggsave(stringr::str_c(f_prefix, "genus.svg"), f_g)
ggsave(stringr::str_c(f_prefix, "genus.png"), f_g)

ggsave(stringr::str_c(f_prefix, "species.pdf"), f_s)
ggsave(stringr::str_c(f_prefix, "species.svg"), f_s)
ggsave(stringr::str_c(f_prefix, "species.png"), f_s)


## heatmap plot
ggsave(stringr::str_c(h_prefix, "phylum.pdf"), h_p)
ggsave(stringr::str_c(h_prefix, "phylum.svg"), h_p)
ggsave(stringr::str_c(h_prefix, "phylum.png"), h_p)

ggsave(stringr::str_c(h_prefix, "genus.pdf"), h_g)
ggsave(stringr::str_c(h_prefix, "genus.svg"), h_g)
ggsave(stringr::str_c(h_prefix, "genus.png"), h_g)

ggsave(stringr::str_c(h_prefix, "species.pdf"), h_s)
ggsave(stringr::str_c(h_prefix, "species.svg"), h_s)
ggsave(stringr::str_c(h_prefix, "species.png"), h_s)


if (!dir.exists(dirname(args$image))) {
  dir.create(dirname(args$image), recursive = TRUE)
}
save.image(args$image)