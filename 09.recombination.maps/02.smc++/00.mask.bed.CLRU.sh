#!/bin/bash
#SBATCH --job-name=mask
#SBATCH --partition=sixhour
#SBATCH --time=6:00:00
#SBATCH --mem=10G
#SBATCH --nodes=1
#SBATCH --ntasks=1
#SBATCH --output=outputs/out.%j.mask.txt


module load bioconda

date

species=CLRU
echo $species

out_dir=/kuhpc/scratch/bi/b686w673/009.RBV.WGS/09.recombination.maps/02.smc++/$species/mask

gunzip $out_dir/*.stat.gz

# combine all the depths into one file
paste $out_dir/*.stat > $out_dir/$species.combined.txt


# get the average depth across individuals for each window
awk '{
  n=0; sum=0;
  for(i=8;i<=NF;i+=8) {sum+=$i; n++}
  print $1, $2, $3, $4, $5, $6, $7, sum/n
}' $out_dir/$species.combined.txt > $out_dir/$species.avg.100bp.depth.txt

awk '$8 < 2' $out_dir/$species.avg.100bp.depth.txt > $out_dir/$species.mask.depth.txt

# get columns for bed file, replace spaces with tabs, remove header column
awk '{ print $1, $2, $3 }' $out_dir/$species.mask.depth.txt | tr ' ' '\t' | awk '!/^#/' > $out_dir/$species.mask.bed

# Compress with bgzip
bgzip -c $species.mask.bed > $species.mask.bed.gz

# Index with tabix
tabix -p bed $species.mask.bed.gz

date






