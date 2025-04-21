#!/bin/bash -l
#-------------------- Slurm directives --------------------#
#SBATCH -A uppmax2025-3-3                # UPPMAX project account
#SBATCH -M snowy                         # Cluster (Snowy)
#SBATCH -p core                          # Partition
#SBATCH -n 4                             # CPU cores for CheckM
#SBATCH -t 04:00:00                      # Wall-time limit
#SBATCH --mem=32G                        # Memory allocation
#SBATCH -J checkm_bins                   # Job name
#SBATCH -D /home/abha6491/dead-zone-metagenomes-Metabolic-  # Project root
#SBATCH -o results/checkm/checkm_bins.%j.out  # Stdout log
#SBATCH -e results/checkm/checkm_bins.%j.err  # Stderr log
#SBATCH --mail-type=ALL                  # Email on all job events
#SBATCH --mail-user=abha6491@student.uu.se
#----------------------------------------------------------#

set -euo pipefail                        # Exit on error, undefined var, or failed pipe

# Load required modules
module load bioinfo-tools
module load CheckM/1.1.3
module load pplacer/1.1.alpha19

# Link CheckM data files into ~/.checkm for full functionality
DATA_SRC=/sw/bioinfo/CheckM/1.1.3/src/CheckM_data/2015_01_16
mkdir -p "$HOME/.checkm"
# Symlink HMMs
mkdir -p "$HOME/.checkm/hmms"
ln -svf "$DATA_SRC/hmms"/*.hmm "$HOME/.checkm/hmms/"
# Symlink Pfam DB
mkdir -p "$HOME/.checkm/pfam"
ln -svf "$DATA_SRC/pfam/Pfam-A.hmm.dat" "$HOME/.checkm/pfam/"
# Symlink genome tree data
mkdir -p "$HOME/.checkm/genome_tree"
ln -svf "$DATA_SRC/genome_tree"/* "$HOME/.checkm/genome_tree/"
# Symlink marker sets metadata
ln -svf "$DATA_SRC/selected_marker_sets.tsv" "$HOME/.checkm/selected_marker_sets.tsv"

# Verify data links
echo "CheckM data files linked in ~/.checkm:"
ls -l ~/.checkm | sed 's/^/  /'

# Define input and output directories
BINS_DIR=results/bins                   # Directory containing bin*.fa files
OUT_DIR=results/checkm                  # Output directory for CheckM results
mkdir -p "$OUT_DIR"

# Run CheckM lineage workflow
echo "Running CheckM lineage_wf on bins in $BINS_DIR..."
checkm lineage_wf \
  --reduced_tree \
  -x fa \
  "$BINS_DIR" \
  "$OUT_DIR"

echo "CheckM completed successfully. Key stats in $OUT_DIR/storage/bin_stats_ext.tsv"

