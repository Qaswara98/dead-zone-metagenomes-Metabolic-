#!/bin/bash
#SBATCH -A uppmax2025-3-3
#SBATCH -M snowy
#SBATCH -p core
#SBATCH -n 4
#SBATCH -t 06:00:00
#SBATCH -J megahit_assembly
#SBATCH -o /home/abha6491/dead-zone-metagenomes-Metabolic-/results/megahit_assembly.%j.out
#SBATCH --mail-type=FAIL
#SBATCH --mail-user=abha6491@student.uu.se

module load bioinfo-tools
module load megahit/1.2.9

# Input and output directories
INPUT_DIR=~/dead-zone-metagenomes-Metabolic-/data/trimmed_rna_v2
OUTPUT_DIR=~/dead-zone-metagenomes-Metabolic-/data/assemblies

mkdir -p $OUTPUT_DIR

# Run Megahit assembly for RNA-seq data with --kmin-1pass to reduce memory usage
megahit -1 $INPUT_DIR/SRR4342137_1.trimmed.fastq.gz \
        -2 $INPUT_DIR/SRR4342137_2.trimmed.fastq.gz \
        -o $OUTPUT_DIR/SRR4342137_assembly \
        --kmin-1pass

megahit -1 $INPUT_DIR/SRR4342139_1.trimmed.fastq.gz \
        -2 $INPUT_DIR/SRR4342139_2.trimmed.fastq.gz \
        -o $OUTPUT_DIR/SRR4342139_assembly \
        --kmin-1pass

