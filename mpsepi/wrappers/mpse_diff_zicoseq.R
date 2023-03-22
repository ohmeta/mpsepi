#!/usr/bin/env Rscript

'mpse diff zicoseq script

Usage:
  mpse_diff_zicoseq.R cal <method> <group> <mpse> <mpse_output> <lda_tsv>
  mpse_diff_zicoseq.R plot tree <group> <mpse> <plot_prefix> <height> <width>
  mpse_diff_zicoseq.R plot cladogram <group> <mpse> <plot_prefix> <height> <width>
  mpse_diff_zicoseq.R plot box_bar <group> <mpse> <plot_prefix> <height> <width>
  mpse_diff_zicoseq.R plot mahattan <group> <mpse> <plot_prefix> <height> <width>
  mpse_diff_zicoseq.R (-h | --help)
  mpse_diff_zicoseq.R --version

Options:
  -h --help     Show this screen.
  --version     Show version.

' -> doc

# biomarker discovery

library(GUniFrac)
library(matrixStats)
library(magrittr)
library(MicrobiotaProcess)


args <- docopt::docopt(doc, version = 'mpse diff zicoseq v0.1')

mpse <- readRDS(args$mpse)

sign_group <- stringr::str_c("Sign_", args$group)


# cal
if (args$cal) {
  if (args$method %in% c("qiime2", "dada2")) {
    abun_all <- 
      mpse %>% mp_extract_abundance() %>%
      dplyr::select(label, RareAbundanceBySample)

    features_all <-
      abun_all %>%
      tidyr::unnest(RareAbundanceBySample) %>%
      dplyr::select(label, Sample, RelRareAbundanceBySample) %>%
      tidyr::pivot_wider(
        id_cols = label,
        names_from = "Sample",
        values_from = RelRareAbundanceBySample
      ) %>%
      tibble::column_to_rownames(var = "label") %>%
      as.matrix()

    features_all <- features_all[!rowSds(features_all) == 0, ]

    sample_da <- 
      mpse %>%
      mp_extract_sample() %>%
      dplyr::select(Sample, !!rlang::sym(args$group)) %>%
      tibble::column_to_rownames(var = "Sample")

    set.seed(123)
    zicoseq_res <-
      ZicoSeq(meta.dat = sample_da,
              feature.dat = features_all / 100,
              grp.name = args$group,
              prev.filter = .1, 
              perm.no = 999,
              feature.dat.type = "proportion",
              verbose = FALSE)

    res_df <- data.frame(zicoseq_res$p.adj.fdr)
    print(colnames(res_df))

    colnames(res_df) <- "FDR.zicoseq"

    res_sign <-
      abun_all %>%
      dplyr::filter(
        label %in% rownames(
            res_df[res_df$FDR.zicoseq <=0.05, , drop = FALSE])) %>%
      tidyr::unnest(RareAbundanceBySample) %>%
      dplyr::group_by(label, !!rlang::sym(args$group)) %>%
      dplyr::summarize(MeanAbu = mean(RareAbundance)) %>%
      dplyr::slice_max(MeanAbu) %>%
      dplyr::ungroup() %>%
      dplyr::rename(!!rlang::sym(sign_group) := args$group) %>%
      dplyr::select(label, !!rlang::sym(sign_group))

      # https://community.rstudio.com/t/pass-a-variable-to-dplyr-rename-to-change-columnname/6907/2


    res_df %<>%
      as_tibble(rownames = "label") %>%
      dplyr::left_join(res_sign)

    taxa_tree <-
      mpse %>%
      mp_extract_taxatree() %>%
      dplyr::select(
        -c("LDAupper", "LDAmean", "LDAlower", "pvalue", "fdr", sign_group),
        keep.td = T)

    taxa_tree %<>%
      dplyr::left_join(res_df, by = "label")

    mpse2 <- mpse
    taxatree(mpse2) <- taxa_tree

    if (!dir.exists(dirname(args$lda_tsv))) {
      dir.create(dirname(args$lda_tsv), recursive = TRUE)
    }

    taxa_tree2 <-
      mpse2 %>%
      mp_extract_tree(type = "taxatree")

    taxa_tree_lda <- 
      taxa_tree2 %>%
      dplyr::select(
      label, nodeClass, FDR.zicoseq, !!rlang::sym(sign_group))

    readr::write_tsv(taxa_tree_lda, args$lda_tsv)

    if (!dir.exists(dirname(args$mpse_output))) {
      dir.create(dirname(args$mpse_output), recursive = TRUE)
    }
    saveRDS(mpse2, args$mpse_output)
  }
}


# plot
if (args$plot) {
  library(ggtree)
  library(ggtreeExtra)
  library(ggplot2)
  library(MicrobiotaProcess)
  library(tidytree)
  library(ggstar)
  library(forcats)

  if (!dir.exists(dirname(args$plot_prefix))) {
    dir.create(dirname(args$plot_prefix), recursive = TRUE)
  }

  height <- as.numeric(args$height)
  width <- as.numeric(args$width)

  if (args$tree) {
    plot <- mpse %>%
      mp_plot_diff_res(
        group.abun = TRUE,
        pwidth.abun = 0.1
      )
  }

  if (args$cladogram) {
    plot <- mpse %>%
      mp_plot_diff_cladogram(
        .group = !!rlang::sym(sign_group),
        .size = FDR.zicoseq,
        removeUnknown = TRUE,
        as.tiplab = TRUE
      ) +
      scale_fill_diff_cladogram(values = c('deepskyblue', 'orange')) +
      scale_size_continuous(range = c(1, 4))
  }

  if (args$box_bar) {
    f_box <- mpse %>%
      mp_plot_diff_boxplot(.group = !!rlang::sym(sign_group)) %>%
      set_diff_boxplot_color(
        values = c("deepskyblue", "orange"),
        guide = guide_legend(title = NULL)
      )
    f_bar <- mpse %>%
      mp_plot_diff_boxplot(
        taxa.class = "OTU",
        group.abun = TRUE,
        removeUnknown = TRUE
      ) %>%
      set_diff_boxplot_color(
        values = c("deepskyblue", "orange"),
        guide = guide_legend(title = NULL)
      )
    plot <- aplot::plot_list(f_box, f_bar)
  }

  if (args$mahattan) {
    plot <- mpse %>%
      mp_plot_diff_manhattan(
        .group = !!rlang::sym(sign_group),
        .y = log10(FDR.zicoseq),
        taxa.class = "OTU",
        anno.taxa.class = Phylum
    )
  }

  ggsave(stringr::str_c(args$plot_prefix, ".pdf"), plot,
    height=height, width=width, limitsize = FALSE)

  ggsave(stringr::str_c(args$plot_prefix, ".svg"), plot,
    height=height, width=width, limitsize = FALSE)

  ggsave(stringr::str_c(args$plot_prefix, ".png"), plot,
    height=height, width=width, limitsize = FALSE)
}