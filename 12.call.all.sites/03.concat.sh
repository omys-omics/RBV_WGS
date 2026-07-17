#!/bin/bash
#SBATCH --job-name=concat
#SBATCH --partition=colella
#SBATCH --time=48:00:00
#SBATCH --mem=500G
#SBATCH --nodes=1
#SBATCH --ntasks=48
#SBATCH --output=outputs/out.%j.concat.txt


module load bcftools

date

in_dir=/kuhpc/scratch/bi/b686w673/009.RBV.WGS/12.call.all.sites/01.chromosomes
out_dir=/kuhpc/scratch/bi/b686w673/009.RBV.WGS/12.call.all.sites
bcfs=`ls $in_dir/*.bcf`
echo $bcfs

bcftools concat --threads 96 -Oz $bcfs > $out_dir/02.raw.concat.vcf.gz
bcftools index $out_dir/02.raw.concat.vcf.gz
bcftools stats $out_dir/02.raw.concat.vcf.gz > $out_dir/02.raw.concat.txt

date




