#!/bin/bash
#SBATCH --job-name=optimize
#SBATCH --partition=sixhour
#SBATCH --time=6:00:00
#SBATCH --mem=120G
#SBATCH --nodes=1
#SBATCH --ntasks=12
#SBATCH --output=outputs/out.%j.optimize.txt
#SBATCH --array=1-28


module load conda
conda activate /kuhpc/work/colella/lab_software/pyrho_env/


date

species=CLRU
echo $species

chromosomes="CM105764.1 CM105765.1 CM105766.1 CM105767.1 CM105768.1 CM105769.1 CM105770.1 CM105771.1 CM105772.1 CM105773.1 CM105774.1 CM105775.1 CM105776.1 CM105777.1 CM105778.1 CM105779.1 CM105780.1 CM105781.1 CM105782.1 CM105783.1 CM105784.1 CM105785.1 CM105786.1 CM105787.1 CM105788.1 CM105789.1 CM105790.1 CM105791.1"

# figure out which chromosome of this iteration of the array
chromosome=$(echo "$chromosomes" | cut -f"${SLURM_ARRAY_TASK_ID}" -d" ")
echo $chromosome

out_dir=/kuhpc/scratch/bi/b686w673/009.RBV.WGS/09.recombination.maps/03.pyrho/$species/maps.13
vcf=/kuhpc/scratch/bi/b686w673/009.RBV.WGS/09.recombination.maps/03.pyrho/$species/vcfs.13/$species.$chromosome.vcf.gz
table_file=/kuhpc/scratch/bi/b686w673/009.RBV.WGS/09.recombination.maps/03.pyrho/$species/$species.lookuptable.13.hdf

pyrho optimize --numthreads 12 --logfile 03.optimize.$species.13.logfile \
  --vcffile $vcf \
  --windowsize 50 \
  --blockpenalty 15 \
  --tablefile $table_file \
  --ploidy 2 \
  -o $out_dir/$species.$chromosome.rmap
  # --windowsize     from hyperparam
  # --blockpenalty   from hyperparam.  Penalty to ensure smoothness. Larger penalties result in smoother recombination maps.
  # --ploidy         <ploidy> should be set to 1 if using phased data and 2 for unphased genotype data
  # -o            OUTFILE



date






