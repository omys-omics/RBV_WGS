#!/bin/bash
#SBATCH --job-name=decomp
#SBATCH --partition=sixhour
#SBATCH --time=6:00:00
#SBATCH --mem=61G
#SBATCH --nodes=1
#SBATCH --ntasks=24
#SBATCH --output=outputs/out.%j.decomp.txt
#SBATCH --array=1-2


module load bcftools

species2="CLRU CLGA"
  
# figure out which FN of this iteration of the array
species=$(echo "$species2" | cut -f"${SLURM_ARRAY_TASK_ID}" -d" ")
echo $species

out_dir=/kuhpc/scratch/bi/b686w673/009.RBV.WGS/09.recombination.maps/01.call.snps

bcftools view --threads 24 -Oz $out_dir/05.quality.$species.bcf > $out_dir/05.quality.$species.vcf.gz


bcftools reheader -s $species.rename.txt -o $out_dir/06.reheader.$species.vcf.gz $out_dir/05.quality.$species.vcf.gz






