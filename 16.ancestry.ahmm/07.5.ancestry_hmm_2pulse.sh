#!/bin/bash
#SBATCH --job-name=ahmm
#SBATCH --partition=colella
#SBATCH --time=60-00:00:00
#SBATCH --mem=400G
#SBATCH --nodes=1
#SBATCH --ntasks=1
#SBATCH --output=outputs/out.%j.ahmm.txt
#SBATCH --array=1-2

module load conda
conda activate /kuhpc/work/colella/lab_software/ahmm_armadillo/
export LD_LIBRARY_PATH=$CONDA_PREFIX/lib:$LD_LIBRARY_PATH

date


geos="BC SEAK"

# figure out which pop of this iteration of the array
geo=$(echo "$geos" | cut -f"${SLURM_ARRAY_TASK_ID}" -d" ")
echo $geo

out_dir=/kuhpc/scratch/bi/b686w673/009.RBV.WGS/16.ancestry_hmm
ancestry_hmm=/kuhpc/work/colella/lab_software/Ancestry_HMM/src/ancestry_hmm
input_file=$out_dir/03.ahmm.input.$geo.AIM10.CLGAr.txt
ploidy_file=/kuhpc/work/colella/ben/009.RBV.WGS/16.ancestry_hmm/ploidy.$geo.txt

mkdir $out_dir/$geo.2pulse.hi.ne.AIM10.CLGAr
cd $out_dir/$geo.2pulse.hi.ne.AIM10.CLGAr
pwd

echo $input_file

if [[ $geo == "BC" ]]
then
  rut=0.0783128
  gap=0.9216872
  rut_1=$(echo "scale=7; $rut / 2" | bc -l)
  rut_2=$(echo "scale=7; $rut / 2" | bc -l)

elif [[ $geo == "SEAK" ]]
then
  rut=0.01420663
  gap=0.98579337
  rut_1=$(echo "scale=8; $rut / 2" | bc -l)
  rut_2=$(echo "scale=8; $rut / 2" | bc -l)

fi

echo $rut
echo $gap
echo $rut_1
echo $rut_2

$ancestry_hmm -i $input_file -s $ploidy_file -a 2 $rut $gap -p 1 10000000 $gap -p 0 -100 -$rut_1 -p 0 -1000 -$rut_2 --tmax 1000000 --tmin 1 -b 50 1000 --ne 90166
# -a Required: Overall ancestry proportion -a [int] [double] [double]
#      This option specifies the number of ancestral populations (the first argument) and the overall ancestry proportion of each in the sample. 

# -p Required: Ancestry Pulses -p [int, ancestry type] [int, time before present] [double, proportion of ancestry] 

#In general, the initial ancestry type of the population, prior to ancestry pulses should be specified as an ancestry pulse with a time of the pulse set to be greater than the maximum time allowable in the program (--tmax, below).

#-b [int] [int] 	If bootstrap replicates are to be performed, specify –b and the number of bootstraps and the block size of bootstraps. E.g., “-b 10 1000” would indicate 10 bootstrap replicates each using a block size of 1000 SNPs. 

#--ne The effective population size, n. By default this number is multiplied by 2 to accommodate diploid populations
date
