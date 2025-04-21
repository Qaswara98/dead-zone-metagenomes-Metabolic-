#!/bin/bash -l
#-------------------- Slurm directives --------------------#
#SBATCH -A uppmax2025-3-3                      # UPPMAX project account
#SBATCH -M snowy                               # Cluster name
#SBATCH -p core                                # Partition
#SBATCH -n 2                                   # CPU cores (depth summarization is I/O bound)
#SBATCH -t 01:00:00                            # Time limit
#SBATCH --mem=8G                               # Memory allocation
#SBATCH -J depth_summary                      # Job name
#SBATCH -D /home/abha6491/dead-zone-metagenomes-Metabolic-   # Project root
#SBATCH -o results/depth/depth_summary.%j.out # stdout log
#SBATCH -e results/depth/depth_summary.%j.err # stderr log
#SBATCH --mail-type=ALL                       # Email on all
#SBATCH --mail-user=abha6491@student.uu.se
#----------------------------------------------------------#

set -euo pipefail

#-------------------- Load modules ------------------------#
module load bioinfo-tools
module load MetaBat/2.12.1


# Create output directory
mkdir -p results/depth

# Input BAMs
BAMS=( \
  results/mapping/SRR4342129_sorted.bam \
  results/mapping/SRR4342133_sorted.bam 
)

# Sanity check: each BAM and its index must exist
for BAM in "${BAMS[@]}"; do
  [[ -f "$BAM" ]] || { echo "ERROR: BAM not found: $BAM" >&2; exit 1; }
  [[ -f "${BAM}.bai" ]] || { echo "ERROR: BAM index not found: ${BAM}.bai" >&2; exit 1; }
done

echo "Summarizing contig depths with jgi_summarize_bam_contig_depths..."

# Run depth summarization
jgi_summarize_bam_contig_depths \
  --outputDepth results/depth/depth.txt \
  "${BAMS[@]}"

echo "Depth table written to results/depth/depth.txt"

