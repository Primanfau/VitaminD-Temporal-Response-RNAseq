
#!/bin/bash
# Download and QC script

# Set directories (update paths as needed)
OUTDIR="data/raw"
METADATA="data/metadata/SraRunTable.csv"

# Download data (assumes sradownloader is installed)
python3 sradownloader --outdir $OUTDIR $METADATA

# Quality control
fastqc $OUTDIR/*.fastq -o $OUTDIR/fastqc/
multiqc $OUTDIR/fastqc/ -n multiQC -o $OUTDIR/multifastqc/

echo "QC completed. Check $OUTDIR/multifastqc/multiQC.html"