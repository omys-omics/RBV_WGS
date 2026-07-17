#!/bin/bash
#SBATCH --job-name=tree
#SBATCH --partition=sixhour
#SBATCH --time=6:00:00
#SBATCH --mem=61G
#SBATCH --nodes=1
#SBATCH --ntasks=1
#SBATCH --output=out.%j.tree.txt


# Use msa_to_vcf.py to convert from fasta alignment (all.mitogenomes.aligned.fasta) to vcf
# Use vcf2phylip.py to convert from vcf to phylip 
#   Available here: https://github.com/edgardomortiz/vcf2phylip

module load bioconda

output_dir=04.iqtree
mkdir $output_dir

iqtree -s all.mitogenomes.aligned.min4.phy -m MFP -bb 1000 -nt AUTO -pre $output_dir/mitogenome
#-s specifies the input sequence data
#-m MFP specifies to perform model testing and use the best model of sequence evolution
#-bb specifies performing 1000 ultrafast bootstraps to assess support
#-o specify outgroup
#-nt AUTO allows the program to use the optimal number of threads (15 specified here)
#-pre prefix for output






