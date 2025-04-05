#!/bin/bash
#SBATCH -A uppmax2025-3-3
#SBATCH -M snowy
#SBATCH -p core
#SBATCH -n 2
#SBATCH -t 01:00:00
#SBATCH -J fastqc_trimmed_rna
#SBATCH -o /home/abha6491/dead-zone-metagenomes-Metabolic-/results/run_fastqc_trimmed_rna.%j.out
#SBATCH --mail-type=END
#SBATCH --mail-user=abha6491@student.uu.se

# Load required modules
module load bioinfo-tools
module load FastQC/0.11.9

# Set paths
TRIMMED_DIR=~/dead-zone-metagenomes-Metabolic-/data/trimmed_rna
OUT_DIR=~/dead-zone-metagenomes-Metabolic-/results/QC_reports_trimmed

mkdir -p "$OUT_DIR"

# Run FastQC on all trimmed files
fastqc ${TRIMMED_DIR}/*.trimmed.fastq.gz -o "$OUT_DIR"
fastqc ${TRIMMED_DIR}/*.unpaired.fastq.gz -o "$OUT_DIR"

echo "FastQC analysis on trimmed RNA reads completed!"

