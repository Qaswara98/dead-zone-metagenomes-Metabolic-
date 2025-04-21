#!/bin/bash -l
#SBATCH -A uppmax2025-3-3
#SBATCH -M snowy
#SBATCH -p core
#SBATCH -n 16                    # threads for BWA & samtools
#SBATCH -t 08:00:00
#SBATCH --mem=32G
#SBATCH -J rna_mapping_to_bins
#SBATCH -o ~/dead-zone-metagenomes-Metabolic-/results/mapping/rna/%x.%j.out
#SBATCH -e ~/dead-zone-metagenomes-Metabolic-/results/mapping/rna/%x.%j.err
#SBATCH --mail-type=ALL
#SBATCH --mail-user=abha6491@student.uu.se

set -euo pipefail

module load bioinfo-tools
module load bwa/0.7.18
module load samtools/1.20

PROJECT=$HOME/dead-zone-metagenomes-Metabolic-
REFDIR=$PROJECT/results/mapping/reference
RNADIR=$PROJECT/results/mapping/rna
RNA_IN=$PROJECT/data/trimmed_rna_v2    # trimmed RNA FASTQs

mkdir -p "$RNADIR"

COMBINED_FA=$REFDIR/combined_HQ_bins.fa

# sanity check
[[ -f $COMBINED_FA ]] || { echo "ERROR: Reference FASTA missing: $COMBINED_FA"; exit 1; }

for S in SRR4342137 SRR4342139; do
  echo "[$(date)] Mapping sample $S…"

  FWD="$RNA_IN/${S}_1.trimmed.fastq.gz"
  REV="$RNA_IN/${S}_2.trimmed.fastq.gz"
  BAM="$RNADIR/${S}_sorted.bam"
  FLAG="$RNADIR/${S}_flagstat.txt"

  [[ -f $FWD && -f $REV ]] || { echo "ERROR: Missing reads for $S"; exit 1; }

  bwa mem -t $SLURM_NTASKS "$COMBINED_FA" "$FWD" "$REV" \
    | samtools view -Sb - \
    | samtools sort -m 2G -@ $SLURM_NTASKS -o "$BAM"

  samtools index "$BAM"
  samtools flagstat "$BAM" > "$FLAG"

  echo "[$(date)] Done $S → $BAM + index + $FLAG"
done

echo "All RNA samples mapped. Outputs in $RNADIR/"

