#!/bin/bash
#SBATCH --job-name=align
#SBATCH --partition=sixhour
#SBATCH --time=6:00:00
#SBATCH --mem=120G
#SBATCH --nodes=1
#SBATCH --ntasks=48
#SBATCH --output=outputs/out.%j.alignment.txt
#SBATCH --array=1-15


module load bioconda

date

IDs="UAM20640 UAM50109 UAM59964 UAM59965 UAM59966 UAM59967 UAM59968 UAM59969 UAM59970 UAM59971 UAM59972 UAM59973 UAM59974 UAM59975 UAM59976"  

# figure out which FN of this iteration of the array
ID=$(echo "$IDs" | cut -f"${SLURM_ARRAY_TASK_ID}" -d" ")
echo $ID

# input fastq files
read1=/kuhpc/scratch/bi/b686w673/009.RBV.WGS/03.fastp/$ID.R1.fastq.gz
read2=/kuhpc/scratch/bi/b686w673/009.RBV.WGS/03.fastp/$ID.R2.fastq.gz

# assign the reference genome
ref=/kuhpc/work/colella/ben/009.RBV.WGS/11.mitogenomes/gapperi/NC_068811

#Make sure to start in correct directory
cd /kuhpc/scratch/bi/b686w673/009.RBV.WGS/11.mitogenomes/alignments/

    
#Align raw reads to reference genome and convert to .bam
bwa mem -t 48 $ref $read1 $read2 | samtools view -b -F 4 -@48 -o $ID.raw.bam
      # -t number of threads to use
      # -b output in bam format
      # -@ number of threads to use
      # -o output file name
      # -F exclude flags (4 means read is unmapped)
    echo "aligned raw reads for $name"
    date
    
#Sort alignments by leftmost coordinates
samtools sort -@48 $ID.raw.bam -o $ID.sorted.bam
    # -o output file
    echo "sorted bam for $name"
    date    

#Remove unsorted bam
rm $ID.raw.bam

#Index sorted bam
samtools index -@48 $ID.sorted.bam



date