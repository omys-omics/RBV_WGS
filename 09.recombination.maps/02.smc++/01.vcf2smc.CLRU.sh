#!/bin/bash
#SBATCH --job-name=smc
#SBATCH --partition=sixhour
#SBATCH --time=6:00:00
#SBATCH --mem=120G
#SBATCH --nodes=1
#SBATCH --ntasks=1
#SBATCH --output=outputs/out.%j.smc.txt
#SBATCH --array=1-28

date

species=CLRU
echo $species

chromosomes="CM105764.1 CM105765.1 CM105766.1 CM105767.1 CM105768.1 CM105769.1 CM105770.1 CM105771.1 CM105772.1 CM105773.1 CM105774.1 CM105775.1 CM105776.1 CM105777.1 CM105778.1 CM105779.1 CM105780.1 CM105781.1 CM105782.1 CM105783.1 CM105784.1 CM105785.1 CM105786.1 CM105787.1 CM105788.1 CM105789.1 CM105790.1 CM105791.1"

# figure out which chromosome of this iteration of the array
chromosome=$(echo "$chromosomes" | cut -f"${SLURM_ARRAY_TASK_ID}" -d" ")
echo $chromosome

vcf=/kuhpc/scratch/bi/b686w673/009.RBV.WGS/09.recombination.maps/01.call.snps/$species/08.$species.smcpp.input.vcf.gz
out_dir=/kuhpc/scratch/bi/b686w673/009.RBV.WGS/09.recombination.maps/02.smc++/$species/smcs.mask
mask=/kuhpc/scratch/bi/b686w673/009.RBV.WGS/09.recombination.maps/02.smc++/$species/mask/$species.mask.bed.gz

for i in MSB199067 MSB199079 MSB199082 MSB199096 MSB199104 MSB199112 MSB199126 MSB199127 MSB199134 MSB199138
do
  smc++ vcf2smc -m $mask -d $i $i $vcf $out_dir/$species.$i.$chromosome.smc $chromosome $species:MSB198512,MSB199067,MSB199079,MSB199080,MSB199082,MSB199092,MSB199096,MSB199104,MSB199112,MSB199119,MSB199121,MSB199122,MSB199126,MSB199127,MSB199129,MSB199132,MSB199133,MSB199134,MSB199135,MSB199136,MSB199138
  # -d identity of distinguished lineage
  # -m This specifies a BED-formatted mask file whose positions will be marked as missing data (across all samples) in the outputted SMC++ data set
  # input vcf
  # output
  # chromosome
  # individuals
done


date






