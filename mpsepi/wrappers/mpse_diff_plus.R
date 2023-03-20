#!/usr/bin/env Rscript

'mpse diff plus script

Usage:
  mpse_diff_plus.R cal <import_method> <diff_method> <dist_method> <formula> <mpse> <mpse_output> <tsv>
  mpse_diff_plus.R plot abundance <import_method> <diff_method> <dist_method> <group> <mpse> <plot_prefix> <height> <width>
  mpse_diff_plus.R plot sample_tree <import_method> <diff_method> <dist_method> <group> <mpse> <plot_prefix> <height> <width>
  mpse_diff_plus.R plot otu_tree <import_method> <diff_method> <dist_method> <group> <mpse> <plot_prefix> <height> <width>
  mpse_diff_plus.R (-h | --help)
  mpse_diff_plus.R --version

Options:
  -h --help     Show this screen.
  --version     Show version.

' -> doc


library(magrittr)
library(ggplot2)
library(MicrobiotaProcess)
library(ggtree)


args <- docopt::docopt(doc, version = 'mpse diff v0.1')

mpse <- readRDS(args$mpse)


if (args$cal) {
  one_formula <- as.formula(args$formula)

  mpse %<>%
      tidybulk::test_differential_abundance(
          .abundance = Abundance,
          .method = args$diff_method,
          .formula = one_formula,
          .action = "add")

  diff_res <-
      mpse %>%
      mp_extract_feature() #%>%
      #dplyr::filter(FDR <= .05 & abs(logFC) >= 2)

  if (!dir.exists(dirname(args$tsv))) {
    dir.create(dirname(args$tsv), recursive = TRUE)
  }
  readr::write_tsv(diff_res, args$tsv)

  if (!dir.exists(dirname(args$mpse_output))) {
    dir.create(dirname(args$mpse_output), recursive = TRUE)
  }
  saveRDS(mpse, args$mpse_output)

} else if(args$plot) {

  height <- as.numeric(args$height)
  width <- as.numeric(args$width)

  if (!dir.exists(dirname(args$plot_prefix))) {
    dir.create(dirname(args$plot_prefix), recursive = TRUE)
  }

  if (args$abundance) {

    diff_res <-
      mpse %>% dplyr::filter(FDR <= .05 & abs(logFC) >= 2)

    if (args$import_method %in% c("dada2", "qiime2")) {
      plot <-
        diff_res %>%
        mp_plot_abundance(
          .abundance = RareAbundance,
          force = TRUE,
          relative = TRUE,
          feature.dist = args$dist_method,
          geom = "heatmap",
          topn = "all",
          .group = !!rlang::sym(args$group)
      )
    } else if(args$import_method == "metaphlan") {

      plot <-
        diff_res %>%
        mp_plot_abundance(
          .abundance = RelAbundance,
          force = TRUE,
          relative = TRUE,
          feature.dist = args$dist_method,
          geom = "heatmap",
          topn = "all",
          .group = !!rlang::sym(args$group)
        )
    }

    plot[[1]] <-
      plot[[1]] +
      scale_fill_viridis_c(
        na.value = 0, 
        trans = 'log10'
      ) +
      guides(
        fill = guide_colorbar(
          title = expression(log[10]("relative abundance")),
          title.position = "right",
          title.theme = element_text(angle=-90, size=9, vjust=.5, hjust=.5),
          label.theme = element_text(angle=-90, size=7, vjust=.5, hjust=.5),
          barwidth = unit(.3, 'cm'),  
          barheight = unit(5, 'cm')
        )
      ) +
      theme(
        axis.text.x = element_blank(),
        axis.text.y = element_text(size = 6)
      )

    plot[[2]] <-
      plot[[2]] +
      #scale_fill_manual(values = cols) +
      theme(
        legend.key.height = unit(0.3, "cm"),
        legend.key.width = unit(0.3, "cm"),
        legend.spacing.y = unit(0.02, "cm"),
        legend.text = element_text(size = 7),
        legend.title = element_text(size = 9)
      )

    f <-
      diff_res %>%
      mp_extract_taxonomy() %>%
      ggplot() +
      geom_text(
        mapping = aes(y=OTU, x=0, label=Genus, color=Phylum),
        hjust = 0,
        size = 2
      ) +
      scale_x_continuous(expand=c(0, 0, 0, 0.1)) +
      theme_bw() +
      theme(
        legend.text = element_text(size = 5),
        legend.title = element_text(size = 7),
        legend.key.width = unit(0.3, "cm"),
        legend.key.height = unit(0.3, "cm"),
        panel.background = element_blank(),
        panel.grid = element_blank(),
        axis.text = element_blank(),
        axis.ticks = element_blank(),
        panel.border = element_blank()
      ) +
      labs(x = NULL, y = NULL)

    plot <- plot %>% insert_right(f, width = 0.4)
  }

  if (args$sample_tree) {
    diff_res <-
      mpse %>%
      dplyr::filter(FDR <= .05 & abs(logFC) >= 2)

    if (args$import_method %in% c("dada2", "qiime2")) {
      diff_dist <-
        diff_res %>%
        mp_cal_dist(
          .abundance = RelRareAbundanceBySample,
          distmethod = args$dist_method
        )
    } else if(args$import_method == "metaphlan") {
      diff_dist <-
        diff_res %>%
        mp_cal_dist(
          .abundance = RelAbundanceBySample,
          distmethod = args$dist_method
        )
    }

    plot <-
      diff_dist %>%
      ggtree(layout = igraph::layout_with_kk, color = "#afb7b8") +
      geom_nodepoint(color = "#afb7b8", size = .5) +
      geom_tippoint(aes(fill = !!rlang::sym(args$group)), shape = 21, size=3) +
      geom_text_repel(
        data = td_filter(isTip),
        mapping = aes(label = label),
        size = 2,
        max.overlaps = 30,
        colour = "black",
        bg.colour = "white"
      ) +
      scale_fill_manual(
        values = cols,
        guide = guide_legend(
           title.theme = element_text(size = 7),
           label.theme = element_text(size = 5),
        )
      )
  }

  if (args$otu_tree) {
    if (args$import_method %in% c("dada2", "qiime2")) {
      mpse_dist <-
        mpse %>%
        mp_cal_dist(
          .abundance = RelRareAbundanceBySample,
          distmethod = args$dist_method,
          cal.feature.dist = TRUE,
        )
    } else if(args$import_method == "metaphlan") {
      mpse_dist <-
        mpse %>%
        mp_cal_dist(
          .abundance = RelAbundanceBySample,
          distmethod = args$dist_method,
          cal.feature.dist = TRUE
        )
    }

    plot <-
      mpse_dist %>%
      hclust() %>%
      ggtree(layout = igraph::layout_with_kk, color = "#bed0d1") +
      geom_nodepoint(color = "#bed0d1", size = .5)

    otu_tab <- mpse %>% mp_extract_feature()

    plot <-
      plot %<+% otu_tab +
      geom_tippoint(
          mapping = aes(fill = logFC, size = -log10(FDR)),
          shape = 21,
          color = "grey"
      ) +
      scale_fill_viridis_c(
        option="C",
        guide = guide_colorbar(
          title.theme = element_text(size = 7),
          label.theme = element_text(size = 5),
          barheight = unit(1.5, "cm"),
          barwidth = unit(.3, "cm")
      )) +
      scale_size_continuous(
        range = c(.5, 6),
        guide = guide_legend(
          key.width = .3,
          key.height = .3,
          label.theme = element_text(size = 5),
          title.theme = element_text(size = 7)
      )) +
      geom_text_repel(
        data = td_filter(FDR <= .05 & abs(logFC) >= 2),
        mapping = aes(x = x, y = y, label = label),
        size = 2,
        min.segment.length = 0.1,
        segment.size = .25,
        segment.colour = 'grey18',
        colour = "black",
        bg.colour = 'white'
        #max.overlaps = 60,
      )
  }

  ggsave(stringr::str_c(args$plot_prefix, ".pdf"), plot,
    height=height, width=width, limitsize = FALSE)

  ggsave(stringr::str_c(args$plot_prefix, ".svg"), plot,
    height=height, width=width, limitsize = FALSE)

  ggsave(stringr::str_c(args$plot_prefix, ".png"), plot,
    height=height, width=width, limitsize = FALSE)

}