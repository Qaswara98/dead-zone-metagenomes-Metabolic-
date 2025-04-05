#!/bin/bash
# FastQC for RNA reads only

RAW_READS_DIR=~/dead-zone-metagenomes-Metabolic-/data/raw_reads
OUT_DIR=~/dead-zone-metagenomes-Metabolic-/results/QC_reports

mkdir -p "$OUT_DIR"

cd "$RAW_READS_DIR"

fastqc SRR4342137*.fastq.gz SRR4342139*.fastq.gz -o "$OUT_DIR"

