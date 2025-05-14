#!/bin/bash -l
#SBATCH -A uppmax2025-3-3
#SBATCH -M snowy
#SBATCH -p core
#SBATCH -n 8               # featureCounts threads
#SBATCH -t 02:00:00
#SBATCH --mem=16G
#SBATCH -J fc_perMAG
#SBATCH -o ~/dead-zone-metagenomes-Metabolic-/results/mapping/rna_perMAG/featureCounts.%j.out
#SBATCH -e ~/dead-zone-metagenomes-Metabolic-/results/mapping/rna_perMAG/featureCounts.%j.err
#SBATCH --mail-type=ALL
#SBATCH --mail-user=abha6491@student.uu.se
set -euo pipefail

module load bioinfo-tools
module load subread/2.0.3   # featureCounts

# ─── paths ──────────────────────────────────────────────────────
PROJ=$HOME/dead-zone-metagenomes-Metabolic-
MAG_DIR=$PROJ/results/checkm/bins_high_quality            # bin.*.fa
BAM_DIR=$PROJ/results/mapping/rna_perMAG                  # *.sorted.bam
OUT_DIR=$BAM_DIR/counts_perMAG
mkdir -p "$OUT_DIR"

SAMPLES=(SRR4342137 SRR4342139)

echo "$(date)  featureCounts per MAG for ${#SAMPLES[@]} RNA libraries"

for BIN_FA in "$MAG_DIR"/bin.*.fa; do
    BIN=$(basename "$BIN_FA" .fa)                         # e.g. bin.27
    GFF=$PROJ/results/annotation/prokka/$BIN/$BIN.gff
    [[ -f $GFF ]] || { echo "WARN: no GFF for $BIN – skip"; continue; }

    # build BAM list that matches existing files
    BAM_LIST=()
    for S in "${SAMPLES[@]}"; do
        BAM_LIST+=("$BAM_DIR/${S}_${BIN}.sorted.bam")
    done

    # check they exist
    for B in "${BAM_LIST[@]}"; do
        [[ -f $B ]] || { echo "WARN: missing $B – skip $BIN"; continue 2; }
    done

    echo "  → $BIN  ( $(basename "$GFF"), ${#BAM_LIST[@]} BAMs )"
    featureCounts \
        -T $SLURM_NTASKS \
        -p -B --countReadPairs \
        -t CDS -g ID \
        -a "$GFF" \
        -o "$OUT_DIR/${BIN}_counts.txt" \
        "${BAM_LIST[@]}"
done

echo "$(date)  Done.  Count tables: $OUT_DIR/*_counts.txt"

