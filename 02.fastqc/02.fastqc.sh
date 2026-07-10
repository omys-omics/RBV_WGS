#!/bin/bash
#SBATCH --job-name=fastqc
#SBATCH --partition=colella
#SBATCH --time=100:00:00
#SBATCH --mem=100G
#SBATCH --nodes=1
#SBATCH --ntasks=1
#SBATCH --output=out.%j.fastqc.txt

module load conda
conda activate /kuhpc/work/colella/lab_software/f_m

# FASTQC on fastq files
fastqs=`ls /kuhpc/work/colella/ben/009.RBV.WGS/20250325_NX2K-P4-PE150_BJW-RBV-WGS-2/20250325_NX2K-P4-PE150_BJW-RBV-WGS-2-Colella_FASTQ/FN*.fastq.gz`
num=`echo $fastqs | wc -w`
echo "Processing" $num "fastq files"

mkdir plate.2

fastqc -t 20 $fastqs -o plate.2/
#-t threads
#-o output directory

multiqc --title multiqc.plate.2 plate.2/


