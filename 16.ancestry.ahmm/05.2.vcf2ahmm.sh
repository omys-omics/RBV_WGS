#!/bin/bash
#SBATCH --job-name=vcf2ahmm
#SBATCH --partition=sixhour
#SBATCH --time=6:00:00
#SBATCH --mem=250G
#SBATCH --nodes=1
#SBATCH --ntasks=1
#SBATCH --output=outputs/out.%j.vcf2ahmm.txt
#SBATCH --array=1-2

# average recombination weight for CLGA
rmap=/kuhpc/work/colella/ben/009.RBV.WGS/09.recombination.maps/03.pyrho/CLGA/CLGA.genome.27.rmap
awk '{ sum += $4 * ($3 - $2); len +=($3 - $2) } END { print sum / len }' $rmap


module load conda

date

geos="BC SEAK"

# figure out which population of this iteration of the array
geo=$(echo "$geos" | cut -f"${SLURM_ARRAY_TASK_ID}" -d" ")
echo $geo


in_dir=/kuhpc/scratch/bi/b686w673/009.RBV.WGS/16.ancestry_hmm/01.high.depth.filter
out_dir=/kuhpc/scratch/bi/b686w673/009.RBV.WGS/16.ancestry_hmm
vcf=$in_dir/03.ahmm.input.vcf.gz
popmap=popmap.$geo.sorted.txt
ploidy_file=ploidy.$geo.3.txt

vcf2ahmm_bjw=/kuhpc/work/colella/ben/009.RBV.WGS/15.ancestry_hmm/vcf2ahmm_bjw.py

# Python script provided by ancestry_hmm modified by bjw to recognize AD as the 4th feature in the genotype line of vcf


# UNIFORM RECOMBINATION RATE

python3 $vcf2ahmm_bjw -v $vcf -s $popmap -r 3.34664e-09 --min_total 1 --min_diff 0.1 -o $ploidy_file > $out_dir/03.ahmm.input.$geo.AIM10.CLGAr.txt
# -v vcf file
# -s sample file
# -r uniform recombination rate per bp in morgans/bp (float)", default = 1e-8
# -m minimum distance between successive snps (int,bp)", default = 1000
#--min_total [int]" minimum number of samples in each ancestral population to consider a site. Default 10
#--min_diff [float]" minimum allele frequency difference between any pair of ancestral populations to include a site. i.e., this selects AIMs. Default 0.1
#-o ploidy file for ahmm input

#Where the sample2population mapping file is a text-based table with two columns.

#1. sample id exactly as it appears in the vcf file
#2. the population to which that individual belongs. This can be either one of the ancestral populations indicated with an integer (0,1,2..k), or the sample is admixed in which case the population must read "admixed"
#e.g.

#sample1 0
#sample2 0
#sample3 1
#sample4 1
#sample5 admixed

date
