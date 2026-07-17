#!/bin/bash
#SBATCH --job-name=hyperparam
#SBATCH --partition=sixhour
#SBATCH --time=6:00:00
#SBATCH --mem=61G
#SBATCH --nodes=1
#SBATCH --ntasks=48
#SBATCH --output=outputs/out.%j.hyperparam.txt


module load conda
conda activate /kuhpc/work/colella/lab_software/pyrho_env/


date

species=CLGA
echo $species

out_dir=/kuhpc/scratch/bi/b686w673/009.RBV.WGS/09.recombination.maps/03.pyrho/$species
Ne=/kuhpc/scratch/bi/b686w673/009.RBV.WGS/09.recombination.maps/02.smc++/$species/estimate.mask/$species.ftol1e-3.csv
table_file=/kuhpc/scratch/bi/b686w673/009.RBV.WGS/09.recombination.maps/03.pyrho/$species/$species.lookuptable.hdf

pyrho hyperparam --numthreads 48 --logfile 02.hyperparams.$species.logfile \
  --tablefile $table_file \
  --samplesize 26 \
  --mu 8.7e-9 \
  --ploidy 2 \
  --smcpp_file $Ne \
  --num_sims 20 \
  -o $out_dir/$species.hyperparams.txt
  # --samplesize   haploid sample size
  # --mu           The per-generation mutation rate.
  # --ploidy       <ploidy> should be set to 1 if using phased data and 2 for unphased genotype data
  # --smcpp_file   smc++ csv file to specify the size history.
  # --num_sims     Number of 1Mb regions to simulate [100].
  # -o             OUTFILE



date






