#!/bin/bash
#SBATCH --job-name=depth
#SBATCH --partition=colella
#SBATCH --time=100:00:00
#SBATCH --mem=500G
#SBATCH --nodes=1
#SBATCH --ntasks=1
#SBATCH --output=outputs/out.%j.depth_quantiles.txt


module load bcftools

date

out_dir=/kuhpc/scratch/bi/b686w673/009.RBV.WGS/12.call.all.sites
file=$out_dir/04.filtered.vcf.gz

mkdir $out_dir/06.individual

# 1. Build tab-delimited file of depths
bcftools query -f '[%DP\t]\n' $file > $out_dir/depth_matrix.txt


# 2. Find the 95th percentile for each sample
conda activate /kuhpc/work/colella/lab_software/datamash

awk 'BEGIN{srand(192585)} rand() < 0.1' $out_dir/depth_matrix.txt | datamash perc:95 1-72 > quantiles_95.txt
# randomly sample ~10% of the sites (one site per line), because finding the percentile for the whole file takes too much memory
# 798456 is a random seed, so the output is random but reproducible


ids=`cat ids.txt`
depths=`cat quantiles_95.txt`
paste <(printf "%s\n" $ids) <(printf "%s\n" $depths) > sample_ids_quantiles.txt


awk 'BEGIN{srand(192585)} rand() < 0.1' $out_dir/depth_matrix.txt | datamash perc:5 1-72 > quantiles_5_50_95.txt
awk 'BEGIN{srand(192585)} rand() < 0.1' $out_dir/depth_matrix.txt | datamash perc:50 1-72 >> quantiles_5_50_95.txt
awk 'BEGIN{srand(192585)} rand() < 0.1' $out_dir/depth_matrix.txt | datamash perc:95 1-72 >> quantiles_5_50_95.txt



date






