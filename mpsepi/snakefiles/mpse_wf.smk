#!/usr/bin/env snakemake

import sys
import os
import pandas as pd

import mpsepi

shell.executable("bash")

MPSEPI_dir = mpsepi.__path__[0]

WRAPPERS_DIR = os.path.join(MPSEPI_dir, "wrappers")


include: "../rules/mpse_import.smk"
include: "../rules/mpse_rarefy.smk"
include: "../rules/mpse_composition.smk"
include: "../rules/mpse_venn.smk"
include: "../rules/mpse_diversity_alpha.smk"
include: "../rules/mpse_diversity_phylogenetic.smk"
include: "../rules/mpse_diversity_beta.smk"
include: "../rules/mpse_diff.smk"


rule all:
    input:
        rules.mpse_import_all.input,
        rules.mpse_rarefy_all.input,
        rules.mpse_composition_all.input,
        rules.mpse_venn_all.input,
        rules.mpse_diversity_alpha_all.input,
        rules.mpse_diversity_phylogenetic_all.input,
        rules.mpse_diversity_beta_all.input,
        rules.mpse_diff_all.input