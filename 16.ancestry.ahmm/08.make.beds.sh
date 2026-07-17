#!/bin/bash
#SBATCH --job-name=ahmm
#SBATCH --partition=sixhour
#SBATCH --time=6:00:00
#SBATCH --mem=1G
#SBATCH --nodes=1
#SBATCH --ntasks=1
#SBATCH --output=outputs/out.%j.beds.txt
#SBATCH --array=1-26



date


# figure out which id of this iteration of the array
id=$(cat popmap.BC.sorted.txt popmap.SEAK.sorted.txt | awk '$2 == "admixed" {print}' | cut -f1 | sed -n "${SLURM_ARRAY_TASK_ID}p")
echo $id

out_dir=/kuhpc/scratch/bi/b686w673/009.RBV.WGS/16.ancestry_hmm/1pulse.hi.ne.AIM10.CLGAr
mkdir $out_dir
mkdir $out_dir/beds
in_dir=/kuhpc/scratch/bi/b686w673/009.RBV.WGS/16.ancestry_hmm

# Make bed file where 4th column is most likely ancestry (2=gapperi, 1=het, 0=rutilus)
sed '1d' $in_dir/*.1pulse.hi.ne.AIM10.CLGAr/$id.posterior | awk -v id="$id" '
$3 > 0.95 { print id, $1, $2, 2; next }
$4 > 0.95 { print id, $1, $2, 1; next } 
$5 > 0.95 { print id, $1, $2, 0; next }
{ print id, $1, $2, "UNASSIGNED" }' > $out_dir/beds/$id.ancestry_hmm.bed



date