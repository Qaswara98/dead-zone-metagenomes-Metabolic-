#!/bin/bash -l
# ---------------- SLURM DIRECTIVES ---------------- #
#SBATCH -A uppmax2025-3-3        # UPPMAX project
#SBATCH -M snowy                 # Cluster
#SBATCH -p core                  # Partition
#SBATCH -n 1                   
#SBATCH -t 00:30:00              
#SBATCH --mem=4G                 # Minimal RAM
#SBATCH -J combine_index_bins    # Job name
#SBATCH -o ~/dead-zone-metagenomes-Metabolic-/results/mapping/combine_bins.%j.out
#SBATCH -e ~/dead-zone-metagenomes-Metabolic-/results/mapping/combine_bins.%j.err
#SBATCH --mail-type=ALL
#SBATCH --mail-user=abha6491@student.uu.se
# ------------------------------------------------- #

set -euo pipefail

#### 1) Paths & directories ####
PROJECT=$HOME/dead-zone-metagenomes-Metabolic-
HQ_BIN_DIR=$PROJECT/results/checkm/bins_high_quality
REF_DIR=$PROJECT/results/mapping/reference
COMBINED_REF=$REF_DIR/combined_HQ_bins.fa

mkdir -p "$REF_DIR"

#### 2) Concatenate ####
echo "[$(date +%T)] Concatenating all HQ bin FASTAs → $COMBINED_REF"
cat "$HQ_BIN_DIR"/bin.*.fa > "$COMBINED_REF"
echo "[$(date +%T)] Done concatenation ($(wc -l < <(grep -c '^>' $COMBINED_REF)) contigs)"

#### 3) Indexing ####
echo "[$(date +%T)] Loading BWA and building index"
module load bioinfo-tools
module load bwa/0.7.18

bwa index "$COMBINED_REF"
echo "[$(date +%T)] BWA index built for $COMBINED_REF"

echo "All set! Reference and index are in $REF_DIR."

