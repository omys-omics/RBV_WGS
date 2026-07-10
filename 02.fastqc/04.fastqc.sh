#!/bin/bash
#SBATCH --job-name=fastqc
#SBATCH --partition=colella
#SBATCH --time=100:00:00
#SBATCH --mem=200G
#SBATCH --nodes=1
#SBATCH --ntasks=20
#SBATCH --output=out.%j.fastqc.txt

module load conda
conda activate /kuhpc/work/colella/lab_software/f_m

# FASTQC on fastq files
fastqs=`ls /kuhpc/scratch/bi/b686w673/009.RBV.WGS/01.raw.reads/colellalab-jccgc-bw-28892-5j0LwCzqxPqGyTEv/*.fastq.gz`
num=`echo $fastqs | wc -w`
echo "Processing" $num "fastq files"

mkdir plate.4

fastqc -t 40 $fastqs -o plate.4/
#-t threads
#-o output directory

multiqc --title multiqc.plate.4 plate.4/


