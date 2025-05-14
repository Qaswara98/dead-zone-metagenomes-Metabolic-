#!/bin/bash -l
#SBATCH -A uppmax2025-3-3
#SBATCH -M snowy
#SBATCH -p core
#SBATCH -n 16                       # threads for HMMER / ANI
#SBATCH -t 06:00:00
#SBATCH --mem=64G                   # ≥60 GB recommended for pplacer step
#SBATCH -J gtdbtk_classify
#SBATCH -o /home/abha6491/dead-zone-metagenomes-Metabolic-/results/checkm/bins_high_quality/gtdbtk/gtdbtk.%j.out
#SBATCH -e /home/abha6491/dead-zone-metagenomes-Metabolic-/results/checkm/bins_high_quality/gtdbtk/gtdbtk.%j.err
#SBATCH --mail-type=ALL
#SBATCH --mail-user=abha6491@student.uu.se

set -euo pipefail

module load bioinfo-tools
module load GTDB-Tk/2.4.0
module load pplacer/1.1.alpha19      # pplacer called internally

PROJECT=$HOME/dead-zone-metagenomes-Metabolic-
MAG_DIR=$PROJECT/results/checkm/bins_high_quality
OUT_DIR=$MAG_DIR/gtdbtk
mkdir -p "$OUT_DIR"

echo "$(date)  Running GTDB-Tk on $(ls "$MAG_DIR"/*.fa | wc -l) MAGs"

gtdbtk classify_wf \
    --genome_dir      "$MAG_DIR" \
    --out_dir         "$OUT_DIR" \
    --extension       fa \
    --prefix          my_project \
    --cpus            $SLURM_NTASKS \
    --pplacer_cpus    1 \
    --skip_ani_screen \
    --scratch_dir     "$SNIC_TMP" \
    --force

echo "$(date)  GTDB-Tk finished.  First lines of taxonomy summary:"
head -n 5 "$OUT_DIR"/my_project.bac120.summary.tsv | column -t

