#!/bin/bash
#SBATCH -A uppmax2025-3-3
#SBATCH -M snowy
#SBATCH -p core
#SBATCH -n 2
#SBATCH -t 01:00:00
#SBATCH -J multiqc_rna_versions
#SBATCH -o /home/abha6491/dead-zone-metagenomes-Metabolic-/results/multiqc_rna_versions.%j.out
#SBATCH --mail-type=ALL
#SBATCH --mail-user=abha6491@student.uu.se

# Load required module
module load bioinfo-tools
module load MultiQC

echo "🔍 Running MultiQC for Trimmed RNA V1..."
multiqc ~/dead-zone-metagenomes-Metabolic-/results/QC_reports_trimmed \
  -o ~/dead-zone-metagenomes-Metabolic-/results/multiqc_trimmed_v1 \
  --force

echo "🔍 Running MultiQC for Trimmed RNA V2..."
multiqc ~/dead-zone-metagenomes-Metabolic-/results/QC_reports_trimmed_v2 \
  -o ~/dead-zone-metagenomes-Metabolic-/results/multiqc_trimmed_v2 \
  --force

echo "✅ MultiQC reports for both versions generated."

