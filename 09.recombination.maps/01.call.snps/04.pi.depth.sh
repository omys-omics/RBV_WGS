#!/bin/bash
#SBATCH --job-name=depth
#SBATCH --partition=colella
#SBATCH --time=24:00:00
#SBATCH --mem=480G
#SBATCH --nodes=1
#SBATCH --ntasks=1
#SBATCH --output=outputs/out.%j.depth.txt
#SBATCH --array=1


module load R

date

species2="CLRU CLGA"
  
# figure out which FN of this iteration of the array
species=$(echo "$species2" | cut -f"${SLURM_ARRAY_TASK_ID}" -d" ")
echo $species

file=/kuhpc/scratch/bi/b686w673/009.RBV.WGS/09.recombination.maps/01.call.snps/06.reheader.$species.vcf.gz

R < 04.pi.depth.R $file $species --no-save

date






