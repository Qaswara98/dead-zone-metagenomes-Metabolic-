#!/usr/bin/env bash
#SBATCH -A uppmax2025-3-3
#SBATCH -M snowy
#SBATCH -p core
#SBATCH -n 16
#SBATCH -t 12:00:00
#SBATCH --mem=64G
#SBATCH -J gtdbtk_denovo

#SBATCH -o /home/abha6491/dead-zone-metagenomes-Metabolic-/results/checkm/bins_high_quality/gtdbtk/de_novo_wf/de_novo_wf.%j.out
#SBATCH -e /home/abha6491/dead-zone-metagenomes-Metabolic-/results/checkm/bins_high_quality/gtdbtk/de_novo_wf/de_novo_wf.%j.err

#SBATCH --mail-type=ALL
#SBATCH --mail-user=abha6491@student.uu.se

set -euxo pipefail

module load bioinfo-tools
module load GTDB-Tk/2.4.0
module load pplacer/1.1.alpha19

PROJECT=$HOME/dead-zone-metagenomes-Metabolic-
MAG_DIR=$PROJECT/results/checkm/bins_high_quality
OUT_DIR=$MAG_DIR/gtdbtk/de_novo_wf
mkdir -p "$OUT_DIR"


# If tree already exists, skip to avoid rerunning
if [[ -f "$OUT_DIR/bac120.markers.treefile" ]]; then
  echo "De novo tree already exists at $OUT_DIR/bac120.markers.treefile, skipping run."
  exit 0
fi

echo "$(date)  Running GTDB-Tk de_novo_wf on $(ls "$MAG_DIR"/*.fa | wc -l) MAGs"
gtdbtk de_novo_wf \
    --genome_dir      "$MAG_DIR" \
    --out_dir         "$OUT_DIR" \
    --extension       fa \
    --cpus            $SLURM_NTASKS \
    --tmpdir          "$SNIC_TMP" \
    --bacteria \
    --outgroup_taxon  p__Bacteroidota \
    --force

echo "$(date)  ✅ de_novo complete; tree at $OUT_DIR/bac120.markers.treefile"

