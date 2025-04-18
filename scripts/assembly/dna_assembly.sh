#!/bin/bash 
#SBATCH -A uppmax2025-3-3
#SBATCH -M snowy
#SBATCH -p core
#SBATCH -n 16  # 16 threads as per your previous script
#SBATCH -t 07:00:00
#SBATCH --mem=32GB  # Requested memory, adjust as needed
#SBATCH -J dna_assembly
#SBATCH -o ~/dead-zone-metagenomes-Metabolic-/results/assembly_dna.%j.out
#SBATCH --mail-type=ALL
#SBATCH --mail-user=abha6491@student.uu.se

# Load modules
module load bioinfo-tools
module load megahit/1.2.9

# Directories
RAW_READS_DIR=~/dead-zone-metagenomes-Metabolic-/data/raw_reads
ASSEMBLY_DIR=~/dead-zone-metagenomes-Metabolic-/results/assembly_dna
OUTPUT_DIR="$ASSEMBLY_DIR/simultaneous_assembly"
mkdir -p $ASSEMBLY_DIR

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

# Prepare comma-separated lists for forward and reverse reads
FWD_READS=""
REV_READS=""
for SAMPLE in "SRR4342129" "SRR4342133"; do
    FWD_READS="${FWD_READS},$RAW_READS_DIR/${SAMPLE}_1.paired.trimmed.fastq.gz"
    REV_READS="${REV_READS},$RAW_READS_DIR/${SAMPLE}_2.paired.trimmed.fastq.gz"
done
FWD_READS="${FWD_READS#,}"  # Remove leading comma
REV_READS="${REV_READS#,}"

echo "Forward reads: $FWD_READS"
echo "Reverse reads: $REV_READS"

# Cleanup previous output directory if it exists
if [ -d "$OUTPUT_DIR" ]; then
    echo "Removing previous output directory..."
    rm -rf "$OUTPUT_DIR"
fi

# Cleanup temporary files
TEMP_DIR="$ASSEMBLY_DIR/simultaneous_assembly/tmp"
if [ -d "$TEMP_DIR" ]; then
    echo "Removing temporary files..."
    rm -rf "$TEMP_DIR"
fi

# Run Megahit with reduced k-max for memory optimization
echo "Starting assembly with Megahit..."
megahit -1 "$FWD_READS" \
        -2 "$REV_READS" \
        -o "$OUTPUT_DIR" \
        --min-count 2 \
        --k-min 21 --k-max 99 --k-step 6 \  # Reduced k-max to minimize memory usage
        --mem-flag 2 --kmin-1pass  # Memory optimization flag

# Check success
if [ $? -eq 0 ]; then
    echo "Assembly completed successfully!"
else
    echo "ERROR: Assembly failed."
    exit 1
fi

