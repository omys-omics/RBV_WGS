#!/bin/bash
#SBATCH --job-name=fastqc
#SBATCH --partition=colella
#SBATCH --time=100:00:00
#SBATCH --mem=100G
#SBATCH --nodes=1
#SBATCH --ntasks=1
#SBATCH --output=out.%j.fastqc.txt

module load fastqc

# FASTQC on fastq files
fastqs=`ls /kuhpc/scratch/bi/b686w673/009.RBV.WGS/01.raw.reads/colellalab-wienspooledlib-UHI10t3rcFok0HF5/FN*.fastq.gz`
num=`echo $fastqs | wc -w`
echo "Processing" $num "fastq files"

mkdir plate.1

fastqc -t 12 $fastqs -o plate.1/
#-t threads
#-o output directory

multiqc --title multiqc.plate.1 plate.1/


