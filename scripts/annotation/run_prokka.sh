#!/bin/bash -l

# ------------------- SLURM DIRECTIVES ------------------- #
#SBATCH -A uppmax2025-3-3
#SBATCH -M snowy
#SBATCH -p core
#SBATCH -n 8                        # CPUs for Prokka
#SBATCH -t 04:00:00                 # wall‐time
#SBATCH --mem=32G                   # memory
#SBATCH -J prokka_bins              # job name
#SBATCH -o /home/abha6491/dead-zone-metagenomes-Metabolic-/results/annotation/prokka.%j.out
#SBATCH -e /home/abha6491/dead-zone-metagenomes-Metabolic-/results/annotation/prokka.%j.err
#SBATCH --mail-type=ALL
#SBATCH --mail-user=abha6491@student.uu.se
# -------------------------------------------------------- #

set -euo pipefail

module load bioinfo-tools
module load prokka/1.45-5b58020  

PROJECT_DIR=$HOME/dead-zone-metagenomes-Metabolic-
HQ_BINS=$PROJECT_DIR/results/checkm/bins_high_quality
PROKKA_OUT=$PROJECT_DIR/results/annotation/prokka
MERGED_OUT=$PROJECT_DIR/results/annotation/combined

mkdir -p "$PROKKA_OUT" "$MERGED_OUT"

echo "Starting Prokka annotation on high‑quality bins…"
for BIN_FASTA in "$HQ_BINS"/bin.*.fa; do
  BIN_NAME=$(basename "$BIN_FASTA" .fa)
  OUTDIR="$PROKKA_OUT/$BIN_NAME"
  mkdir -p "$OUTDIR"
  echo "  Annotating $BIN_NAME"
  prokka \
    --outdir "$OUTDIR" \
    --prefix "$BIN_NAME" \
    --cpus 8 \
    --kingdom Bacteria \
    --force \
    "$BIN_FASTA"
done

echo "Prokka annotation complete. Now merging GFFs…"
grep -h -v "^##FASTA" "$PROKKA_OUT"/bin.*/*.gff \
  > "$MERGED_OUT"/combined_bins.gff

echo "Merged GFF written to: $MERGED_OUT/combined_bins.gff"

