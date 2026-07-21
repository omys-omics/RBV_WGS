#!/bin/bash
#SBATCH --job-name=missing
#SBATCH --partition=colella
#SBATCH --time=100:00:00
#SBATCH --mem=500G
#SBATCH --nodes=1
#SBATCH --ntasks=16
#SBATCH --output=outputs/out.%j.missing.txt




date

#bcftools-1.21 (default on cluster at this time) has a bug that causes +fill_tags F_MISSING per population to not work, but 1.23 fixes it
bcftools=/kuhpc/work/colella/lab_software/bcftools-1.23/bcftools-1.23/bcftools
export BCFTOOLS_PLUGINS=/kuhpc/work/colella/lab_software/bcftools-1.23/bcftools-1.23/plugins/


out_dir=/kuhpc/scratch/bi/b686w673/009.RBV.WGS/16.ancestry_hmm/01.high.depth.filter
vcf=$out_dir/02.high.dp.filter.vcf.gz
popmap=/kuhpc/work/colella/ben/009.RBV.WGS/16.ancestry_hmm/popmap.txt

# +fill-tags combined with the -S option will compute the requested statistics for each group in the sample file (popmap), and add it to the vcf as an INFO field
# so, F_MISSING_BC_ref_gapperi and F_MISSING_BC_ref_rutilus can be used as filters

# 13 ref gapperi, so max missing individuals at 25% is 3
# 4/13=0.307
# 3/13=0.231

# 21 ref rutilus, so max missing individuals at 25% is 5
# 6/21=0.286
# 5/21=0.238

$bcftools +fill-tags $vcf -- -S $popmap -t F_MISSING | $bcftools view --threads 96 -i "F_MISSING_BC_ref_gapperi < 0.25 & F_MISSING_BC_ref_rutilus < 0.25" -Oz -o $out_dir/03.ahmm.input.vcf.gz

$bcftools index $out_dir/03.ahmm.input.vcf.gz
$bcftools stats $out_dir/03.ahmm.input.vcf.gz > $out_dir/03.ahmm.input.txt


date




