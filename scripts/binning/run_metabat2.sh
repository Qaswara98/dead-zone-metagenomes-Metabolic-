#!/bin/bash -l
#-------------------- Slurm directives --------------------#
#SBATCH -A uppmax2025-3-3                  # UPPMAX project account
#SBATCH -M snowy                           # Cluster name
#SBATCH -p core                            # Partition
#SBATCH -n 8                               # CPU cores (MetaBAT2 is multi-threaded)
#SBATCH -t 04:00:00                        # Time limit
#SBATCH --mem=32G                         # Memory allocation
#SBATCH -J metabat2_binning               # Job name
#SBATCH -D /home/abha6491/dead-zone-metagenomes-Metabolic-   # Project root
#SBATCH -o results/bins/metabat2_%j.out   # stdout log
#SBATCH -e results/bins/metabat2_%j.err   # stderr log
#SBATCH --mail-type=ALL                   # Email on all
#SBATCH --mail-user=abha6491@student.uu.se
#----------------------------------------------------------#

set -euo pipefail

# Load MetaBAT2 module
module load bioinfo-tools
module load MetaBat/2.12.1 || { echo "ERROR: MetaBat/2.12.1 module not found" >&2; exit 1; }

# Paths
ASM_FASTA=results/assembly_dna/simultaneous_assembly/final.contigs.fa
DEPTH_FILE=results/depth/depth.txt
OUT_DIR=results/bins

# Create output directory
mkdir -p "$OUT_DIR"

# Sanity checks
[[ -f "$ASM_FASTA" ]] || { echo "ERROR: Assembly FASTA not found: $ASM_FASTA" >&2; exit 1; }
[[ -f "$DEPTH_FILE" ]] || { echo "ERROR: Depth file not found: $DEPTH_FILE" >&2; exit 1; }

echo "Running MetaBAT2 on contigs and depth matrix..."

metabat2 \
  -i "$ASM_FASTA" \
  -a "$DEPTH_FILE" \
  -o "$OUT_DIR/bin" \
  -t 8

echo "MetaBAT2 binning completed. Bins available in $OUT_DIR"

