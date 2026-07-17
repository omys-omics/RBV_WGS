#!/bin/bash
#SBATCH --job-name=view
#SBATCH --partition=colella
#SBATCH --time=48:00:00
#SBATCH --mem=500G
#SBATCH --nodes=1
#SBATCH --ntasks=48
#SBATCH --output=outputs/out.%j.rmoutgroup.txt


module load bcftools

date

out_dir=/kuhpc/scratch/bi/b686w673/009.RBV.WGS/12.call.all.sites


bcftools view --threads 96 -s ^UAM34216 $out_dir/02.raw.concat.vcf.gz -Oz > $out_dir/03.raw.no.outgroup.vcf.gz
  #-s samples (^ means not that one)
bcftools index $out_dir/03.raw.no.outgroup.vcf.gz
bcftools stats $out_dir/03.raw.no.outgroup.vcf.gz > $out_dir/03.raw.no.outgroup.txt

date




