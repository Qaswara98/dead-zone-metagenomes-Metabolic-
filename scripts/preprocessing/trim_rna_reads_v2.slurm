#!/bin/bash
#SBATCH -A uppmax2025-3-3
#SBATCH -M snowy
#SBATCH -p core
#SBATCH -n 2
#SBATCH -t 02:00:00
#SBATCH -J trim_rna_v2
#SBATCH -o /home/abha6491/dead-zone-metagenomes-Metabolic-/results/trimmed_v2_logs/trim_rna_reads_v2.%j.out
#SBATCH --mail-type=FAIL
#SBATCH --mail-user=abha6491@student.uu.se

# Load modules
module load bioinfo-tools
module load trimmomatic

# Define paths
PROJECT_DIR=~/dead-zone-metagenomes-Metabolic-
RAW_DIR="$PROJECT_DIR/data/raw_reads"
TRIMMED_DIR="$PROJECT_DIR/data/trimmed_rna_v2"
LOG_DIR="$PROJECT_DIR/results/trimmed_v2_logs"
ADAPTERS=/sw/bioinfo/trimmomatic/0.39/rackham/adapters/TruSeq3-PE.fa

# Create output directories if needed
mkdir -p "$TRIMMED_DIR"
mkdir -p "$LOG_DIR"

# Define samples
declare -a SAMPLES=("SRR4342137" "SRR4342139")

# Trimming loop
for SAMPLE in "${SAMPLES[@]}"; do
  echo "🔧 Trimming $SAMPLE..."

  trimmomatic PE -threads 2 -phred33 \
    "$RAW_DIR/${SAMPLE}.1.fastq.gz" "$RAW_DIR/${SAMPLE}.2.fastq.gz" \
    "$TRIMMED_DIR/${SAMPLE}_1.trimmed.fastq.gz" "$TRIMMED_DIR/${SAMPLE}_1.unpaired.fastq.gz" \
    "$TRIMMED_DIR/${SAMPLE}_2.trimmed.fastq.gz" "$TRIMMED_DIR/${SAMPLE}_2.unpaired.fastq.gz" \
    ILLUMINACLIP:$ADAPTERS:2:30:10 LEADING:5 TRAILING:5 SLIDINGWINDOW:4:20 MINLEN:50

  echo "Finished $SAMPLE"
done

echo "All trimming (v2) done!"

