#!/bin/bash
#SBATCH -A uppmax2025-3-3
#SBATCH -M snowy
#SBATCH -p core
#SBATCH -n 2
#SBATCH -t 02:00:00
#SBATCH -J trim_rna
#SBATCH -o /home/abha6491/dead-zone-metagenomes-Metabolic-/results/trim_rna_reads.%j.out
#SBATCH --mail-type=ALL
#SBATCH --mail-user=abha6491@student.uu.se

# Load modules
module load bioinfo-tools
module load trimmomatic/0.39

# Set paths
RAW_DIR="/home/abha6491/dead-zone-metagenomes-Metabolic-/data/raw_reads"
TRIMMED_DIR="/home/abha6491/dead-zone-metagenomes-Metabolic-/data/trimmed_rna"
ADAPTERS="/sw/bioinfo/trimmomatic/0.39/rackham/adapters"

# Create output directory if it doesn't exist
mkdir -p "$TRIMMED_DIR"

# RNA sample names
declare -a SAMPLES=("SRR4342137" "SRR4342139")

# Run Trimmomatic PE for each pair
for SAMPLE in "${SAMPLES[@]}"; do
  echo "Trimming $SAMPLE..."

  trimmomatic PE -threads 2 -phred33 \
    "$RAW_DIR/${SAMPLE}.1.fastq.gz" "$RAW_DIR/${SAMPLE}.2.fastq.gz" \
    "$TRIMMED_DIR/${SAMPLE}_1.trimmed.fastq.gz" "$TRIMMED_DIR/${SAMPLE}_1.unpaired.fastq.gz" \
    "$TRIMMED_DIR/${SAMPLE}_2.trimmed.fastq.gz" "$TRIMMED_DIR/${SAMPLE}_2.unpaired.fastq.gz" \
    ILLUMINACLIP:${ADAPTERS}/TruSeq3-PE.fa:2:30:10 \
    LEADING:3 TRAILING:3 SLIDINGWINDOW:4:15 MINLEN:36

  echo "Finished trimming $SAMPLE"
done

echo " All RNA trimming complete!"

