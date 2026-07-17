#!/bin/bash
#SBATCH --job-name=filter
#SBATCH --partition=eeb
#SBATCH --time=24:00:00
#SBATCH --mem=250G
#SBATCH --nodes=1
#SBATCH --ntasks=12
#SBATCH --output=outputs/out.%j.filter.txt

module load bcftools

date


out_dir=/kuhpc/scratch/bi/b686w673/009.RBV.WGS/08.call.snps

# 1. stats
bcftools stats $out_dir/05.depth.5.95.vcf.gz > $out_dir/05.depth.5.95.txt


# 2. Only keep sites with data for at least 1 out of 73 individuals, get rid of invariant sites
bcftools index $out_dir/05.depth.5.95.vcf.gz
bcftools view --threads 96 -i 'N_MISSING < 73 && AC!=AN && AC!=0' $out_dir/05.depth.5.95.vcf.gz -Oz -o $out_dir/06.variants.outgroup.vcf.gz
bcftools stats $out_dir/06.variants.outgroup.vcf.gz > $out_dir/06.variants.outgroup.txt


# 2. Remove outgroup, only keep sites with data for at least 2 out of 72 individuals, get rid of invariant sites
bcftools index $out_dir/06.variants.outgroup.vcf.gz
bcftools view --threads 96 -s ^UAM34216 $out_dir/06.variants.outgroup.vcf.gz -Oz | \
bcftools view --threads 96 -i 'N_MISSING < 71 && AC!=AN && AC!=0' -Oz -o $out_dir/07.variants.vcf.gz
  # -s ^ID excludes that sample
bcftools stats $out_dir/07.variants.vcf.gz > $out_dir/07.variants.txt
bcftools index $out_dir/07.variants.vcf.gz


# 3. Get missing data for each sample
# Get genotypes per site
bcftools query -f '[%GT\t]\n' $out_dir/07.variants.vcf.gz | \
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
paste ids.no.outgroup.txt missing.counts.txt | \
awk '{printf "%s\tMissing=%s\tTotal=%s\tProportion=%s\n", $1,$2,$3,$4}' > ids.missing.counts.txt



# 4. Distance filter
bcftools +prune --random-seed 48751 -N "1st" -n 1 -w 100000bp -Oz $out_dir/07.variants.vcf.gz -o $out_dir/08.distance.100000.vcf.gz
bcftools +prune --random-seed 48751 -N "1st" -n 1 -w 10000bp -Oz $out_dir/07.variants.vcf.gz -o $out_dir/08.distance.10000.vcf.gz
bcftools +prune --random-seed 48751 -N "1st" -n 1 -w 1000bp -Oz $out_dir/07.variants.vcf.gz -o $out_dir/08.distance.1000.vcf.gz
bcftools +prune --random-seed 48751 -N "1st" -n 1 -w 100bp -Oz $out_dir/07.variants.vcf.gz -o $out_dir/08.distance.100.vcf.gz
# -n, --nsites-per-win N          Keep at most N sites in the -w window. See also -N, --nsites-per-win-mode
# -w, --window INT[bp|kb|Mb]      The window size of INT sites or INT bp/kb/Mb for the -n/-l options [100kb]
# -N, --nsites-per-win-mode STR   Keep sites with biggest AF ("maxAF"); sites that come first ("1st"); pick randomly ("rand") [maxAF]

bcftools stats $out_dir/08.distance.100000.vcf.gz > $out_dir/08.distance.100000.txt
bcftools stats $out_dir/08.distance.10000.vcf.gz > $out_dir/08.distance.10000.txt
bcftools stats $out_dir/08.distance.1000.vcf.gz > $out_dir/08.distance.1000.txt
bcftools stats $out_dir/08.distance.100.vcf.gz > $out_dir/08.distance.100.txt

bcftools index $out_dir/08.distance.100000.vcf.gz
bcftools index $out_dir/08.distance.10000.vcf.gz
bcftools index $out_dir/08.distance.1000.vcf.gz
bcftools index $out_dir/08.distance.100.vcf.gz


date
