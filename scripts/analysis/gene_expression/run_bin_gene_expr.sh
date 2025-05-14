#!/usr/bin/env bash
#SBATCH -A uppmax2025-3-3
#SBATCH -M snowy
#SBATCH -p core
#SBATCH -n 1
#SBATCH -t 01:00:00
#SBATCH --mem=8G
#SBATCH -J gene_expr
#SBATCH -o /home/abha6491/dead-zone-metagenomes-Metabolic-/results/analysis/gene_expression/gene_expr.%j.out
#SBATCH -e /home/abha6491/dead-zone-metagenomes-Metabolic-/results/analysis/gene_expression/gene_expr.%j.err
#SBATCH --mail-type=ALL
#SBATCH --mail-user=abha6491@student.uu.se

set -euo pipefail

module load R/4.3.1
module load R_packages/4.3.1 

# run the Rscript (it will mkdir its own out_dir)
Rscript /home/abha6491/dead-zone-metagenomes-Metabolic-/scripts/analysis/gene_expression/bin_gene_expr.R

