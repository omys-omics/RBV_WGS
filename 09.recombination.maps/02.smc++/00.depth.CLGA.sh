#!/bin/bash
#SBATCH --job-name=pandepth
#SBATCH --partition=sixhour
#SBATCH --time=6:00:00
#SBATCH --mem=10G
#SBATCH --nodes=1
#SBATCH --ntasks=28
#SBATCH --output=outputs/out.%j.pandepth.txt
#SBATCH --array=1-13


module load bioconda

date

bams=`ls /kuhpc/work/colella/ben/009.RBV.WGS/06.alignments.CLRU/01.alignments/UAM59*.bam`

# figure out which FN of this iteration of the array
bam=$(echo $bams | cut -f"${SLURM_ARRAY_TASK_ID}" -d" ")
echo $bam

species=CLGA
echo $species

ID=`basename $bam | cut -f1 -d"."`
echo $ID

out_dir=/kuhpc/scratch/bi/b686w673/009.RBV.WGS/09.recombination.maps/02.smc++/$species/mask

pandepth=/kuhpc/work/colella/lab_software/PanDepth/bin/pandepth

$pandepth -t 28 -i $bam -w 100 -o $out_dir/$ID.depth.100bp.windows



date






