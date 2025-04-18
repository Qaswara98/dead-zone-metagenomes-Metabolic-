#!/bin/bash
#SBATCH -A uppmax2025-3-3
#SBATCH -M snowy
#SBATCH -p core
#SBATCH -n 2
#SBATCH -t 02:00:00
#SBATCH -J quast_assembly
#SBATCH -o ~/dead-zone-metagenomes-Metabolic-/results/quast_assembly.%j.out
#SBATCH --mail-type=FAIL
#SBATCH --mail-user=abha6491@student.uu.se

# Load QUAST module
module load bioinfo-tools
module load quast/5.0.2

# Directory for storing results
RESULTS_DIR=~/dead-zone-metagenomes-Metabolic-/results

# Run QUAST for SRR4342137 assembly
quast.py -o ${RESULTS_DIR}/quast_output_SRR4342137 ~/dead-zone-metagenomes-Metabolic-/data/assemblies/SRR4342137_assembly/final.contigs.fa

# Run QUAST for SRR4342139 assembly
quast.py -o ${RESULTS_DIR}/quast_output_SRR4342139 ~/dead-zone-metagenomes-Metabolic-/data/assemblies/SRR4342139_assembly/final.contigs.fa

