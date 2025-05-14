#!/usr/bin/env bash
#SBATCH -A uppmax2025-3-3
#SBATCH -M snowy
#SBATCH -p core
#SBATCH -n 1
#SBATCH -t 01:00:00
#SBATCH --mem=4G
#SBATCH -J bin_abundance

#SBATCH -o /home/abha6491/dead-zone-metagenomes-Metabolic-/results/analysis/extra/bin_abundance/bin_abundance.%j.out
#SBATCH -e /home/abha6491/dead-zone-metagenomes-Metabolic-/results/analysis/extra/bin_abundance/bin_abundance.%j.err

#SBATCH --mail-type=ALL
#SBATCH --mail-user=abha6491@student.uu.se

set -euo pipefail

module load bioinfo-tools
module load python/3.8.7   # make sure pandas is available

PROJECT="$HOME/dead-zone-metagenomes-Metabolic-"
DEPTH="$PROJECT/results/depth/depth.txt"   # your DNA depth file
BINS="$PROJECT/results/checkm/bins_high_quality"
OUT_DIR="$PROJECT/results/analysis/extra/bin_abundance"
OUT_RAW="$OUT_DIR/bin_abundance_raw.tsv"
OUT_PCT="$OUT_DIR/bin_abundance_pct.tsv"

mkdir -p "$OUT_DIR"

python3 <<PYCODE
import pandas as pd, glob, os

# 1) load DNA depth table; drop any "-var" columns
depth = pd.read_csv(os.path.expanduser("$DEPTH"), sep="\t", index_col=0)
depth = depth.loc[:, ~depth.columns.str.endswith("-var")]

# 2) sum coverage × contig length per bin → total covered bases
res = {}
for fa in glob.glob(os.path.expanduser("$BINS/bin.*.fa")):
    binname = os.path.basename(fa).replace(".fa", "")
    contigs = [L[1:].strip() for L in open(fa) if L.startswith(">")]
    sub = depth.loc[depth.index.intersection(contigs)]
    if sub.empty:
        print(f"⚠️  Warning: no contigs for {binname} in depth table")
        continue
    lengths = sub.iloc[:, 1]         # contigLen column
    covmat  = sub.iloc[:, 2:]       # coverage columns
    cov     = covmat.multiply(lengths, axis=0).sum(axis=0)
    res[binname] = cov

df = pd.DataFrame(res).T.sort_index()
df.columns = [c.replace("coverage_","") for c in df.columns]

# 3) write raw and percent tables
df.to_csv(os.path.expanduser("$OUT_RAW"), sep="\t")
pct = df.div(df.sum(axis=0), axis=1) * 100
pct.to_csv(os.path.expanduser("$OUT_PCT"), sep="\t")
PYCODE

echo "✅ Bin abundance tables written to:"
echo "    $OUT_RAW"
echo "    $OUT_PCT"

