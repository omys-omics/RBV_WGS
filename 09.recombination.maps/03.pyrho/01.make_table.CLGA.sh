#!/bin/bash
#SBATCH --job-name=lookuptable
#SBATCH --partition=sixhour
#SBATCH --time=6:00:00
#SBATCH --mem=250G
#SBATCH --nodes=1
#SBATCH --ntasks=12
#SBATCH --output=outputs/out.%j.lookuptable.txt


module load conda
conda activate /kuhpc/work/colella/lab_software/pyrho_env/


date

species=CLGA
echo $species

out_dir=/kuhpc/scratch/bi/b686w673/009.RBV.WGS/09.recombination.maps/03.pyrho/$species
Ne=/kuhpc/scratch/bi/b686w673/009.RBV.WGS/09.recombination.maps/02.smc++/$species/estimate.mask/$species.ftol1e-3.csv

pyrho make_table --numthreads 12 --logfile 01.make_table.$species.logfile \
  --samplesize 26 \
  --approx \
  --moran_pop_size 26 \
  --mu 8.7e-9 \
  --smcpp_file $Ne \
  -o $out_dir/$species.lookuptable.hdf
  # --samplesize         Maximum number of haplotypes in your sample.
  # --approx             Use the Moran approximation to compute the haplotype lookup table.
                       # we recommend setting <N> equal to <n>
  # --moran_pop_size     Number of particles to consider if using --approx.
  # --mu                 The per-generation mutation rate.
  # --smcpp_file smc++   csv file to specify the size history.
  # -o            OUTFILE


  # --ploidy       <ploidy> should be set to 1 if using phased data and 2 for unphased genotype data

#var  timepoint  size
#size1  present  90166
#size2  1048  189830
#size3  10723  8354
#size4  109750  84803

date






