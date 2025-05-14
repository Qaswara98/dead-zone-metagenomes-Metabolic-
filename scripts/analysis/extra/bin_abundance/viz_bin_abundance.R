#!/usr/bin/env Rscript

# ──────────────────────────────────────────────────────────────────────────────
# Composite visualization of MAG abundances (DNA)
# - 1) horizontal bar‐plots faceted by sample
# - 2) stacked bar‐chart of community composition
# - 3) heatmap of bin × sample
# ──────────────────────────────────────────────────────────────────────────────

suppressPackageStartupMessages({
  library(tidyverse)    # ggplot2, dplyr, tidyr, readr, forcats
  library(patchwork)    # for combining plots
  library(viridis)      # for continuous color scales
})

# Set the base and results directory explicitly
base_dir    <- file.path(Sys.getenv("HOME"), "dead-zone-metagenomes-Metabolic-")
results_dir <- file.path(base_dir, "results", "analysis", "extra", "bin_abundance")

cat("👋 viz_bin_abundance.R starting at", Sys.time(), "\n")

# 1) Read the percent‐abundance table and tidy it
pct_file <- file.path(results_dir, "bin_abundance_pct.tsv")
if (!file.exists(pct_file)) {
  stop("Percent-abundance file not found: ", pct_file)
}
# read with no type messages
pct <- read_tsv(pct_file, show_col_types = FALSE)
# rename first unnamed column to 'bin'
names(pct)[1] <- "bin"

# reshape to long format
 df_long <- pct %>%
  pivot_longer(
    cols     = -bin,
    names_to = "Sample",
    values_to = "Pct"
  ) %>%
  mutate(
    # order bins by their max abundance across samples
    bin    = fct_reorder(bin, Pct, .fun = max),
    # ensure samples appear in file-order
    Sample = factor(Sample, unique(Sample))
  )

# 2) Horizontal point‐plots faceted by sample
p1 <- df_long %>%
  ggplot(aes(x = Pct, y = bin, color = Sample)) +
  geom_point(size = 3) +
  facet_wrap(~ Sample, scales = "free_y") +
  labs(
    title = "MAG abundances by sample (top view)",
    x     = "Relative abundance (%)",
    y     = "Bin"
  ) +
  theme_bw() +
  theme(
    legend.position = "none",
    strip.text      = element_text(face = "bold"),
    axis.text.y     = element_text(size = 7),
    plot.title      = element_text(hjust = 0.5)
  )

# 3) Stacked bar‐chart of community composition
p2 <- df_long %>%
  ggplot(aes(x = Sample, y = Pct, fill = bin)) +
  geom_col(width = 0.7) +
  labs(
    title = "Community composition by MAG",
    x     = "Sample",
    y     = "Relative abundance (%)",
    fill  = "Bin"
  ) +
  theme_bw() +
  theme(
    axis.text.x     = element_text(angle = 45, hjust = 1),
    legend.position = "right",
    plot.title      = element_text(hjust = 0.5)
  )

# 4) Heatmap of bin × sample
p3 <- df_long %>%
  ggplot(aes(x = Sample, y = bin, fill = Pct)) +
  geom_tile(color = "white", linewidth = 0.3) +
  scale_fill_viridis_c(name = "% abundance") +
  labs(
    title = "Heatmap of MAG abundances",
    x     = "Sample",
    y     = "Bin"
  ) +
  theme_minimal(base_size = 12) +
  theme(
    axis.text.x     = element_text(angle = 45, hjust = 1),
    axis.text.y     = element_text(size = 7),
    plot.title      = element_text(hjust = 0.5),
    legend.position = "bottom"
  )

# 5) Combine with patchwork
combined <- (p1 | p2) / p3 +
  plot_annotation(
    title = "DNA‐based MAG Abundance Visualizations",
    theme = theme(plot.title = element_text(size = 16, face = "bold", hjust = 0.5))
  )

# 6) Save
out_file <- file.path(results_dir, "combined_bin_abundance_viz.png")
ggsave(out_file, combined, width = 12, height = 14, dpi = 150)

message("✅ Composite figure written to: ", out_file)

cat("✅ viz_bin_abundance.R finished at", Sys.time(), "\n")

