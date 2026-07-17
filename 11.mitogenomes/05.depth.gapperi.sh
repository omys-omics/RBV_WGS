#!/bin/bash
#SBATCH --job-name=gapperi
#SBATCH --partition=sixhour
#SBATCH --time=6:00:00
#SBATCH --mem=61G
#SBATCH --nodes=1
#SBATCH --ntasks=1
#SBATCH --output=outputs/out.%j.gapperi.depth.txt
#SBATCH --array=1-15

module load samtools

date


IDs="UAM20640 UAM50109 UAM59964 UAM59965 UAM59966 UAM59967 UAM59968 UAM59969 UAM59970 UAM59971 UAM59972 UAM59973 UAM59974 UAM59975 UAM59976"  


# figure out which FN of this iteration of the array
ID=$(echo "$IDs" | cut -f"${SLURM_ARRAY_TASK_ID}" -d" ")
echo $ID

in_dir=/kuhpc/work/colella/ben/009.RBV.WGS/11.mitogenomes/alignments


depth=`samtools depth -a -r NC_068811 $in_dir/$ID.sorted.bam | awk '{sum+=$3} END {print sum/NR}'`
printf "$ID\t"gapperi"\t$depth\n" >> 05.mitogenome.depth.txt


date




