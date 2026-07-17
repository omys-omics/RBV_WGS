#!/bin/bash
#SBATCH --job-name=merge
#SBATCH --partition=eeb
#SBATCH --time=200:00:00
#SBATCH --mem=250G
#SBATCH --nodes=1
#SBATCH --ntasks=24
#SBATCH --output=outputs/out.%j.merge.txt



module load bcftools

date


out_dir=/kuhpc/scratch/bi/b686w673/009.RBV.WGS/08.call.snps


# 5. Put all the samples back together
bcfs=`ls $out_dir/individual/*.depth.filtered.vcf.gz`
bcftools merge --threads 192 $bcfs -Oz -o $out_dir/05.depth.5.95.vcf.gz



date






