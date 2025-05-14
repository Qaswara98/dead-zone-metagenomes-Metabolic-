#!/usr/bin/env Rscript

##───────────────────────────────────────────────────────────────────────────────
##  Top 10 expressed genes per MAG — horizontal bar chart (fixed pivot_longer)
##───────────────────────────────────────────────────────────────────────────────

suppressPackageStartupMessages({
  library(tidyverse)   # dplyr, purrr, ggplot2, readr, stringr, forcats
  library(tidytext)    # reorder_within(), scale_y_reordered()
})

## 1) I/O & parameters
counts_dir <- "~/dead-zone-metagenomes-Metabolic-/results/mapping/rna_perMAG/counts_perMAG"
gff_dir    <- "~/dead-zone-metagenomes-Metabolic-/results/annotation/prokka"
out_dir    <- "~/dead-zone-metagenomes-Metabolic-/results/analysis/gene_expression"
top_n      <- 10
keep_samps <- c("SRR4342137","SRR4342139")

dir.create(out_dir, recursive = TRUE, showWarnings = FALSE)

## 2) Read + normalize (FIXED)
expr_df <- list.files(counts_dir, pattern = "_counts\\.txt$", full.names = TRUE) %>%
  map_dfr(function(fp) {
    bin_name <- basename(fp) %>% str_remove("_counts\\.txt$")
    df <- read_tsv(fp, comment = "#", col_types = cols(), show_col_types = FALSE)

    # identify & rename sample columns
    samp_cols <- setdiff(names(df),
                         c("Geneid","Chr","Start","End","Strand","Length"))
    names(df)[match(samp_cols, names(df))] <- basename(samp_cols)
    samp_cols <- basename(samp_cols)

    df %>%
      select(Geneid, all_of(samp_cols)) %>%
      pivot_longer(
        cols      = all_of(samp_cols),
        names_to  = "RawSample",
        values_to = "Count"
      ) %>%
      mutate(
        Sample = str_extract(RawSample, "^SRR\\d+"),
        Bin    = bin_name
      ) %>%
      select(Geneid, Sample, Count, Bin)
  }) %>%
  filter(Sample %in% keep_samps) %>%
  group_by(Bin, Sample) %>%
  mutate(Rel = 100 * Count / sum(Count)) %>%
  ungroup()

## 3) Annotate
annot_df <- unique(expr_df$Bin) %>% 
  map_dfr(function(bin) {
    gff <- file.path(gff_dir, bin, paste0(bin, ".gff"))
    read_tsv(gff, comment = "#", col_names = FALSE, show_col_types = FALSE) %>%
      filter(X3 == "CDS") %>%
      pull(X9) %>%
      str_split(";") %>%
      map(~ set_names(
        str_split_fixed(.x, "=", 2)[,2],
        str_split_fixed(.x, "=", 2)[,1]
      )) %>%
      map_dfr(~ as.list(.x)) %>%
      transmute(
        Geneid  = ID,
        Product = ifelse(is.na(product), "hypothetical protein", product),
        Bin     = bin
      ) %>%
      distinct()
  })

expr_annot <- expr_df %>%
  left_join(annot_df, by = c("Bin","Geneid"))

## 4) Pick top N per bin
topN <- expr_annot %>%
  group_by(Bin, Geneid, Product) %>%
  summarize(MaxRel = max(Rel), .groups = "drop") %>%
  group_by(Bin) %>%
  slice_max(MaxRel, n = top_n) %>%
  ungroup()

plot_df <- expr_annot %>%
  semi_join(topN, by = c("Bin","Geneid")) %>%
  mutate(
    Label  = Geneid,  # or paste0(Geneid, ": ", Product)
    Sample = factor(Sample, keep_samps),
    Label  = reorder_within(Label, Rel, Bin)
  )

## 5) Plot horizontal bars
p <- ggplot(plot_df, aes(x = Rel, y = Label, fill = Sample)) +
  geom_col(position = position_dodge(width = 0.8), width = 0.7) +
  facet_wrap(~Bin, scales = "free_y", ncol = 3) +
  scale_y_reordered() +
  scale_fill_brewer(palette = "Set1", name = "Sample") +
  labs(
    title = paste("Top", top_n, "expressed genes per MAG"),
    x     = "Relative expression (% of bin total)",
    y     = NULL
  ) +
  theme_bw(base_size = 12) +
  theme(
    strip.text      = element_text(face = "bold"),
    axis.text.y     = element_text(size = 7),
    axis.text.x     = element_text(angle = 45, hjust = 1),
    legend.position = "top",
    plot.title      = element_text(hjust = 0.5)
  )

ggsave(
  file.path(out_dir, paste0("bin_gene_expression_top", top_n, "_barplot.png")),
  p, width = 12, height = 8, dpi = 150
)

message("✅ Done! See barplot at: ", file.path(out_dir, 
                                              paste0("bin_gene_expression_top", top_n, "_barplot.png")))

