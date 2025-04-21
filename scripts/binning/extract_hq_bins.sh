#!/usr/bin/env bash
set -euo pipefail

PROJECT_DIR="$HOME/dead-zone-metagenomes-Metabolic-"
QA_SUM="$PROJECT_DIR/results/checkm/qa_summary/high_quality_bins.tsv"

# MetaBAT’s direct bin FASTAs:
SRC_DIR="$PROJECT_DIR/results/bins"

# Where we want the HQ FASTAs:
DST_DIR="$PROJECT_DIR/results/checkm/bins_high_quality"
mkdir -p "$DST_DIR"

echo "Extracting high‑quality FASTAs from $SRC_DIR to $DST_DIR …"

awk -F $'\t' 'NR>1 { gsub(/\r/,"",$1); print $1 }' "$QA_SUM" | \
while read -r BIN; do
  echo "Processing $BIN …"
  found=0

  for ext in fa fna fasta; do
    SRC_FILE="$SRC_DIR/${BIN}.${ext}"
    if [[ -f "$SRC_FILE" ]]; then
      cp -v "$SRC_FILE" "$DST_DIR/${BIN}.fa"
      found=1
      break
    fi
  done

  if [[ $found -eq 0 ]]; then
    echo "  ! WARNING: no ${BIN}.{fa,fna,fasta} in $SRC_DIR"
  fi
done

echo "Done. $(ls -1 "$DST_DIR" | wc -l) FASTAs in $DST_DIR."

