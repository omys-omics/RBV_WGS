#!/bin/bash
#SBATCH --job-name=snps
#SBATCH --partition=sixhour
#SBATCH --time=6:00:00
#SBATCH --mem=61G
#SBATCH --nodes=1
#SBATCH --ntasks=1
#SBATCH --output=outputs/out.%j.snps.txt
#SBATCH --array=2



module load bcftools

date

species2="CLRU CLGA"
  
# figure out which FN of this iteration of the array
species=$(echo "$species2" | cut -f"${SLURM_ARRAY_TASK_ID}" -d" ")
echo $species

out_dir=/kuhpc/scratch/bi/b686w673/009.RBV.WGS/09.recombination.maps/01.call.snps

#bcftools stats $out_dir/01.raw.snps.$species.bcf > $out_dir/01.raw.snps.$species.txt


# 1. Get rid of sites with more than 2 alleles
#bcftools index $out_dir/01.raw.snps.$species.bcf
#bcftools view -m2 -M2 -v snps -Ou -o $out_dir/02.biallelic.$species.bcf $out_dir/01.raw.snps.$species.bcf
#bcftools stats $out_dir/02.biallelic.$species.bcf > $out_dir/02.biallelic.$species.txt
  #-m, --min-alleles INT
    #print sites with at least INT alleles listed in REF and ALT columns
  #-M, --max-alleles INT
    #print sites with at most INT alleles listed in REF and ALT columns. 
    #Use -m2 -M2 -v snps to only view biallelic SNPs.
  #-Ou output uncompressed bcf


# 2. Only keep sites that are variant within MY samples (not where the ref is the only difference)
#bcftools index $out_dir/02.biallelic.$species.bcf
#bcftools view -i 'AC!=AN' $out_dir/02.biallelic.$species.bcf -Ou -o $out_dir/03.real.variant.$species.bcf
#bcftools stats $out_dir/03.real.variant.$species.bcf > $out_dir/03.real.variant.$species.txt
  #AC: Total number of ALT alleles across all samples
  #AN: Total number of called alleles across all samples


# 3. Convert all sites where more than 2 individuals are missing data to all missing data
#bcftools index $out_dir/03.real.variant.$species.bcf
bcftools +setGT $out_dir/03.real.variant.$species.bcf \
  -Ou -o $out_dir/04.2missing.$species.bcf \
  -- -t q -n . -e 'N_MISSING <= 2'
  #-t Genotypes to change
    #q select genotypes using -i/-e options
  #-n Genotypes to set
bcftools stats $out_dir/04.2missing.$species.bcf > $out_dir/04.2missing.$species.txt


# 4. Convert all sites that are outside of 2 standard deviations for the following statistics to all missing data
bcftools index $out_dir/04.2missing.$species.bcf
#bcftools +setGT $out_dir/04.2missing.$species.bcf \
#  -Ou -o $out_dir/05.quality.$species.bcf \
#  -- -t q -n . -e 'RPBZ>-2 && RPBZ<2 && MQBZ>-2 && MQBZ<2 && MQSBZ>-2 && MQSBZ<2 && BQBZ>-2 && BQBZ<2 && SCBZ>-2 && SCBZ<2'
  #-t Genotypes to change
    #q select genotypes using -i/-e options
  #-n Genotypes to set
#bcftools stats $out_dir/05.quality.$species.bcf > $out_dir/05.quality.$species.txt









date






