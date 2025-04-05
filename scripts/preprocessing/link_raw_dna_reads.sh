#!/bin/bash

# Link raw DNA-seq reads into the project's raw_reads folder
# Author: Abdullahi Haji
# Date: 2025-04-05

RAW_DATA_PATH="/proj/uppmax2025-3-3/Genome_Analysis/3_Thrash_2017/DNA_trimmed"
DEST_DIR="$HOME/dead-zone-metagenomes-Metabolic-/data/raw_reads"

mkdir -p "$DEST_DIR"
cd "$DEST_DIR" || exit 1

echo "Linking raw DNA reads from $RAW_DATA_PATH to $DEST_DIR"

for file in "$RAW_DATA_PATH"/*.fastq.gz; do
    ln -sf "$file" .
done

echo "Done. Linked DNA files:"
ls -lh "$DEST_DIR"/*.fastq.gz

