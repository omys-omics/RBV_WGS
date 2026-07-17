#!/bin/bash
#SBATCH --job-name=pixy
#SBATCH --partition=colella
#SBATCH --time=7-00:00:00
#SBATCH --mem=500G
#SBATCH --nodes=1
#SBATCH --ntasks=48
#SBATCH --output=outputs/out.%j.pixy.txt

module load conda
conda activate /kuhpc/work/colella/lab_software/pixy2.0/

date


vcf=/kuhpc/scratch/bi/b686w673/009.RBV.WGS/12.call.all.sites/07.all.sites.vcf.gz
out_dir=/kuhpc/scratch/bi/b686w673/009.RBV.WGS/14.pixy
bed=/kuhpc/work/colella/ben/009.RBV.WGS/09.recombination.maps/03.pyrho/sliding.windows.100kb.10kb.bed
populations=/kuhpc/work/colella/ben/009.RBV.WGS/14.pixy/popmap.txt

pixy --n_cores 48 --stats pi watterson_theta tajima_d fst dxy --vcf $vcf --populations $populations --bed_file $bed --output_folder $out_dir --output_prefix pixy.100kb.10kb

date
