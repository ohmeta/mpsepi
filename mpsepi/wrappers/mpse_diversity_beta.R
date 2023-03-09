#!/usr/bin/env Rscript

'mpse diversity beta script

Usage:
  mpse_diversity_beta.R cal <method> <distmethod> <mpse> <group> <dist_tsv> <mpse_output>
  mpse_diversity_beta.R plot dist <method> <distmethod> <mpse> <group> <plot_outdir> <h_samples> <w_samples> <h_groups> <w_groups>
  mpse_diversity_beta.R plot pca <method> <distmethod> <mpse> <group> <plot_outdir> <height> <width>
  mpse_diversity_beta.R plot pcoa <method> <distmethod> <mpse> <group> <plot_outdir> <height> <width>
  mpse_diversity_beta.R plot nmds <method> <distmethod> <mpse> <group> <plot_outdir> <height> <width>
  mpse_diversity_beta.R plot clust <method> <distmethod> <mpse> <group> <plot_outdir> <height> <width>

  mpse_diversity_beta.R (-h | --help)
  mpse_diversity_beta.R --version

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


if (args$cal) {
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

  # cal pca
  mpse %<>% 
    MicrobiotaProcess::mp_cal_pca(
      .abundance = hellinger,
      action = "add")

  # cal pcoa
  mpse %<>% 
    MicrobiotaProcess::mp_cal_pcoa(
      .abundance = hellinger,
      distmethod = args$distmethod,
      action = "add")


  # cal nmds
  mpse %<>% 
    MicrobiotaProcess::mp_cal_nmds(
      .abundance = hellinger,
      distmethod = args$distmethod,
      action = "add",
      seed = 2023)

  # clust
  mpse %<>%
    MicrobiotaProcess::mp_cal_clust(
      .abundance = hellinger, 
      distmethod = args$distmethod,
      hclustmethod = "average",
      action = "add"
  )

  if (!dir.exists(dirname(args$mpse_output))) {
    dir.create(dirname(args$mpse_output), recursive = TRUE)
  }
  saveRDS(mpse, args$mpse_output)
}


