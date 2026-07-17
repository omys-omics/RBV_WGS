#!/bin/bash
#SBATCH --job-name=pixy
#SBATCH --partition=sixhour
#SBATCH --time=6:00:00
#SBATCH --mem=61G
#SBATCH --nodes=1
#SBATCH --ntasks=1
#SBATCH --output=outputs/out.%j.pixy.txt

module load conda
conda activate /kuhpc/work/colella/lab_software/pixy2.0/

date


vcf=/kuhpc/scratch/bi/b686w673/009.RBV.WGS/12.call.all.sites/07.all.sites.vcf.gz
out_dir=./
bed=Nmt.genes.selection.nonames.bed
populations=/kuhpc/work/colella/ben/009.RBV.WGS/14.pixy/popmap.txt

pixy --n_cores 12 --stats pi watterson_theta tajima_d fst dxy --vcf $vcf --populations $populations --bed_file $bed --output_folder $out_dir --output_prefix Nmt_selected

date
