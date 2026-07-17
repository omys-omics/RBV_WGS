#!/bin/bash
#SBATCH --job-name=filter
#SBATCH --partition=colella
#SBATCH --time=100:00:00
#SBATCH --mem=500G
#SBATCH --nodes=1
#SBATCH --ntasks=32
#SBATCH --output=outputs/out.%j.filter.txt



module load bcftools

date

out_dir=/kuhpc/scratch/bi/b686w673/009.RBV.WGS/12.call.all.sites


# Filter
# 1. Get rid of sites with more than 2 alleles, only keeps snps (not mnps)
# 2. Remove sites that are outside of 2 standard deviations for the following statistics
bcftools view --threads 96 -M2 \
  -e 'RPBZ<-2 || RPBZ>2 || MQBZ<-2 || MQBZ>2 || MQSBZ<-2 || MQSBZ>2 || BQBZ<-2 || BQBZ>2 || SCBZ<-2 || SCBZ>2' \
  $out_dir/03.raw.no.outgroup.vcf.gz -Oz -o $out_dir/04.filtered.vcf.gz
  #-M2 print sites with at most INT alleles listed in REF and ALT columns.
  # RPBZ Mann-Whitney U-z test of Read Position Bias (closer to 0 is better)
  # MQBZ Mann-Whitney U-z test of Mapping Quality Bias (closer to 0 is better)
  # MQSBZ Mann-Whitney U-z test of Mapping Quality vs Strand Bias (closer to 0 is better)
  # BQBZ Mann-Whitney U-z test of Base Quality Bias (closer to 0 is better)
  # SCBZ Mann-Whitney U-z test of Soft-Clip Length Bias (closer to 0 is better)

bcftools index $out_dir/04.filtered.vcf.gz
bcftools stats $out_dir/04.filtered.vcf.gz > $out_dir/04.filtered.txt



date




