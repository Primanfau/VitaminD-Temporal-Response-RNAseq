#!/bin/bash
# featureCounts script

ANNOTATION="/path/to/gencode.v47.basic.annotation.gtf"
BAM_DIR="data/processed/star_alignment"
OUTPUT="data/processed/counts/RNA_featurecounts.txt"

featureCounts -T 4 -s 0 \
  -a $ANNOTATION \
  -o $OUTPUT \
  $BAM_DIR/*.out.bam

echo "featureCounts completed. Output: $OUTPUT"