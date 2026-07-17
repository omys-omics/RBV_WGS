#!/bin/bash
#SBATCH --job-name=bcftools
#SBATCH --partition=sixhour
#SBATCH --time=6:00:00
#SBATCH --mem=120G
#SBATCH --nodes=1
#SBATCH --ntasks=1
#SBATCH --output=outputs/out.%j.bcftools.txt
#SBATCH --array=1-28


module load bcftools

date

species=CLGA
echo $species

chromosomes="CM105764.1 CM105765.1 CM105766.1 CM105767.1 CM105768.1 CM105769.1 CM105770.1 CM105771.1 CM105772.1 CM105773.1 CM105774.1 CM105775.1 CM105776.1 CM105777.1 CM105778.1 CM105779.1 CM105780.1 CM105781.1 CM105782.1 CM105783.1 CM105784.1 CM105785.1 CM105786.1 CM105787.1 CM105788.1 CM105789.1 CM105790.1 CM105791.1"

# figure out which chromosome of this iteration of the array
chromosome=$(echo "$chromosomes" | cut -f"${SLURM_ARRAY_TASK_ID}" -d" ")
echo $chromosome

vcf=/kuhpc/scratch/bi/b686w673/009.RBV.WGS/09.recombination.maps/01.call.snps/$species/08.$species.smcpp.input.vcf.gz
out_dir=/kuhpc/scratch/bi/b686w673/009.RBV.WGS/09.recombination.maps/03.pyrho/$species/vcfs

bcftools view -Oz -r $chromosome -i 'F_MISSING<1' $vcf > $out_dir/$species.$chromosome.vcf.gz
  # --regions -r chr
  # -i only include regions where the fraction of missing genotypes is less than 1
  #      this value is calculated on the fly, so it doesn't matter that the AC and AN are incorrect, which resulted from manually setting certain sites to all missing data, as smc++ wanted

cd $out_dir
tabix -p vcf $species.$chromosome.vcf.gz


date






