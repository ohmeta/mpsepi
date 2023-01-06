#!/usr/bin/env Rscript

'mpse diversity beta script

Usage:
  mpse_diversity_beta.R <method> <distmethod> <mpse> <group> <dist_tsv> <dist_samples_plot_prefix> <dist_groups_plot_prefix> <pcoa_plot_prefix> <clust_plot_prefix> <image>
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

s_prefix <- args$dist_samples_plot_prefix
g_prefix <- args$dist_groups_plot_prefix
p_prefix <- args$pcoa_plot_prefix
c_prefix <- args$clust_plot_prefix

if (!dir.exists(dirname(s_prefix))) {
  dir.create(dirname(s_prefix), recursive = TRUE)
}
if (!dir.exists(dirname(g_prefix))) {
  dir.create(dirname(g_prefix), recursive = TRUE)
}
if (!dir.exists(dirname(p_prefix))) {
  dir.create(dirname(p_prefix), recursive = TRUE)
}
if (!dir.exists(dirname(c_prefix))) {
  dir.create(dirname(c_prefix), recursive = TRUE)
}


mpse <- readRDS(args$mpse)

mpse %<>% MicrobiotaProcess::mp_decostand(.abundance = Abundance)

mpse %<>% MicrobiotaProcess::mp_cal_dist(.abundance = hellinger, distmethod = args$distmethod)


mpse_dist <- as.matrix(mpse %>% MicrobiotaProcess::mp_extract_dist(distmethod = args$distmethod))
mpse_dist[lower.tri(mpse_dist, diag=TRUE)] <- NA

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

# samples distance
p1 <- mpse %>%
  MicrobiotaProcess::mp_plot_dist(
    .distmethod = args$distmethod,
    .group = !!rlang::sym(args$group))

# groups distance
p2 <- mpse %>%
  MicrobiotaProcess::mp_plot_dist(
    .distmethod = args$distmethod,
    .group = !!rlang::sym(args$group),
    group.test = TRUE,
    textsize = 2)

# pcoa
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


# save plot
ggsave(stringr::str_c(s_prefix, ".pdf"), p1)
ggsave(stringr::str_c(s_prefix, ".svg"), p1)
ggsave(stringr::str_c(s_prefix, ".png"), p1)

ggsave(stringr::str_c(g_prefix, ".pdf"), p1)
ggsave(stringr::str_c(g_prefix, ".svg"), p2)
ggsave(stringr::str_c(g_prefix, ".png"), p2)

ggsave(stringr::str_c(p_prefix, ".pdf"), pcoa_p)
ggsave(stringr::str_c(p_prefix, ".svg"), pcoa_p)
ggsave(stringr::str_c(p_prefix, ".png"), pcoa_p)


# clust
mpse %<>%
  MicrobiotaProcess::mp_cal_clust(
    .abundance = hellinger, 
    distmethod = args$distmethod,
    hclustmethod = "average",
    action = "add"
)

samples_clust <- mpse %>% MicrobiotaProcess::mp_extract_internal_attr(name='SampleClust')

f <- ggtree(sample_clust) + 
  geom_tippoint(aes(color = args$group)) +
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

ggsave(stringr::str_c(c_prefix, ".pdf"), f)
ggsave(stringr::str_c(c_prefix, ".svg"), f)
ggsave(stringr::str_c(c_prefix, ".png"), f)


if (!dir.exists(dirname(args$image))) {
  dir.create(dirname(args$image), recursive = TRUE)
}
save.image(args$image)