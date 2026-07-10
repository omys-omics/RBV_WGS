#!/bin/bash
#SBATCH --job-name=fastqc
#SBATCH --partition=bi
#SBATCH --time=100:00:00
#SBATCH --mem=200G
#SBATCH --nodes=1
#SBATCH --ntasks=20
#SBATCH --output=out.%j.fastqc.txt

module load conda
conda activate /kuhpc/work/colella/lab_software/f_m

# FASTQC on fastq files
fastqs=`ls /kuhpc/scratch/bi/b686w673/009.RBV.WGS/01.raw.reads/20250611_NX2K-P4-PE150_BJW-RBV-WGS-5/20250611_NX2K-P4-PE150_BJW-RBV-WGS-5-Colella_FASTQ/*.fastq.gz`
num=`echo $fastqs | wc -w`
echo "Processing" $num "fastq files"

mkdir plate.5

fastqc -t 40 $fastqs -o plate.5/
#-t threads
#-o output directory

multiqc --title multiqc.plate.5 plate.5/


