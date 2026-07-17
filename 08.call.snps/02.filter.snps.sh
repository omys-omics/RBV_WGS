#!/bin/bash
#SBATCH --job-name=filter
#SBATCH --partition=bi
#SBATCH --time=100:00:00
#SBATCH --mem=250G
#SBATCH --nodes=1
#SBATCH --ntasks=12
#SBATCH --output=outputs/out.%j.filter.txt



module load bcftools

date

out_dir=/kuhpc/scratch/bi/b686w673/009.RBV.WGS/08.call.snps

# Compress
#bcftools view --threads 24 $out_dir/01.raw.snps.bcf -Oz -o $out_dir/01.raw.snps.vcf.gz
#bcftools index $out_dir/01.raw.snps.vcf.gz


#bcftools stats $out_dir/01.raw.snps.vcf.gz > $out_dir/01.raw.snps.txt

# Filter
# 1. Get rid of sites with more than 2 alleles, only keeps snps (not mnps)
# 2. Only keep sites that are variant within MY samples (not where the ref is the only difference)
bcftools view --threads 96 -m2 -M2 -v snps -i 'AC!=AN' \
  $out_dir/01.raw.snps.vcf.gz -Oz -o $out_dir/02.variant.vcf.gz
  #-m2 -M2 -v snps (view only biallelic snps)
  # RPBZ Mann-Whitney U-z test of Read Position Bias (closer to 0 is better)
  # MQBZ Mann-Whitney U-z test of Mapping Quality Bias (closer to 0 is better)
  # MQSBZ Mann-Whitney U-z test of Mapping Quality vs Strand Bias (closer to 0 is better)
  # BQBZ Mann-Whitney U-z test of Base Quality Bias (closer to 0 is better)
  # SCBZ Mann-Whitney U-z test of Soft-Clip Length Bias (closer to 0 is better)
  #AC: Total number of ALT alleles across all samples
  #AN: Total number of called alleles across all samples
bcftools stats $out_dir/02.variant.vcf.gz > $out_dir/02.variant.txt


# 3. Remove sites that are outside of 2 standard deviations for the following statistics
bcftools view --threads 96 -e 'RPBZ<-2 || RPBZ>2 || MQBZ<-2 || MQBZ>2 || MQSBZ<-2 || MQSBZ>2 || BQBZ<-2 || BQBZ>2 || SCBZ<-2 || SCBZ>2' \
  $out_dir/02.variant.vcf.gz -Oz -o $out_dir/03.quality.vcf.gz
  #-m2 -M2 -v snps (view only biallelic snps)
  # RPBZ Mann-Whitney U-z test of Read Position Bias (closer to 0 is better)
  # MQBZ Mann-Whitney U-z test of Mapping Quality Bias (closer to 0 is better)
  # MQSBZ Mann-Whitney U-z test of Mapping Quality vs Strand Bias (closer to 0 is better)
  # BQBZ Mann-Whitney U-z test of Base Quality Bias (closer to 0 is better)
  # SCBZ Mann-Whitney U-z test of Soft-Clip Length Bias (closer to 0 is better)
  #AC: Total number of ALT alleles across all samples
  #AN: Total number of called alleles across all samples
bcftools stats $out_dir/03.quality.vcf.gz > $out_dir/03.quality.txt



date




