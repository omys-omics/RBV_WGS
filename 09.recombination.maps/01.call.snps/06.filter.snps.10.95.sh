#!/bin/bash
#SBATCH --job-name=snps
#SBATCH --partition=sixhour
#SBATCH --time=6:00:00
#SBATCH --mem=61G
#SBATCH --nodes=1
#SBATCH --ntasks=1
#SBATCH --output=outputs/out.%j.snps.txt
#SBATCH --array=1

module load bcftools

date

species2="CLRU CLGA"
  
# figure out which FN of this iteration of the array
species=$(echo "$species2" | cut -f"${SLURM_ARRAY_TASK_ID}" -d" ")
echo $species

cd /kuhpc/scratch/bi/b686w673/009.RBV.WGS/09.recombination.maps/01.call.snps/$species

# stats
bcftools stats 07.depth.filtered.10.95.vcf.gz > 07.depth.filtered.10.95.txt


# Convert all sites where more than 2 individuals are missing data to all missing data
#bcftools index $out_dir/03.real.variant.$species.bcf
bcftools +setGT 07.depth.filtered.10.95.vcf.gz \
  -Oz -o 08.$species.smcpp.input.vcf.gz \
  -- -t q -n . -e 'N_MISSING <= 2'
  #-t Genotypes to change
    #q select genotypes using -i/-e options
  #-n Genotypes to set
bcftools stats 08.$species.smcpp.input.vcf.gz > 08.$species.smcpp.input.txt


bcftools +prune --random-seed 2758 -N "1st" -n 1 -w 100000bp -Oz 08.$species.smcpp.input.vcf.gz -o $species.distance.100000.10.95.vcf.gz
bcftools +prune --random-seed 2758 -N "1st" -n 1 -w 10000bp -Oz 08.$species.smcpp.input.vcf.gz -o $species.distance.10000.10.95.vcf.gz
bcftools +prune --random-seed 2758 -N "1st" -n 1 -w 1000bp -Oz 08.$species.smcpp.input.vcf.gz -o $species.distance.1000.10.95.vcf.gz
bcftools +prune --random-seed 2758 -N "1st" -n 1 -w 100bp -Oz 08.$species.smcpp.input.vcf.gz -o $species.distance.100.10.95.vcf.gz
# -n, --nsites-per-win N          Keep at most N sites in the -w window. See also -N, --nsites-per-win-mode
# -w, --window INT[bp|kb|Mb]      The window size of INT sites or INT bp/kb/Mb for the -n/-l options [100kb]
# -N, --nsites-per-win-mode STR   Keep sites with biggest AF ("maxAF"); sites that come first ("1st"); pick randomly ("rand") [maxAF]

bcftools stats $species.distance.100000.10.95.vcf.gz > $species.distance.100000.10.95.txt
bcftools stats $species.distance.10000.10.95.vcf.gz > $species.distance.10000.10.95.txt
bcftools stats $species.distance.1000.10.95.vcf.gz > $species.distance.1000.10.95.txt
bcftools stats $species.distance.100.10.95.vcf.gz > $species.distance.100.10.95.txt


date
