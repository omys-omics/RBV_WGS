#!/bin/bash
#SBATCH --job-name=stats
#SBATCH --partition=sixhour
#SBATCH --time=6:00:00
#SBATCH --mem=120G
#SBATCH --nodes=1
#SBATCH --ntasks=1
#SBATCH --output=outputs/out.%j.stats.txt
#SBATCH --array=1-27


date

module load bcftools

chromosomes="CM105764.1 CM105765.1 CM105766.1 CM105767.1 CM105768.1 CM105769.1 CM105770.1 CM105771.1 CM105772.1 CM105773.1 CM105774.1 CM105775.1 CM105776.1 CM105777.1 CM105778.1 CM105779.1 CM105780.1 CM105781.1 CM105782.1 CM105783.1 CM105784.1 CM105785.1 CM105786.1 CM105787.1 CM105788.1 CM105789.1 CM105790.1"

# figure out which chromosome of this iteration of the array
chromosome=$(echo "$chromosomes" | cut -f"${SLURM_ARRAY_TASK_ID}" -d" ")
echo $chromosome

in_dir=/kuhpc/scratch/bi/b686w673/009.RBV.WGS/12.call.all.sites/01.chromosomes
out_dir=/kuhpc/scratch/bi/b686w673/009.RBV.WGS/12.call.all.sites/01.stats

#bcftools index $in_dir/01.raw.$chromosome.bcf
bcftools stats $in_dir/01.raw.$chromosome.bcf > $out_dir/01.raw.$chromosome.stats.txt


date




