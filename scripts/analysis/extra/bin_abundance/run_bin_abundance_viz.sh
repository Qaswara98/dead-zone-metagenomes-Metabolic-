#!/usr/bin/env bash
#SBATCH -A uppmax2025-3-3
#SBATCH -M snowy
#SBATCH -p core
#SBATCH -n 1
#SBATCH -t 00:30:00
#SBATCH --mem=2G
#SBATCH -J bin_abundance_viz
#SBATCH -o /home/abha6491/dead-zone-metagenomes-Metabolic-/results/analysis/extra/bin_abundance/bin_abundance_viz.%j.out
#SBATCH -e /home/abha6491/dead-zone-metagenomes-Metabolic-/results/analysis/extra/bin_abundance/bin_abundance_viz.%j.err
#SBATCH --mail-type=ALL
#SBATCH --mail-user=abha6491@student.uu.se

set -euxo pipefail   # -x will echo each command

# 1) Load R + packages
module load R/4.3.1
module load R_packages/4.3.1

echo "=== WHICH Rscript ==="
which Rscript

echo "=== JOB START: $(date) ==="

# 3) Run in verbose mode so we see all library() calls
Rscript --verbose /home/abha6491/dead-zone-metagenomes-Metabolic-/scripts/analysis/extra/bin_abundance/viz_bin_abundance.R

echo "=== JOB END: $(date) ==="

