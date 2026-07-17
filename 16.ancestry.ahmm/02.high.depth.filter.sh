#!/bin/bash
#SBATCH --job-name=filter
#SBATCH --partition=colella
#SBATCH --time=100:00:00
#SBATCH --mem=250G
#SBATCH --nodes=1
#SBATCH --ntasks=16
#SBATCH --output=outputs/out.%j.filter.txt



module load bcftools

date

in_dir=/kuhpc/scratch/bi/b686w673/009.RBV.WGS/12.call.all.sites
out_dir=/kuhpc/scratch/bi/b686w673/009.RBV.WGS/16.ancestry_hmm/01.high.depth.filter
vcf_raw=$in_dir/02.raw.concat.vcf.gz
vcf_snps=$out_dir/01.snps.vcf.gz

# 1. Get INFO/DP for every site. This is the total number of raw reads summed across individuals.
# Performed on 02.raw.concat.vcf.gz, so is not skewed by other quality filters
##INFO=<ID=DP,Number=1,Type=Integer,Description="Raw read depth">
bcftools query -f '%DP\n' $vcf_raw > $out_dir/02.INFO.DP.txt

conda deactivate
module load conda
conda activate /kuhpc/work/colella/lab_software/datamash

# 2. Find the 95th quantile of depth
DP95=$(awk 'BEGIN{srand(192585)} rand() < 0.1' $out_dir/02.INFO.DP.txt | datamash perc:95 1)
echo $DP95

conda deactivate
module load bcftools

# 3. Identify every site that has overall depth that exceeds the 95th quantile. Output the chromosome and position, separated by tab.
bcftools query -f '%CHROM\t%POS' -i "INFO/DP > $DP95" $vcf_raw > $out_dir/02.HIGH.DP.coords

# 4. Filter the snps for sites that are NOT above the 95th quantile of total depth
bcftools view --threads 96 -T ^$out_dir/02.HIGH.DP.coords $vcf_snps -Oz -o $out_dir/02.high.dp.filter.vcf.gz
  # -T, --targets-file [^]FILE
bcftools index $out_dir/02.high.dp.filter.vcf.gz
bcftools stats $out_dir/02.high.dp.filter.vcf.gz > $out_dir/02.high.dp.filter.txt


date




