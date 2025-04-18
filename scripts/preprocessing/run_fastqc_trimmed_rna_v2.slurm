#!/bin/bash
#SBATCH -A uppmax2025-3-3
#SBATCH -M snowy
#SBATCH -p core
#SBATCH -n 2
#SBATCH -t 01:00:00
#SBATCH -J fastqc_trimmed_v2
#SBATCH -o /home/abha6491/dead-zone-metagenomes-Metabolic-/results/fastqc_trimmed_v2.%j.out
#SBATCH --mail-type=FAIL
#SBATCH --mail-user=abha6491@student.uu.se

# Load modules
module load bioinfo-tools
module load FastQC/0.11.9

# Define paths
INPUT_DIR=/home/abha6491/dead-zone-metagenomes-Metabolic-/data/trimmed_rna_v2
OUTPUT_DIR=/home/abha6491/dead-zone-metagenomes-Metabolic-/results/QC_reports_trimmed_v2

# Make output directory if it doesn't exist
mkdir -p $OUTPUT_DIR

# Run FastQC
echo "Running FastQC on trimmed RNA reads (v2)..."
fastqc $INPUT_DIR/*.fastq.gz -o $OUTPUT_DIR
echo "FastQC finished ✅"

