#!/usr/bin/env Rscript

'mpse diversity beta script

Usage:
  mpse_diversity_beta.R <distmethod> <mpse> <group> <dist_tsv> <dist_plot_prefix> <compare_plot_prefix> <pcoa_plot_prefix> <image>
  mpse_import.R (-h | --help)
  mpse_import.R --version

Options:
  -h --help     Show this screen.
  --version     Show version.

' -> doc


library(magrittr)
library(ggplot2)
library(patchwork)


args <- docopt::docopt(doc, version = 'mpse diversity beta v0.1')

readRDS(args$mpse)

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

readr::write_tsv(mpse_dist, args$dist_tsv)


p1 <- mpse %>% MicrobiotaProcess::mp_plot_dist(.distmethod = args$distmethod, .group = args$group)

p2 <- mpse %>% MicrobiotaProcess::mp_plot_dist(.distmethod = args$distmethod, .group = args$group, group.test = TRUE, textsize = 2)

pcoa_p1 <- mpse %>%
        mp_plot_ord(
          .ord = pcoa, 
          .group = time, 
          .color = time, 
          .size = 1.2,
          .alpha = 1,
          ellipse = TRUE,
          show.legend = FALSE
        )

pcoa_p2 <- mpse %>% 
        mp_plot_ord(
          .ord = pcoa, 
          .group = time, 
          .color = time, 
          .size = Observe, 
          .alpha = Shannon,
          ellipse = TRUE,
          show.legend = FALSE
        )

pcoa_p <- pcoa_p1 + pcoa_p2

d_prefix <- args$dist_plot_prefix
c_prefix <- args$compare_plot_prefix
p_prefix <- args$pcoa_plot_prefix


ggsave(stringr::str_c(d_prefix, ".pdf"), p1)
ggsave(stringr::str_c(d_prefix, ".svg"), p1)
ggsave(stringr::str_c(d_prefix, ".png"), p1)

ggsave(stringr::str_c(c_prefix, ".pdf"), p1)
ggsave(stringr::str_c(c_prefix, ".svg"), p2)
ggsave(stringr::str_c(c_prefix, ".png"), p2)

ggsave(stringr::str_c(p_prefix, ".pdf"), pcoa_p)
ggsave(stringr::str_c(p_prefix, ".svg"), pcoa_p)
ggsave(stringr::str_c(p_prefix, ".png"), pcoa_p)


save.image(args$image)