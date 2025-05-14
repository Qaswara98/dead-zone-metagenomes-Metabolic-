#!/usr/bin/env bash
#SBATCH -A uppmax2025-3-3
#SBATCH -M snowy
#SBATCH -p core
#SBATCH -n 8
#SBATCH -t 08:00:00
#SBATCH --mem=32G
#SBATCH -J pathway_recon
#SBATCH -o /home/abha6491/dead-zone-metagenomes-Metabolic-/results/analysis/extra/pathways/eggnog/eggnog.%j.out
#SBATCH -e /home/abha6491/dead-zone-metagenomes-Metabolic-/results/analysis/extra/pathways/eggnog/eggnog.%j.err
#SBATCH --mail-type=ALL
#SBATCH --mail-user=abha6491@student.uu.se

set -euo pipefail

echo "Loading modules..."
module load bioinfo-tools
module load python/3.12.7

# Directories
PROJECT="$HOME/dead-zone-metagenomes-Metabolic-"
PROKKA_DIR="$PROJECT/results/annotation/prokka"
OUT_DIR="$PROJECT/results/analysis/extra/pathways/eggnog"

# Create output directory
mkdir -p "$OUT_DIR"

# Run eggNOG-mapper on each bin's proteins
for faa in "$PROKKA_DIR"/*/*.faa; do
  base=$(basename "$faa" .faa)
  echo "Mapping $base..."
  emapper.py \
    -i "$faa" \
    --output "$OUT_DIR/${base}_eggnog" \
    --cpu 8 \
    --data_dir /sw/data/eggnog  \
    --annotate_hits_table \
    --go_evidence_score  \
    --seed_orthology
done

# Combine outputs
echo "Combining annotation tables..."
python3 - << 'PYCODE'
import pandas as pd, glob, os
outdir = os.path.expanduser("$OUT_DIR")
all_files = glob.glob(os.path.join(outdir, "*_eggnog.emapper.annotations"))
df_list = []
for f in all_files:
    base = os.path.basename(f).replace("_eggnog.emapper.annotations","")
    tmp = pd.read_csv(f, sep='\t', comment='#')
    tmp['bin'] = base
    df_list.append(tmp)
combined = pd.concat(df_list, ignore_index=True)
combined.to_csv(os.path.join(outdir, 'combined_eggnog_annotations.tsv'), sep='\t', index=False)
print(f"Combined {len(all_files)} annotation tables into combined_eggnog_annotations.tsv")
PYCODE

echo "Pathway reconstruction complete."
echo "Results in: $OUT_DIR"

