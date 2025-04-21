#!/bin/bash -l
#-------------------- Slurm directives --------------------#
#SBATCH -A uppmax2025-3-3
#SBATCH -M snowy
#SBATCH -p core
#SBATCH -n 16                          # Number of CPU cores/threads
#SBATCH -t 07:00:00                    # Wall-time limit (HH:MM:SS)
#SBATCH --mem=32G                      # Total memory allocation
#SBATCH -J dna_mapping                 # Job name
#SBATCH -D /home/abha6491/dead-zone-metagenomes-Metabolic-   # Project root
#SBATCH -o results/mapping/dna_mapping_%j.out
#SBATCH -e results/mapping/dna_mapping_%j.err
#SBATCH --mail-type=ALL
#SBATCH --mail-user=abha6491@student.uu.se
#----------------------------------------------------------#

set -euo pipefail

# Load modules
module load bioinfo-tools
module load bwa/0.7.18
module load samtools/1.20

# Paths
date +"Starting mapping at %Y-%m-%d %H:%M:%S"
PROJECT_DIR=$PWD
RAW_READS_DIR=$PROJECT_DIR/data/raw_reads
ASM_DIR=$PROJECT_DIR/results/assembly_dna/simultaneous_assembly
CONTIGS=$ASM_DIR/final.contigs.fa
MAP_DIR=$PROJECT_DIR/results/mapping

# Create output directory
mkdir -p "$MAP_DIR"

# Sanity checks
[[ -f "$CONTIGS" ]] || { echo "ERROR: Contigs not found at $CONTIGS" >&2; exit 1; }

# Sample list
SAMPLES=(SRR4342129 SRR4342133)

# Index contigs (skip if index exists)
if [[ ! -f "${CONTIGS}.bwt" ]]; then
  echo "Indexing contigs with BWA..."
  bwa index "$CONTIGS"
else
  echo "BWA index already exists."
fi

# Map each sample separately
for S in "${SAMPLES[@]}"; do
  echo "Mapping sample $S..."
  R1="$RAW_READS_DIR/${S}_1.paired.trimmed.fastq.gz"
  R2="$RAW_READS_DIR/${S}_2.paired.trimmed.fastq.gz"

  [[ -f "$R1" && -f "$R2" ]] || { echo "ERROR: Missing reads for $S" >&2; exit 1; }

  bwa mem -t 16 "$CONTIGS" "$R1" "$R2" \
    | samtools view -@4 -b - \
    | samtools sort -@4 -o "$MAP_DIR/${S}_sorted.bam"

  samtools index "$MAP_DIR/${S}_sorted.bam"
  samtools flagstat "$MAP_DIR/${S}_sorted.bam" > "$MAP_DIR/${S}_flagstat.txt"
  echo "Finished mapping $S."
done

echo "All samples mapped successfully at $(date +'%Y-%m-%d %H:%M:%S')"

