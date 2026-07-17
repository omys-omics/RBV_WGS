#!/bin/bash
#SBATCH --job-name=depth
#SBATCH --partition=sixhour
#SBATCH --time=6:00:00
#SBATCH --mem=120G
#SBATCH --nodes=1
#SBATCH --ntasks=12
#SBATCH --output=outputs/out.%j.depth.txt
#SBATCH --array=1-73



module load bcftools

date

ids=`cat ids.txt`


# figure out which FN of this iteration of the array
id=$(echo $ids | cut -f"${SLURM_ARRAY_TASK_ID}" -d" ")
echo $id

file=/kuhpc/scratch/bi/b686w673/009.RBV.WGS/08.call.snps/04.goodnames.vcf.gz
out_dir=/kuhpc/scratch/bi/b686w673/009.RBV.WGS/08.call.snps



# 3. Split each sample to its own file
bcftools view --threads 96 -s $id $file -Oz -o $out_dir/individual/$id.pre.vcf.gz


# 4. Set genotypes below 5 and above 95% quantile to missing
max=$(awk -v id="$id" '$1==id {print $2}' sample_ids_quantiles.txt)
  #-v id="$id" passes the current shell variable into awk
  #$1==id {print $2} means: if column 1 equals the ID, print column 2 (the depth)
printf "$id\t$max\n"
  
bcftools +setGT $out_dir/individual/$id.pre.vcf.gz \
  --threads 96 -Oz -o $out_dir/individual/$id.depth.filtered.vcf.gz \
  -- -t q -i "FMT/DP<5 || FMT/DP>$max" -n ./.
    
bcftools index $out_dir/individual/$id.depth.filtered.vcf.gz




date






