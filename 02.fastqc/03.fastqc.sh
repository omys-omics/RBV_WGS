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
fastqs=`ls /kuhpc/scratch/bi/b686w673/009.RBV.WGS/01.raw.reads/colellalab-jccgc-bw-28742-pfWlkV7L13wl4-2j/*.fastq.gz`
num=`echo $fastqs | wc -w`
echo "Processing" $num "fastq files"

mkdir plate.3

fastqc -t 40 $fastqs -o plate.3/
#-t threads
#-o output directory

multiqc --title multiqc.plate.3 plate.3/


