#!/bin/bash
#SBATCH --job-name=filter
#SBATCH --partition=eeb
#SBATCH --time=100:00:00
#SBATCH --mem=250G
#SBATCH --nodes=1
#SBATCH --ntasks=12
#SBATCH --output=outputs/out.%j.filter.txt

module load bcftools

date


out_dir=/kuhpc/scratch/bi/b686w673/009.RBV.WGS/12.call.all.sites


# 1. stats
bcftools index $out_dir/06.depth.5.95.vcf.gz
bcftools stats $out_dir/06.depth.5.95.vcf.gz > $out_dir/06.depth.5.95.txt


# 2. Only keep sites with data for at least 2 out of 72 individuals
bcftools view --threads 96 -i 'N_MISSING < 71' -Oz $out_dir/06.depth.5.95.vcf.gz -o $out_dir/07.all.sites.vcf.gz
bcftools index $out_dir/07.all.sites.vcf.gz
bcftools stats $out_dir/07.all.sites.vcf.gz > $out_dir/07.all.sites.txt



# 3. Get missing data for each sample
# Get genotypes per site
bcftools query -f '[%GT\t]\n' $out_dir/07.all.sites.vcf.gz | \
awk '
{
    for(i=1;i<=NF;i++){
        total[i]++
        if($i=="./.") missing[i]++
    }
}
END{
    for(i=1;i<=NF;i++){
        prop = (missing[i] / total[i])
        printf "%d\t%d\t%.6f\n", missing[i], total[i], prop
    }
}' > missing.counts.txt

# Combine names + results
paste ids.txt missing.counts.txt | \
awk '{printf "%s\tMissing=%s\tTotal=%s\tProportion=%s\n", $1,$2,$3,$4}' > ids.missing.counts.txt





date
