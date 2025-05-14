#!/usr/bin/env bash
#SBATCH -A uppmax2025-3-3
#SBATCH -M snowy
#SBATCH -p core
#SBATCH -n 1
#SBATCH -t 01:00:00
#SBATCH --mem=4G
#SBATCH -J refine_tax_ids
#SBATCH -o /home/abha6491/dead-zone-metagenomes-Metabolic-/results/analysis/extra/taxonomy/refined_taxonomy/refine_tax_ids.%j.out
#SBATCH -e /home/abha6491/dead-zone-metagenomes-Metabolic-/results/analysis/extra/taxonomy/refined_taxonomy/refine_tax_ids.%j.err
#SBATCH --mail-type=ALL
#SBATCH --mail-user=abha6491@student.uu.se

set -euo pipefail

echo "Loading modules..."
module load R/4.3.1
module load R_packages/4.3.1

# Navigate to project root so relative paths resolve correctly
cd "$HOME/dead-zone-metagenomes-Metabolic-"

# Paths to scripts and output directories
SCRIPT="$HOME/dead-zone-metagenomes-Metabolic-/scripts/analysis/extra/taxonomy/inspect_refine_taxonomy.R"
REFINE_DIR="$HOME/dead-zone-metagenomes-Metabolic-/results/analysis/extra/taxonomy/refined_taxonomy"
DECORATED_TREE="$HOME/dead-zone-metagenomes-Metabolic-/results/checkm/bins_high_quality/gtdbtk/de_novo_wf/infer/gtdbtk.bac120.decorated.tree"

# Ensure output directory exists
mkdir -p "$REFINE_DIR"

echo "Running taxonomy refinement inspection script..."
Rscript --verbose "$SCRIPT" > "$REFINE_DIR/refine_tax_ids.log" 2>&1

echo "Copying decorated tree to refinement directory..."
cp "$DECORATED_TREE" "$REFINE_DIR/"

echo "Refinement inspection complete."
echo "Check logs and outputs in: $REFINE_DIR"

