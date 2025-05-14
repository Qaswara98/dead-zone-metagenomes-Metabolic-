#!/usr/bin/env bash
# ------------------------------------------------------------
# merge_counts_perMAG.sh
# Collects all per-MAG featureCounts tables into a single TSV
# ------------------------------------------------------------
set -euo pipefail

## ---- USER SETTINGS ---------------------------------------
COUNTS_DIR="$HOME/dead-zone-metagenomes-Metabolic-/results/mapping/rna_perMAG/counts_perMAG"
OUT_TABLE="$HOME/dead-zone-metagenomes-Metabolic-/results/mapping/rna_perMAG/all_bins_raw_counts.tsv"
## ----------------------------------------------------------

[[ -d $COUNTS_DIR ]] || { echo "ERR: $COUNTS_DIR not found"; exit 1; }

echo "▶  Merging $(ls "$COUNTS_DIR"/bin.*_counts.txt | wc -l) count tables …"
: > "$OUT_TABLE"    # truncate / create

# grab the true header (2nd line) from the first file
FIRST_FILE=$(ls "$COUNTS_DIR"/bin.*_counts.txt | head -n1)
awk 'NR==2{print; exit}' "$FIRST_FILE" >> "$OUT_TABLE"

# append body (skip first two header lines) of every table
for f in "$COUNTS_DIR"/bin.*_counts.txt; do
    tail -n +3 "$f" >> "$OUT_TABLE"
done

echo "✅  Combined table written to: $OUT_TABLE"
echo "    Preview:"
head -n 6 "$OUT_TABLE" | column -t

