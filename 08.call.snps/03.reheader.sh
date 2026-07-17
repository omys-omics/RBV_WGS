#!/bin/bash
#SBATCH --job-name=reheader
#SBATCH --partition=sixhour
#SBATCH --time=6:00:00
#SBATCH --mem=61G
#SBATCH --nodes=1
#SBATCH --ntasks=24
#SBATCH --output=outputs/out.%j.reheader.txt


module load bcftools

date

# add second column with what to rename to
#awk -F'/' '{file=$NF; sub(/\..*/,"",file); print $0" "file}' sample.names.txt > reheader.txt

# rename the samples in the vcf
out_dir=/kuhpc/scratch/bi/b686w673/009.RBV.WGS/08.call.snps
bcftools reheader --threads 96 -s reheader.txt $out_dir/03.quality.vcf.gz > $out_dir/04.goodnames.vcf.gz
  #-s samples which need to be renamed can be listed as "old_name new_name\n" pairs separated by whitespaces, each on a separate line.

date




