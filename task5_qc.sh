#!/usr/bin/env bash
set -euo pipefail

sample="$1"
bam="$2"

samtools flagstat "$bam" > "${sample}.flagstat.txt"
total=$(samtools view -c -F 0x900 "$bam")
mapped=$(samtools view -c -F 0x904 "$bam")

awk -v sample="$sample" -v total="$total" -v mapped="$mapped" 'BEGIN {
    pct = total ? 100 * mapped / total : 0
    status = (total >= 10000 && pct >= 70) ? "PASS" : "REVIEW"
    print "sample\tprimary_reads\tmapped_primary_reads\tmapped_percent\tstatus"
    printf "%s\t%d\t%d\t%.2f\t%s\n", sample, total, mapped, pct, status
}' > "${sample}.qc.tsv"
