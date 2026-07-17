#!/bin/bash
#SBATCH --job-name=depth
#SBATCH --partition=eeb
#SBATCH --time=48:00:00
#SBATCH --mem=120G
#SBATCH --nodes=1
#SBATCH --ntasks=1
#SBATCH --output=outputs/out.%j.depth.txt
#SBATCH --array=55-72

#bi      1-36
#colella 37-54
#eeb     55-72

module load bcftools

date

ids=`cat ids.txt`


# figure out which FN of this iteration of the array
id=$(echo $ids | cut -f"${SLURM_ARRAY_TASK_ID}" -d" ")
echo $id

out_dir=/kuhpc/scratch/bi/b686w673/009.RBV.WGS/12.call.all.sites
file=$out_dir/04.filtered.vcf.gz



# 3. Split each sample to its own file
bcftools view --threads 96 -s $id $file -Oz -o $out_dir/06.individual/$id.pre.vcf.gz


# 4. Set genotypes below 5 and above 95% quantile to missing
max=$(awk -v id="$id" '$1==id {print $2}' sample_ids_quantiles.txt)
  #-v id="$id" passes the current shell variable into awk
  #$1==id {print $2} means: if column 1 equals the ID, print column 2 (the depth)
printf "$id\t$max\n"
  
bcftools +setGT $out_dir/06.individual/$id.pre.vcf.gz \
  --threads 96 -Oz -o $out_dir/06.individual/$id.depth.filtered.vcf.gz \
  -- -t q -i "FMT/DP<5 || FMT/DP>$max" -n ./.
    
bcftools index $out_dir/06.individual/$id.depth.filtered.vcf.gz




date






