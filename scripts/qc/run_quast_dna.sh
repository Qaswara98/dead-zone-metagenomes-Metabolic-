#!/bin/bash -l
#-------------------- Slurm directives --------------------#
#SBATCH -A uppmax2025-3-3              # UPPMAX project account
#SBATCH -M snowy                       # Cluster name
#SBATCH -p core                        # Partition
#SBATCH -n 16                          # Number of CPU cores/threads
#SBATCH -t 02:00:00                    # Wall-time limit (HH:MM:SS)
#SBATCH --mem=32G                      # Total memory allocation
#SBATCH -J quast_analysis              # Job name
#SBATCH -D /home/abha6491/dead-zone-metagenomes-Metabolic-  # Project root directory
#SBATCH -o results/quast_dna/quast_analysis.%j.out  # Standard output
#SBATCH -e results/quast_dna/quast_analysis.%j.err  # Standard error
#SBATCH --mail-type=ALL              # Email on all
#SBATCH --mail-user=abha6491@student.uu.se
#----------------------------------------------------------#

set -euo pipefail  # Exit on error, undefined var, or failed pipe

# Load necessary modules
module load bioinfo-tools
module load quast/5.0.2

# Define paths
PROJECT_DIR=$PWD
CONTIGS=$PROJECT_DIR/results/assembly_dna/simultaneous_assembly/final.contigs.fa
OUT_DIR=$PROJECT_DIR/results/quast_dna/quast_analysis

# Create output directory
mkdir -p "$OUT_DIR"

# Sanity check: contigs file must exist
if [[ ! -f "$CONTIGS" ]]; then
  echo "ERROR: Contigs file not found at $CONTIGS" >&2
  exit 1
fi

echo "Running QUAST on $CONTIGS..."
quast.py \
  -t 16 \
  --large \
  --k-mer-stats \
  -o "$OUT_DIR" \
  "$CONTIGS"

echo "QUAST analysis completed successfully. Reports available in $OUT_DIR"

