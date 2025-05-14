#!/usr/bin/env Rscript

# ─────────────────────────────────────────────────────────────────────────────
# Inspect & refine GTDB-Tk taxonomic assignments
# - Extract genus from GTDB-Tk `classification` field
# - Generate iTOL metadata (NODE → genus)
# - Plot decorated concatenated-marker tree colored by genus
# ─────────────────────────────────────────────────────────────────────────────

suppressPackageStartupMessages({
  library(tidyverse)
  library(ggtree)
  library(treeio)
  library(ape)
  library(stringr)
})

# 1) Define file paths
ts_summary    <- "results/checkm/bins_high_quality/gtdbtk/classify/my_project.bac120.summary.tsv"
decorated_tree <- "results/checkm/bins_high_quality/gtdbtk/de_novo_wf/infer/gtdbtk.bac120.decorated.tree"
refine_dir     <- "results/analysis/extra/taxonomy/refined_taxonomy"
itol_csv       <- file.path(refine_dir, "itol_metadata.txt")
output_png     <- file.path(refine_dir, "chanGED_refined_tree.png")

# 2) Read classification summary and extract genus
df <- read_tsv(ts_summary, show_col_types = FALSE) %>%
  mutate(
    genus = classification %>%
      str_extract("(?<=;g__)[^;]+") %>%
      replace_na("unknown")
  )

# 3) Ensure output directory exists
dir.create(refine_dir, recursive = TRUE, showWarnings = FALSE)

# 4) Write iTOL metadata (NODE → genus)
meta <- df %>% select(NODE = user_genome, COLOR_LABEL = genus)
write_tsv(meta, itol_csv)
message("iTOL metadata written to: ", itol_csv)

# 5) Load the decorated tree
message("Loading tree from: ", decorated_tree)
tree <- read.tree(decorated_tree)

# 6) Combine tree structure with genus data
# Convert tree to tibble, join with genus column, then convert back to treedata
tr_df <- as_tibble(tree) %>%
  left_join(
    df %>% transmute(label = user_genome, genus),
    by = "label"
  )
tree_data <- as.treedata(tree, data = tr_df)

# 7) Plot tree colored by genus
message("Plotting tree...")
p <- ggtree(tree_data, aes(color = genus)) +
  geom_tippoint(size = 2) +
  theme_tree2() +
  labs(
    title = "GTDB-Tk de novo concatenated-marker tree colored by genus",
    color = "Genus"
  )

# 8) Save the figure
message("Saving plot to: ", output_png)
ggsave(output_png, p, width = 8, height = 10, dpi = 150)
message("Static tree plot written to: ", output_png)

