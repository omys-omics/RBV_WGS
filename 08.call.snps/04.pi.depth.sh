#!/bin/bash
#SBATCH --job-name=depth
#SBATCH --partition=bi
#SBATCH --time=72:00:00
#SBATCH --mem=503G
#SBATCH --nodes=1
#SBATCH --ntasks=1
#SBATCH --output=outputs/out.%j.depth.txt


module load R

date


file=/kuhpc/scratch/bi/b686w673/009.RBV.WGS/08.call.snps/04.goodnames.vcf.gz

R < 04.pi.depth.R $file --no-save

date






