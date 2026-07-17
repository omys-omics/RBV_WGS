#!/bin/bash
#SBATCH --job-name=index
#SBATCH --partition=sixhour
#SBATCH --time=6:00:00
#SBATCH --mem=61G
#SBATCH --nodes=1
#SBATCH --ntasks=1
#SBATCH --output=outputs/out.%j.index.txt
#SBATCH --array=1

module load bcftools

date

species2="CLRU CLGA"
  
# figure out which FN of this iteration of the array
species=$(echo "$species2" | cut -f"${SLURM_ARRAY_TASK_ID}" -d" ")
echo $species

cd /kuhpc/scratch/bi/b686w673/009.RBV.WGS/09.recombination.maps/01.call.snps/$species

tabix -p vcf 08.$species.smcpp.input.vcf.gz


date
