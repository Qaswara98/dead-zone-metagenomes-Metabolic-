#!/bin/bash -l
# ------------------------------------------------------------
#SBATCH -A uppmax2025-3-3
#SBATCH -M snowy
#SBATCH -p core
#SBATCH -n 4
#SBATCH -t 4:00:00
#SBATCH --mem=2G
#SBATCH -J index_bins
#SBATCH -o ~/dead-zone-metagenomes-Metabolic-/results/mapping/reference/index_bins.%j.out
#SBATCH -e ~/dead-zone-metagenomes-Metabolic-/results/mapping/reference/index_bins.%j.err
#SBATCH --mail-type=ALL
#SBATCH --mail-user=abha6491@student.uu.se
# -----------------------------------------------------------

set -euo pipefail
# ------------------------------------------------------------
module load bioinfo-tools
module load bwa/0.7.18

# ------------------------------------------------------------

PROJECT=$HOME/dead-zone-metagenomes-Metabolic-
MAG_FASTA_DIR=$PROJECT/results/checkm/bins_high_quality
INDEX_ROOT=$PROJECT/results/mapping/reference/bwa_indexes

mkdir -p "$INDEX_ROOT"

echo "$(date)  Indexing each MAG separately …"

for BIN_FASTA in "$MAG_FASTA_DIR"/bin.*.fa; do
    BIN=$(basename "$BIN_FASTA" .fa)            # e.g. bin.27
    IDX_DIR="$INDEX_ROOT/$BIN"
    mkdir -p "$IDX_DIR"

    echo "  → $BIN  (index files in $IDX_DIR)"
    # -p lets us put the six index files *inside* IDX_DIR with a tidy basename
    bwa index -p "$IDX_DIR/$BIN" "$BIN_FASTA"
done

echo "$(date)  All done – indexes live under: $INDEX_ROOT/"

