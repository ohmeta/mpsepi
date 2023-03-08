#!/usr/bin/env Rscript

'mpse venn script

Usage:
  mpse_venn.R <method> <mpse> <group> <h> <w> <plot_prefix>
  mpse_venn.R (-h | --help)
  mpse_venn.R --version

Options:
  -h --help     Show this screen.
  --version     Show version.

' -> doc


library(ggplot2)
library(MicrobiotaProcess)
library(ggpp)


args <- docopt::docopt(doc, version = 'mpse venn v0.1')

mpse <- readRDS(args$mpse)


if (args$method %in% c("dada2", "qiime2")) {
  mpse %<>%
    mp_cal_venn(
      .abundance = RareAbundance,
      .group = !!rlang::sym(args$group)
  )
} else if (args$method == "metaphlan") {
  mpse %<>%
    mp_cal_venn(
      .abundance = Abundance,
      .group = !!rlang::sym(args$group)
  )
}

venn_p <- mpse %>% 
  mp_plot_venn(
    .group = !!rlang::sym(args$group),
    set_size = 2.5,
    label_size = 2,
    edge_size = 2.5
  ) +
  #scale_colour_manual(values = cols) +
  scale_fill_viridis_c(guide = guide_colorbar(barwidth=.3, barheight=2)) +
  theme(
    legend.title = element_text(size = 8), 
    legend.text = element_text(size = 6) 
  )

if (args$method %in% c("dada2", "qiime2")) {
  mpse %<>%
    mp_cal_upset(
      .abundance = RareAbundance,
      .group = !!rlang::sym(args$group)
  )
} else if (args$method == "metaphlan") {
  mpse %<>%
    mp_cal_upset(
      .abundance = Abundance,
      .group = !!rlang::sym(args$group)
  )
}

upset_p <- mpse %>%
  mp_plot_upset(
    .group = !!rlang::sym(args$group) 
  ) +
  theme_bw() +
  theme(
    plot.background = element_blank(),
    panel.border = element_blank(),
    panel.grid = element_blank(),
    axis.line.x.bottom = element_line(size = .5),
    axis.line.y.left = element_line(size = .5)
  ) +
  ggupset::theme_combmatrix(
    combmatrix.label.extra_spacing = 40
  )

p_up_venn <-
  upset_p + 
  ggpp::annotate(
    "plot_npc", 
    npcx = "right", 
    npcy = "top", 
    label = venn_p,
    vp.width = 0.6,
    vp.height = 0.4
  )


p_prefix <- args$plot_prefix

if (!dir.exists(dirname(p_prefix))) {
  dir.create(dirname(p_prefix), recursive = TRUE)
}

h <- as.numeric(args$h)
w <- as.numeric(args$w)

ggsave(stringr::str_c(p_prefix, ".pdf"), p_up_venn, height=h, width=w, limitsize = FALSE)
ggsave(stringr::str_c(p_prefix, ".svg"), p_up_venn, height=h, width=w, limitsize = FALSE)
ggsave(stringr::str_c(p_prefix, ".png"), p_up_venn, height=h, width=w, limitsize = FALSE)

