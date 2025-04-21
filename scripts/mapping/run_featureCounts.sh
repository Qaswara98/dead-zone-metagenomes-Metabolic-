#!/bin/bash -l
#SBATCH -A uppmax2025-3-3
#SBATCH -M snowy
#SBATCH -p core
#SBATCH -n 1             # only need 1 task to launch subread
#SBATCH -t 02:00:00
#SBATCH --mem=16G
#SBATCH -J featureCounts
#SBATCH -o ~/dead-zone-metagenomes-Metabolic-/results/mapping/rna/featureCounts.%j.out
#SBATCH -e ~/dead-zone-metagenomes-Metabolic-/results/mapping/rna/featureCounts.%j.err
#SBATCH --mail-type=ALL
#SBATCH --mail-user=abha6491@student.uu.se

set -euo pipefail

module load bioinfo-tools
module load subread/2.0.3

# Paths
PROJECT=$HOME/dead-zone-metagenomes-Metabolic-
GFF=$PROJECT/results/annotation/combined/combined_bins.gff
OUT=$PROJECT/results/mapping/rna/rna_counts.txt
BAMS=(
  $PROJECT/results/mapping/rna/SRR4342137_sorted.bam
  $PROJECT/results/mapping/rna/SRR4342139_sorted.bam
)

# Make sure output dir exists
mkdir -p "$(dirname "$OUT")"

echo "Running featureCounts on ${#BAMS[@]} samples…"
featureCounts \
  -T 8 \
  -p \
  -B \
  -t CDS \
  -g ID \
  -a "$GFF" \
  -o "$OUT" \
  "${BAMS[@]}"

echo "✅ Counts written to $OUT (and $OUT.summary)"

