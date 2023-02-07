#!/usr/bin/env Rscript

'mpse diversity beta script

Usage:
  mpse_diversity_beta.R <method> <distmethod> <mpse> <group> <dist_tsv> <plot_outdir> <image> <h1> <w1> <h2> <w2> <h3> <w3> <h4> <w4>
  mpse_import.R (-h | --help)
  mpse_import.R --version

Options:
  -h --help     Show this screen.
  --version     Show version.

' -> doc


library(magrittr)
library(ggplot2)
library(patchwork)
library(ggtree)
library(ggtreeExtra)


args <- docopt::docopt(doc, version = 'mpse diversity beta v0.1')


if (!dir.exists(args$plot_outdir)) {
  dir.create(args$plot_outdir, recursive = TRUE)
}

mpse <- readRDS(args$mpse)

mpse %<>% 
  MicrobiotaProcess::mp_decostand(
    .abundance = Abundance)

# cal dist
mpse %<>%
  MicrobiotaProcess::mp_cal_dist(
    .abundance = hellinger,
    distmethod = args$distmethod)

# extract distance
mpse_dist <- as.matrix(mpse %>% MicrobiotaProcess::mp_extract_dist(distmethod = args$distmethod))
mpse_dist[lower.tri(mpse_dist, diag=TRUE)] <- NA
#print(mpse_dist)

mpse_dist <-
  mpse_dist %>%
  as.data.frame() %>%
  tibble::rownames_to_column("Sample_a") %>%
  tidyr::pivot_longer(
    -c(Sample_a),
    names_to = "Sample_b",
    values_to = "distance") %>%
  dplyr::filter(!is.na(distance))

if (!dir.exists(dirname(args$dist_tsv))) {
  dir.create(dirname(args$dist_tsv), recursive = TRUE)
}
readr::write_tsv(mpse_dist, args$dist_tsv)

# plot dist
# samples distance
p1 <- mpse %>%
  MicrobiotaProcess::mp_plot_dist(
    .distmethod = !!rlang::sym(args$distmethod),
    .group = !!rlang::sym(args$group))

# groups distance
p2 <- mpse %>%
  MicrobiotaProcess::mp_plot_dist(
    .distmethod = !!rlang::sym(args$distmethod),
    .group = !!rlang::sym(args$group),
    group.test = TRUE,
    textsize = 2)


# cal pcoa
mpse %<>% 
  MicrobiotaProcess::mp_cal_pcoa(
    .abundance = hellinger, distmethod = args$distmethod)

# plot pcoa
pcoa_p1 <- mpse %>%
  MicrobiotaProcess::mp_plot_ord(
    .ord = pcoa, 
    .group = !!rlang::sym(args$group), 
    .color = !!rlang::sym(args$group), 
    .size = 1.2,
    .alpha = 1,
    ellipse = TRUE,
    show.legend = FALSE
)

pcoa_p2 <- mpse %>%
  MicrobiotaProcess::mp_plot_ord(
    .ord = pcoa, 
    .group = !!rlang::sym(args$group), 
    .color = !!rlang::sym(args$group), 
    .size = Observe, 
    .alpha = Shannon,
    ellipse = TRUE,
    show.legend = FALSE
)

pcoa_p <- pcoa_p1 + pcoa_p2


h1 <- as.numeric(args$h1)
w1 <- as.numeric(args$w1)
h2 <- as.numeric(args$h2)
w2 <- as.numeric(args$w2)
h3 <- as.numeric(args$h3)
w3 <- as.numeric(args$w3)
h4 <- as.numeric(args$h4)
w4 <- as.numeric(args$w4)


# save plot
ggsave(stringr::str_c(args$plot_outdir, "dist_samples.pdf"), p1, 
  height=h1, width=w1, limitsize = FALSE)
ggsave(stringr::str_c(args$plot_outdir, "dist_samples.svg"), p1,
  height=h1, width=w1, limitsize = FALSE)
ggsave(stringr::str_c(args$plot_outdir, "dist_samples.png"), p1,
  height=h1, width=w1, limitsize = FALSE)

ggsave(stringr::str_c(args$plot_outdir, "dist_groups.pdf"), p2,
  height=h2, width=w2, limitsize = FALSE)
ggsave(stringr::str_c(args$plot_outdir, "dist_groups.svg"), p2,
  height=h2, width=w2, limitsize = FALSE)
ggsave(stringr::str_c(args$plot_outdir, "dist_groups.png"), p2,
  height=h2, width=w2, limitsize = FALSE)

ggsave(stringr::str_c(args$plot_outdir, "pcoa.pdf"), pcoa_p,
  height=h3, width=w3, limitsize = FALSE)
ggsave(stringr::str_c(args$plot_outdir, "pcoa.svg"), pcoa_p,
  height=h3, width=w3, limitsize = FALSE)
ggsave(stringr::str_c(args$plot_outdir, "pcoa.png"), pcoa_p,
  height=h3, width=w3, limitsize = FALSE)


# clust
mpse %<>%
  MicrobiotaProcess::mp_cal_clust(
    .abundance = hellinger, 
    distmethod = args$distmethod,
    hclustmethod = "average",
    action = "add"
)

samples_clust <- mpse %>% MicrobiotaProcess::mp_extract_internal_attr(name='SampleClust')

f <- ggtree(samples_clust) + 
  geom_tippoint(aes(color = !!rlang::sym(args$group))) +
  geom_tiplab(as_ylab = TRUE) +
  ggplot2::scale_x_continuous(expand = c(0, 0.01))

phyla_tb <- mpse %>% MicrobiotaProcess::mp_extract_abundance(taxa.class = Phylum, topn = 30)

if (args$method %in% c("dada2", "qiime2")) {

  phyla_tb %<>% tidyr::unnest(cols = RareAbundanceBySample) %>% dplyr::rename(Phyla = "label")

  f <- f +
    geom_fruit(
      data = phyla_tb,
      geom = geom_col,
      mapping = aes(x = RelRareAbundanceBySample, 
                    y = Sample, 
                    fill = Phyla),
      orientation = "y",
      #offset = 0.4,
      pwidth = 3, 
      axis.params = list(axis = "x", 
                         title = "The relative abundance of phyla (%)",
                         title.size = 4,
                         text.size = 2, 
                         vjust = 1),
      grid.params = list()
    )

} else if (args$method == "metaphlan") {

  phyla_tb %<>% tidyr::unnest(cols = AbundanceBySample) %>% dplyr::rename(Phyla = "label")

  f <- f +
    geom_fruit(
      data = phyla_tb,
      geom = geom_col,
      mapping = aes(x = RelAbundanceBySample, 
                    y = Sample, 
                    fill = Phyla),
      orientation = "y",
      #offset = 0.4,
      pwidth = 3, 
      axis.params = list(axis = "x", 
                         title = "The relative abundance of phyla (%)",
                         title.size = 4,
                         text.size = 2, 
                         vjust = 1),
      grid.params = list()
    )
}

ggsave(stringr::str_c(args$plot_outdir, "clust.pdf"), f,
  height=h4, width=w4, limitsize = FALSE)
ggsave(stringr::str_c(args$plot_outdir, "clust.svg"), f,
  height=h4, width=w4, limitsize = FALSE)
ggsave(stringr::str_c(args$plot_outdir, "clust.png"), f,
  height=h4, width=w4, limitsize = FALSE)


if (!dir.exists(dirname(args$image))) {
  dir.create(dirname(args$image), recursive = TRUE)
}
save.image(args$image)