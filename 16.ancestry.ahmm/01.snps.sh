#!/bin/bash
#SBATCH --job-name=snps
#SBATCH --partition=colella
#SBATCH --time=100:00:00
#SBATCH --mem=500G
#SBATCH --nodes=1
#SBATCH --ntasks=16
#SBATCH --output=outputs/out.%j.snps.txt



module load bcftools

date

in_dir=/kuhpc/scratch/bi/b686w673/009.RBV.WGS/12.call.all.sites
out_dir=/kuhpc/scratch/bi/b686w673/009.RBV.WGS/16.ancestry_hmm/01.high.depth.filter
vcf=$in_dir/04.filtered.vcf.gz

#bcftools view --threads 96 -m2 -M2 -v snps -i 'AC!=AN' $vcf -Oz -o $out_dir/01.snps.vcf.gz
  #-m2 -M2 -v snps (view only biallelic snps)
  #AC: Total number of ALT alleles across all samples
  #AN: Total number of called alleles across all samples

bcftools index $out_dir/01.snps.vcf.gz
bcftools stats $out_dir/01.snps.vcf.gz > $out_dir/01.snps.txt


date




