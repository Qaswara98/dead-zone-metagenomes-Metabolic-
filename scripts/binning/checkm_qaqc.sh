#!/bin/bash -l

# ------------------- SLURM DIRECTIVES ------------------- #
#SBATCH -A uppmax2025-3-3
#SBATCH -M snowy
#SBATCH -p core
#SBATCH -n 4
#SBATCH -t 01:00:00
#SBATCH --mem=16G
#SBATCH -J checkm_qaqc
#SBATCH -o /home/abha6491/dead-zone-metagenomes-Metabolic-/results/checkm/checkm_qaqc.%j.out
#SBATCH -e /home/abha6491/dead-zone-metagenomes-Metabolic-/results/checkm/checkm_qaqc.%j.err
#SBATCH --mail-type=ALL
#SBATCH --mail-user=abha6491@student.uu.se
# -------------------------------------------------------- #

set -euo pipefail

module load bioinfo-tools
module load CheckM/1.1.3
module load pplacer/1.1.alpha19

# Paths
PROJECT_DIR=/home/abha6491/dead-zone-metagenomes-Metabolic-
CHECKM_DIR=$PROJECT_DIR/results/checkm
MARKER_FILE=$CHECKM_DIR/lineage.ms       # must lineage_wf run
ANALYZE_DIR=$CHECKM_DIR                  # contains both bins/ and storage/
QA_DIR=$CHECKM_DIR/qa_summary

mkdir -p "$QA_DIR"

# Run CheckM QA quietly, tab‑table format
checkm qa \
  --tab_table \
  -q \
  "$MARKER_FILE" \
  "$ANALYZE_DIR" \
  > "$QA_DIR/checkm_qc_summary.tsv"

echo "✅ CheckM QA complete. Summary at: $QA_DIR/checkm_qc_summary.tsv"

