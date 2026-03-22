#!/bin/bash
#SBATCH -J RNA_Align
#SBATCH -p batch
#SBATCH -N 4
#SBATCH --ntasks-per-node 16
#SBATCH --mem 64gb
#SBATCH --time 48:00:00

SECONDS=0
echo "STAR Alignment for RNA"

# Load STAR module or use conda (adjust as needed)
module load star/2.7.10

# Directories (update these!)
GENOME_DIR=/path/to/GRCh38.p14_STAR
INPUT_DIR=/path/to/data/raw
OUTPUT_DIR=/path/to/data/processed/star_alignment
THREADS=72

cd $INPUT_DIR

for file in *.fastq; do
  base=$(basename $file .fastq)
  STAR --runThreadN $THREADS \
       --genomeDir $GENOME_DIR \
       --readFilesIn $file \
       --outFileNamePrefix $OUTPUT_DIR/${base}_ \
       --outSAMtype BAM SortedByCoordinate \
       --outSAMunmapped Within \
       --quantMode GeneCounts \
       --outSAMattributes Standard
  echo "Finished processing $file"
done

duration=$SECONDS
echo "$((duration / 3600)) hours and $(((duration % 3600)/60)) minutes and $((duration % 60)) seconds elapsed."