if (args$plot) {
  mpse <- readRDS(args$mpse)

  if (!dir.exists(args$plot_outdir)) {
    dir.create(args$plot_outdir, recursive = TRUE)
  }

  if (args$dist) {
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

    h1 <- as.numeric(args$h_samples)
    w1 <- as.numeric(args$w_samples)
    h2 <- as.numeric(args$h_groups)
    w2 <- as.numeric(args$h_groups)
  
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
  }

  if (args$pca) {
    # plot pca
    pca_p1 <- mpse %>%
      MicrobiotaProcess::mp_plot_ord(
        .ord = pca, 
        .group = !!rlang::sym(args$group), 
        .color = !!rlang::sym(args$group),
        #.starshape = !!rlang::sym(args$group),
        .size = 1.2,
        .alpha = 1,
        ellipse = TRUE,
        show.legend = FALSE
    )
    pca_p2 <- mpse %>%
      MicrobiotaProcess::mp_plot_ord(
        .ord = pca, 
        .group = !!rlang::sym(args$group), 
        .color = !!rlang::sym(args$group), 
        #.starshape = !!rlang::sym(args$group),
        .size = Observe, 
        .alpha = Shannon,
        ellipse = TRUE,
        show.legend = FALSE
    )
    pca_p <- pca_p1 + pca_p2

    h <- as.numeric(args$height)
    w <- as.numeric(args$width)

    ggsave(stringr::str_c(args$plot_outdir, "pca.pdf"), pca_p,
      height=h, width=w, limitsize = FALSE)
    ggsave(stringr::str_c(args$plot_outdir, "pca.svg"), pca_p,
      height=h, width=w, limitsize = FALSE)
    ggsave(stringr::str_c(args$plot_outdir, "pca.png"), pca_p,
      height=h, width=w, limitsize = FALSE)
  }

  if (args$pcoa) {
    # plot pcoa
    pcoa_p1 <- mpse %>%
      MicrobiotaProcess::mp_plot_ord(
        .ord = pcoa, 
        .group = !!rlang::sym(args$group), 
        .color = !!rlang::sym(args$group), 
        .starshape = !!rlang::sym(args$group),
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
        .starshape = !!rlang::sym(args$group),
        .size = Observe, 
        .alpha = Shannon,
        ellipse = TRUE,
        show.legend = FALSE
    )
    pcoa_p <- pcoa_p1 + pcoa_p2

    h <- as.numeric(args$height)
    w <- as.numeric(args$width)

    ggsave(stringr::str_c(args$plot_outdir, "pcoa.pdf"), pcoa_p,
      height=h, width=w, limitsize = FALSE)
    ggsave(stringr::str_c(args$plot_outdir, "pcoa.svg"), pcoa_p,
      height=h, width=w, limitsize = FALSE)
    ggsave(stringr::str_c(args$plot_outdir, "pcoa.png"), pcoa_p,
      height=h, width=w, limitsize = FALSE)
  }

  if (args$nmds) {
    # plot nmds
    nmds_p1 <- mpse %>%
      MicrobiotaProcess::mp_plot_ord(
        .ord = nmds, 
        .group = !!rlang::sym(args$group), 
        .color = !!rlang::sym(args$group), 
        .starshape = !!rlang::sym(args$group),
        .size = 1.2,
        .alpha = 1,
        ellipse = TRUE,
        show.legend = FALSE
    )
    nmds_p2 <- mpse %>%
      MicrobiotaProcess::mp_plot_ord(
        .ord = nmds, 
        .group = !!rlang::sym(args$group), 
        .color = !!rlang::sym(args$group), 
        .starshape = !!rlang::sym(args$group),
        .size = Observe, 
        .alpha = Shannon,
        ellipse = TRUE,
        show.legend = FALSE
    )
    nmds_p <- nmds_p1 + nmds_p2

    h <- as.numeric(args$height)
    w <- as.numeric(args$width)

    ggsave(stringr::str_c(args$plot_outdir, "nmds.pdf"), nmds_p,
      height=h, width=w, limitsize = FALSE)
    ggsave(stringr::str_c(args$plot_outdir, "nmds.svg"), nmds_p,
      height=h, width=w, limitsize = FALSE)
    ggsave(stringr::str_c(args$plot_outdir, "nmds.png"), nmds_p,
      height=h, width=w, limitsize = FALSE)
  }

  if (args$clust) {
    samples_clust <-
      mpse %>%
      MicrobiotaProcess::mp_extract_internal_attr(name='SampleClust')

    f <- ggtree(samples_clust) + 
      geom_tippoint(aes(color = !!rlang::sym(args$group))) +
      geom_tiplab(as_ylab = TRUE) +
      ggplot2::scale_x_continuous(expand = c(0, 0.01))

    phyla_tb <-
      mpse %>%
      MicrobiotaProcess::mp_extract_abundance(taxa.class = Phylum, topn = 30)

    if (args$method %in% c("dada2", "qiime2")) {
      phyla_tb %<>%
        tidyr::unnest(cols = RareAbundanceBySample) %>%
        dplyr::rename(Phyla = "label")

      f <- f +
        geom_fruit(
          data = phyla_tb,
          geom = geom_col,
          mapping = aes(
            x = RelRareAbundanceBySample, 
            y = Sample, 
            fill = Phyla),
          orientation = "y",
          #offset = 0.4,
          pwidth = 3, 
          axis.params = list(
            axis = "x", 
            title = "The relative abundance of phyla (%)",
            title.size = 4,
            text.size = 2, 
            vjust = 1),
          grid.params = list()
        )
    } else if (args$method == "metaphlan") {
      phyla_tb %<>%
        tidyr::unnest(cols = AbundanceBySample) %>%
        dplyr::rename(Phyla = "label")

      f <- f +
        geom_fruit(
          data = phyla_tb,
          geom = geom_col,
          mapping = aes(
            x = RelAbundanceBySample, 
            y = Sample, 
            fill = Phyla
          ),
          orientation = "y",
          #offset = 0.4,
          pwidth = 3, 
          axis.params = list(
            axis = "x", 
            title = "The relative abundance of phyla (%)",
            title.size = 4,
            text.size = 2, 
            vjust = 1
          ),
          grid.params = list()
        )
    }

    h <- as.numeric(args$height)
    w <- as.numeric(args$width)

    ggsave(stringr::str_c(args$plot_outdir, "clust.pdf"), f,
      height=h, width=w, limitsize = FALSE)
    ggsave(stringr::str_c(args$plot_outdir, "clust.svg"), f,
      height=h, width=w, limitsize = FALSE)
    ggsave(stringr::str_c(args$plot_outdir, "clust.png"), f,
      height=h, width=w, limitsize = FALSE)
  }
}
