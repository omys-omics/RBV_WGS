#!/bin/bash
#SBATCH --job-name=depth
#SBATCH --partition=bi
#SBATCH --time=48:00:00
#SBATCH --mem=250G
#SBATCH --nodes=1
#SBATCH --ntasks=1
#SBATCH --output=outputs/out.%j.depth_quantiles.txt


module load bcftools

date


file=/kuhpc/scratch/bi/b686w673/009.RBV.WGS/08.call.snps/04.goodnames.vcf.gz
out_dir=/kuhpc/scratch/bi/b686w673/009.RBV.WGS/08.call.snps
mkdir $out_dir/individual

# 1. Build tab-delimited file of depths
bcftools query -f '[%DP\t]\n' $file > $out_dir/depth_matrix.txt


# 2. Find the 95th percentile for each sample
conda activate /kuhpc/work/colella/lab_software/datamash

awk 'BEGIN{srand(798456)} rand() < 0.1' $out_dir/depth_matrix.txt | datamash perc:95 1-73 > quantiles_95.txt
# randomly sample ~10% of the sites (one site per line), because finding the percentile for the whole file takes too much memory
# 798456 is a random seed, so the output is random but reproducible


ids=`cat ids.txt`
depths=`cat quantiles_95.txt`
paste <(printf "%s\n" $ids) <(printf "%s\n" $depths) > sample_ids_quantiles.txt


awk 'BEGIN{srand(798456)} rand() < 0.1' $out_dir/depth_matrix.txt | datamash perc:5 1-73 > quantiles_5_50_95.txt
awk 'BEGIN{srand(798456)} rand() < 0.1' $out_dir/depth_matrix.txt | datamash perc:50 1-73 >> quantiles_5_50_95.txt
awk 'BEGIN{srand(798456)} rand() < 0.1' $out_dir/depth_matrix.txt | datamash perc:95 1-73 >> quantiles_5_50_95.txt



date






