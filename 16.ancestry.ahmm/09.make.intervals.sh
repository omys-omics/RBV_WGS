#!/bin/bash
#SBATCH --job-name=intervals
#SBATCH --partition=sixhour
#SBATCH --time=1:00:00
#SBATCH --mem=1G
#SBATCH --nodes=1
#SBATCH --ntasks=1
#SBATCH --output=outputs/out.%j.intervals.txt
#SBATCH --array=1-26


# Script written with assistance from ChatGPT

date


# figure out which id of this iteration of the array
id=$(cat popmap.BC.sorted.txt popmap.SEAK.sorted.txt | awk '$2 == "admixed" {print}'  | cut -f1 | sed -n "${SLURM_ARRAY_TASK_ID}p")
echo $id

out_dir=/kuhpc/scratch/bi/b686w673/009.RBV.WGS/16.ancestry_hmm/1pulse.hi.ne.AIM10.CLGAr
mkdir $out_dir/intervals


# Combine adjacent chunks of the same ancestry to make larger ancestry intervals
awk '
BEGIN { OFS="\t" }
{
    # $1 = sample, $2 = chr, $3 = pos, $4 = value

    if (NR==1) {
        sample=$1; chr=$2; start=$3; last=$3; val=$4;
        next;
    }

    # If same sample, same chr, and same value, then extend interval
    if ($1==sample && $2==chr && $4==val) {
        last=$3;
    } else {
        # Otherwise, close previous interval
        print sample, chr, start, last, val;
        sample=$1; chr=$2; start=$3; last=$3; val=$4;
    }
}
END {
    # print final interval
    print sample, chr, start, last, val;
}' $out_dir/beds/$id.ancestry_hmm.bed > $out_dir/intervals/$id.ancestry_hmm.intervals.bed




date
