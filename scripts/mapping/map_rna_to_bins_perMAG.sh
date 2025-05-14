#!/bin/bash -l
#SBATCH -A uppmax2025-3-3
#SBATCH -M snowy
#SBATCH -p core
#SBATCH -n 8                     # 8 threads for BWA/SAMtools
#SBATCH -t 08:00:00
#SBATCH --mem=24G
#SBATCH -J rna_map_perMAG
#SBATCH -o ~/dead-zone-metagenomes-Metabolic-/results/mapping/rna/%x.%j.out
#SBATCH -e ~/dead-zone-metagenomes-Metabolic-/results/mapping/rna/%x.%j.err
#SBATCH --mail-type=ALL
#SBATCH --mail-user=abha6491@student.uu.se
set -euo pipefail

module load bioinfo-tools bwa/0.7.18 samtools/1.20

# ─── PATHS ────────────────────────────────────────────────
PROJ=$HOME/dead-zone-metagenomes-Metabolic-
IDX_ROOT=$PROJ/results/mapping/reference/bwa_indexes     # built in previous step
RNA_DIR=$PROJ/data/trimmed_rna_v2                        # *_1/2.trimmed.fastq.gz
OUT_DIR=$PROJ/results/mapping/rna_perMAG
mkdir -p "$OUT_DIR"

SAMPLES=(SRR4342137 SRR4342139)        

# ─── MAIN LOOP ───────────────────────────────────────────
for IDX in "$IDX_ROOT"/bin.* ; do
    BIN=$(basename "$IDX")                      # e.g. bin.27
    REF="$IDX/$BIN"                             # the -p prefix used by bwa index

    echo "==> MAG $BIN  (reference prefix: $REF)"
    for S in "${SAMPLES[@]}" ; do
        F1=$RNA_DIR/${S}_1.trimmed.fastq.gz
        F2=$RNA_DIR/${S}_2.trimmed.fastq.gz
        [[ -f $F1 && -f $F2 ]] || { echo "Missing $S reads"; exit 1; }

        BAM=$OUT_DIR/${S}_${BIN}.sorted.bam
        FLAG=$OUT_DIR/${S}_${BIN}.flagstat.txt

        echo "   • Mapping sample $S → $BIN"
        bwa mem -t $SLURM_NTASKS "$REF" "$F1" "$F2" \
          | samtools view -Sb - \
          | samtools sort -@ $SLURM_NTASKS -m 1G -o "$BAM" -

        samtools index "$BAM"
        samtools flagstat "$BAM" > "$FLAG"
    done
done

echo " All MAG-specific BAMs saved in $OUT_DIR/"

