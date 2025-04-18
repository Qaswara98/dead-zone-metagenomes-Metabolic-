#!/bin/bash
#SBATCH -A uppmax2025-3-3
#SBATCH -M snowy
#SBATCH -p core
#SBATCH -n 16  # 16 threads as per your previous script
#SBATCH -t 07:00:00
#SBATCH -J dna_mapping
#SBATCH -o ~/dead-zone-metagenomes-Metabolic-/results/assembly_dna.%j.out
#SBATCH --mail-type=ALL
#SBATCH --mail-user=abha6491@student.uu.se

# Load modules
module load bioinfo-tools
module load bwa/0.7.18
module load samtools/1.20

# Verify module loading
echo "Loaded modules: $(module list)"
which samtools
which bwa

# Directories
RAW_READS_DIR=~/dead-zone-metagenomes-Metabolic-/data/raw_reads
ASSEMBLY_DIR=~/dead-zone-metagenomes-Metabolic-/results/assembly_dna
OUTPUT_DIR="$ASSEMBLY_DIR/simultaneous_assembly"
CONTIGS="$ASSEMBLY_DIR/simultaneous_assembly/final.contigs.fa"

# Check raw reads
echo "Checking raw reads..."
for SAMPLE in "SRR4342129" "SRR4342133"; do
    for STRAND in 1 2; do
        FILE="$RAW_READS_DIR/${SAMPLE}_${STRAND}.paired.trimmed.fastq.gz"
        if [[ ! -f "$FILE" ]]; then
            echo "ERROR: Missing $FILE"
            exit 1
        fi
    done
done

# Indexing the contigs with BWA
echo "Indexing the contigs with BWA..."
bwa index $CONTIGS

# Prepare the read files for mapping
FWD_READS="$RAW_READS_DIR/SRR4342129_1.paired.trimmed.fastq.gz,$RAW_READS_DIR/SRR4342133_1.paired.trimmed.fastq.gz"
REV_READS="$RAW_READS_DIR/SRR4342129_2.paired.trimmed.fastq.gz,$RAW_READS_DIR/SRR4342133_2.paired.trimmed.fastq.gz"

# Starting BWA MEM to map reads to contigs
echo "Starting BWA MEM to map reads to contigs..."
bwa mem $CONTIGS $FWD_READS $REV_READS > mapped_reads.sam 2> bwa_mapping.log

# Convert SAM to BAM and sort
echo "Converting SAM to BAM and sorting..."
samtools view -Sb mapped_reads.sam | samtools sort -o mapped_reads_sorted.bam
samtools index mapped_reads_sorted.bam

# Check mapping stats
echo "Checking mapping stats..."
samtools flagstat mapped_reads_sorted.bam

# Check if mapping was successful
if [ $? -eq 0 ]; then
    echo "Mapping completed successfully!"
else
    echo "ERROR: Mapping failed."
    exit 1
fi

