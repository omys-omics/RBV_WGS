#!/bin/bash
#SBATCH --job-name=snps
#SBATCH --partition=bi
#SBATCH --time=14-00:00:00
#SBATCH --mem=250G
#SBATCH --nodes=1
#SBATCH --ntasks=24
#SBATCH --output=outputs/out.%j.CLGA.snps.txt

date

module load bcftools

#find the bam files
bams=`ls /kuhpc/work/colella/ben/009.RBV.WGS/06.alignments.CLRU/01.alignments/UAM59*.bam`
echo $bams
for bam in $bams
do
  KU=`basename $bam`
  echo $KU
done

# assign the reference genome
ref=/kuhpc/work/colella/ben/009.RBV.WGS/00.rutilus.ref.genome/GCA_040207285.2_mMyoRut1_p1.0_genomic.fna

# output directory
out_dir=/kuhpc/scratch/bi/b686w673/009.RBV.WGS/09.recombination.maps/01.call.snps

bcftools mpileup --threads 96 -a DP,AD -q 30 -Q 30 -Ou -f $ref $bams | bcftools call -f GQ -mv -V indels -Ou -o $out_dir/01.raw.snps.CLGA.bcf
#-G, --read-groups FILE

#-f the faidx index reference genome in the fasta format
#-a DP output the depth for each sample at each snp, AD output allelic depth
#-q minimum mapping quality for an alignment to be considered
#-Q minimum base quality for a base to be considered
#-Ou output uncompressed bcf
# Use the -Ou option when piping between bcftools subcommands 

#-f GQ output genotype quality ######## ADD THIS TO GET GENOTYPE QUALITY ##############
#-m multi-allelic caller
#-v output variant sites only
#-V indels  #skips indels
#-Ou output uncompressed bcf
#-Ov output a vcf

date






