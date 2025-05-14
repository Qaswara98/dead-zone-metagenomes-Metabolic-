#!/usr/bin/env bash
#SBATCH -A uppmax2025-3-3
#SBATCH -M snowy
#SBATCH -p core
#SBATCH -n 1
#SBATCH -t 00:05:00
#SBATCH --mem=1G
#SBATCH -J merge_bin_activity
#SBATCH -o ~/dead-zone-metagenomes-Metabolic-/results/mapping/rna_perMAG/counts_perMAG/summary/merge.%j.out
#SBATCH -e ~/dead-zone-metagenomes-Metabolic-/results/mapping/rna_perMAG/counts_perMAG/summary/merge.%j.err

set -euo pipefail

###############################################################################
# 1.  Locations
###############################################################################
PROJ=$HOME/dead-zone-metagenomes-Metabolic-
CNT_DIR=$PROJ/results/mapping/rna_perMAG/counts_perMAG         # input .txt files
OUT_DIR=$CNT_DIR/summary                                       # new sub-folder
OUT_TSV=$OUT_DIR/bin_activity_raw.tsv


SAMPLES=(SRR4342137 SRR4342139)

###############################################################################
# 2.  Merge
###############################################################################
mkdir -p "$OUT_DIR"
printf "binID\t%s\n" "$(IFS=$'\t'; echo "${SAMPLES[*]}")" > "$OUT_TSV"

for F in "$CNT_DIR"/bin.*_counts.txt; do
    BIN=$(basename "$F" _counts.txt)           # => bin.27 etc.
    # columns 7 & 8 are the read-pair counts for our two samples
    awk -v ID="$BIN" 'NR>2 {s1+=$7; s2+=$8} END{printf "%s\t%d\t%d\n",ID,s1,s2}' \
        "$F" >> "$OUT_TSV"
done

###############################################################################
# 3.  Quick sanity check
###############################################################################
echo "Merged table (first 10 rows):"
head -n 11 "$OUT_TSV" | column -t
echo -e "\nFinal file:  $OUT_TSV"

