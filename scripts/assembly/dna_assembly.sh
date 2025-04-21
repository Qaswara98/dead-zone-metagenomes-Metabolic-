#!/bin/bash -l
#-------------------- Slurm directives --------------------#
#SBATCH -A uppmax2025-3-3             # project account
#SBATCH -M snowy                      # cluster
#SBATCH -p core                       # standard core partition
#SBATCH -n 16                         # number of CPU cores
#SBATCH -t 07:00:00                   # wall‑clock time
#SBATCH --mem=32G                     # total memory
#SBATCH -J dna_assembly               # job name
#SBATCH -D /home/abha6491/dead-zone-metagenomes-Metabolic-   # start dir
#SBATCH -o /home/abha6491/dead-zone-metagenomes-Metabolic-/results/assembly_dna/assembly_dna.%j.out
#SBATCH -e /home/abha6491/dead-zone-metagenomes-Metabolic-/results/assembly_dna/assembly_dna.%j.err
#SBATCH --mail-type=ALL
#SBATCH --mail-user=abha6491@student.uu.se
#----------------------------------------------------------#

set -euo pipefail                          # safer bash: stop on error

#-------------------- Load software -----------------------#
module load bioinfo-tools
module load megahit/1.2.9

#-------------------- Project paths -----------------------#
PROJECT_DIR=$HOME/dead-zone-metagenomes-Metabolic-
RAW_READS_DIR=$PROJECT_DIR/data/raw_reads
ASSEMBLY_DIR=$PROJECT_DIR/results/assembly_dna
OUTPUT_DIR=$ASSEMBLY_DIR/simultaneous_assembly
TMP_DIR=$OUTPUT_DIR/tmp

mkdir -p "$ASSEMBLY_DIR"

#-------------------- Samples to co‑assemble --------------#
SAMPLES=(SRR4342129 SRR4342133)           # add more IDs if needed

#-------------------- Input‑file sanity check -------------#
echo "Checking raw reads…"
for SAMPLE in "${SAMPLES[@]}"; do
  for STRAND in 1 2; do
    FILE="$RAW_READS_DIR/${SAMPLE}_${STRAND}.paired.trimmed.fastq.gz"
    [[ -f $FILE ]] || { echo "ERROR: missing $FILE"; exit 1; }
  done
done
echo "All input files present."

#-------------------- Build comma‑separated read lists ----#
FWD_READS=""
REV_READS=""
for SAMPLE in "${SAMPLES[@]}"; do
  FWD_READS+="$RAW_READS_DIR/${SAMPLE}_1.paired.trimmed.fastq.gz,"
  REV_READS+="$RAW_READS_DIR/${SAMPLE}_2.paired.trimmed.fastq.gz,"
done
# remove the trailing comma
FWD_READS=${FWD_READS%,}
REV_READS=${REV_READS%,}

#-------------------- Clean previous run ------------------#
[[ -d $OUTPUT_DIR ]] && { echo "Removing old output…"; rm -rf "$OUTPUT_DIR"; }
[[ -d $TMP_DIR    ]] && { echo "Removing old tmp dir…"; rm -rf "$TMP_DIR"; }

#-------------------- Run Megahit -------------------------#
echo "Starting assembly…"
megahit \
  -1 "$FWD_READS" \
  -2 "$REV_READS" \
  -o "$OUTPUT_DIR" \
  --min-count 3 \                       # trims noise, saves RAM
  --k-min 21 --k-max 87 --k-step 12 \   # fewer, smaller k‑mer sizes
  --mem-flag 3 --kmin-1pass \           # most aggressive mem mode
  --num-cpu-threads 8                   # match SBATCH -n 8

echo "Assembly finished OK."

