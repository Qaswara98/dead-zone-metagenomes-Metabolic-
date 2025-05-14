#!/usr/bin/env bash
#SBATCH -A uppmax2025-3-3
#SBATCH -M snowy
#SBATCH -p core
#SBATCH -n 16                     
#SBATCH -t 08:00:00
#SBATCH --mem=16G
#SBATCH -J gtdbtk_classify
#SBATCH -o /home/abha6491/dead-zone-metagenomes-Metabolic-/results/analysis/taxonomy/gtdbtk/classify.%j.out
#SBATCH -e /home/abha6491/dead-zone-metagenomes-Metabolic-/results/analysis/taxonomy/gtdbtk/classify.%j.err
#SBATCH --mail-type=ALL
#SBATCH --mail-user=abha6491@student.uu.se

set -euo pipefail

# Load GTDB-Tk and dependencies
module load python/3.8.7
module load gtdbtk/2.4.0
module load pplacer/1.1.alpha19

# Project paths\PROJECT=$HOME/dead-zone-metagenomes-Metabolic-
MAG_DIR=$PROJECT/results/checkm/bins_high_quality
OUTDIR=$PROJECT/results/analysis/taxonomy/gtdbtk
mkdir -p $OUTDIR

echo "$(date)  Running GTDB-Tk classify_wf on MAGs..."
# 1) Round 1: classification (marker-gene + pplacer)
gtdbtk classify_wf \
  --genome_dir      "$MAG_DIR" \
  --out_dir         "$OUTDIR/classify_wf" \
  --extension       fa \
  --prefix          my_project \
  --cpus            $SLURM_NTASKS \
  --pplacer_cpus    1 \
  --skip_ani_screen \
  --scratch_dir     "$SNIC_TMP" \
  --force

echo "$(date)  Running GTDB-Tk de_novo_wf to build full marker phylogeny..."
# 2) Round 2: de novo tree (requires domain and outgroup taxon)
gtdbtk de_novo_wf \
  --genome_dir        "$MAG_DIR" \
  --out_dir           "$OUTDIR/de_novo_wf" \
  --extension         fa \
  --cpus              $SLURM_NTASKS \
  --scratch_dir       "$SNIC_TMP" \
  --bacteria          \
  --outgroup_taxon    d__Archaea \
  --force

# Notify completion
echo "✅ GTDB-Tk workflows complete."
echo "  Summary TSV:   $OUTDIR/classify_wf/my_project.bac120.summary.tsv"
echo "  Marker tree:   $OUTDIR/de_novo_wf/bac120.markers.treefile"

