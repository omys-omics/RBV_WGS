#!/bin/bash
#SBATCH --job-name=align
#SBATCH --partition=bi
#SBATCH --time=400:00:00
#SBATCH --mem=61G
#SBATCH --nodes=1
#SBATCH --ntasks=12
#SBATCH --output=outputs/out.%j.alignment.txt
#SBATCH --array=54-73

#1-32 eeb
#33-53 colella
#54-73 bi

#module load bwa
#module load samtools

module load bioconda

IDs="FN2538 FN2551 FN2560 FN2562 FN3758 FN3761 FN3762 FN3788 FN3789 FN3790 FN3791 FN3797 FN3802 FN3819 FN3820 FN3835 FN3836 FN3837 FN3867 FN3878 FN3879 FN3880 FN505 FN506 FN534 FN547 FN550 FN572 FN602 FN603 FN605 FN608 MSB198512 MSB199067 MSB199079 MSB199080 MSB199082 MSB199092 MSB199096 MSB199104 MSB199112 MSB199119 MSB199121 MSB199122 MSB199126 MSB199127 MSB199129 MSB199132 MSB199133 MSB199134 MSB199135 MSB199136 MSB199138 UAM100160 UAM20640 UAM34216 UAM50109 UAM50293 UAM50296 UAM59964 UAM59965 UAM59966 UAM59967 UAM59968 UAM59969 UAM59970 UAM59971 UAM59972 UAM59973 UAM59974 UAM59975 UAM59976 UAM68436"  


# figure out which FN of this iteration of the array
ID=$(echo "$IDs" | cut -f"${SLURM_ARRAY_TASK_ID}" -d" ")
echo $ID

# find the fastq files
read1=/kuhpc/scratch/bi/b686w673/009.RBV.WGS/03.fastp/$ID.R1.fastq.gz
read2=/kuhpc/scratch/bi/b686w673/009.RBV.WGS/03.fastp/$ID.R2.fastq.gz

echo $read1
echo $read2

# assign the reference genome
ref=/kuhpc/work/colella/ben/009.RBV.WGS/00.rutilus.ref.genome/indexed/GCA_040207285.2_mMyoRut1_p1.0_genomic

#Make sure to start in correct directory
cd /kuhpc/work/colella/ben/009.RBV.WGS/06.alignments.CLRU/01.alignments

    
#Align raw reads to reference genome and convert to .bam
bwa mem -t 12 $ref $read1 $read2 | samtools view -b -@12 -o $ID.raw.bam
      # -t number of threads to use
      # -b output in bam format
      # -@ number of threads to use
      # -o output file name
    echo "aligned raw reads for $name"
    date
    
#Sort alignments by leftmost coordinates
samtools sort -@12 $ID.raw.bam -o $ID.sorted.bam
    # -o output file
    echo "sorted bam for $name"
    date    

#Remove unsorted bam
rm $ID.raw.bam

#Index sorted bam
samtools index -@12 $ID.sorted.bam



