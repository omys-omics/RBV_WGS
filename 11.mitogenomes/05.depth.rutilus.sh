#!/bin/bash
#SBATCH --job-name=rutilus
#SBATCH --partition=sixhour
#SBATCH --time=6:00:00
#SBATCH --mem=61G
#SBATCH --nodes=1
#SBATCH --ntasks=1
#SBATCH --output=outputs/out.%j.rutilus.depth.txt
#SBATCH --array=1-58

module load samtools

date


IDs="FN2538 FN2551 FN2560 FN2562 FN3758 FN3761 FN3762 FN3788 FN3789 FN3790 FN3791 FN3797 FN3802 FN3819 FN3820 FN3835 FN3836 FN3837 FN3867 FN3878 FN3879 FN3880 FN505 FN506 FN534 FN547 FN550 FN572 FN602 FN603 FN605 FN608 MSB198512 MSB199067 MSB199079 MSB199080 MSB199082 MSB199092 MSB199096 MSB199104 MSB199112 MSB199119 MSB199121 MSB199122 MSB199126 MSB199127 MSB199129 MSB199132 MSB199133 MSB199134 MSB199135 MSB199136 MSB199138 UAM100160 UAM34216 UAM50293 UAM50296 UAM68436"  


# figure out which FN of this iteration of the array
ID=$(echo "$IDs" | cut -f"${SLURM_ARRAY_TASK_ID}" -d" ")
echo $ID

in_dir=/kuhpc/work/colella/ben/009.RBV.WGS/06.alignments.CLRU/01.alignments


depth=`samtools depth -a -r CM079637.2 $in_dir/$ID.sorted.bam | awk '{sum+=$3} END {print sum/NR}'`
printf "$ID\t"rutilus"\t$depth\n" >> 05.mitogenome.depth.txt


date




