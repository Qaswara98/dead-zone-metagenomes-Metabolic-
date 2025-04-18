#!/bin/bash
#SBATCH -A uppmax2025-3-3
#SBATCH -M snowy
#SBATCH -p core
#SBATCH -n 16  # Number of threads
#SBATCH -t 02:00:00  # Max time limit
#SBATCH --mem=32GB  # Memory allocation
#SBATCH -J quast_analysis
#SBATCH -o ~/dead-zone-metagenomes-Metabolic-/results/qc/quast_analysis.%j.out
#SBATCH --mail-type=ALL
#SBATCH --mail-user=abha6491@student.uu.se

# Load modules
module load bioinfo-tools
module load quast/5.0.2

# Define directories
ASSEMBLY_DIR=~/dead-zone-metagenomes-Metabolic-/results/assembly_dna/simultaneous_assembly
OUTPUT_DIR=~/dead-zone-metagenomes-Metabolic-/results/qc

# Create output directory if it doesn't exist
mkdir -p $OUTPUT_DIR

# Define input assembly file
CONTIGS_FILE="$ASSEMBLY_DIR/final.contigs.fa"

# Run QUAST to assess assembly quality
echo "Running QUAST for assembly quality assessment..."
quast.py $CONTIGS_FILE -o $OUTPUT_DIR --threads 16

# Check success
if [ $? -eq 0 ]; then
    echo "QUAST analysis completed successfully!"
else
    echo "ERROR: QUAST analysis failed."
    exit 1
fi

