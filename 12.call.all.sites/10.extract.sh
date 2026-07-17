#!/bin/bash
#SBATCH --job-name=extract
#SBATCH --partition=sixhour
#SBATCH --time=6:00:00
#SBATCH --mem=61G
#SBATCH --nodes=1
#SBATCH --ntasks=1
#SBATCH --output=outputs/out.%j.extract.txt
#SBATCH --array=1-18



module load bcftools

date

region=$(sed -n "$SLURM_ARRAY_TASK_ID"p Nmt.genes.selection.20kb.buffer.bed | cut -f2)
gene=$(sed -n "$SLURM_ARRAY_TASK_ID"p Nmt.genes.selection.20kb.buffer.bed | cut -f1)
out_dir=/kuhpc/scratch/bi/b686w673/009.RBV.WGS/12.call.all.sites
vcf=$out_dir/07.all.sites.vcf.gz

echo $gene
echo $region

# make vcf for region, only variant sites
bcftools view -r $region -v snps $vcf -Ov > $out_dir/10.Nmt.genes.selection.20kb.buffer/$gene.filtered.vcf
bcftools stats $out_dir/10.Nmt.genes.selection.20kb.buffer/$gene.filtered.vcf > $out_dir/10.Nmt.genes.selection.20kb.buffer/$gene.filtered.vcf.txt


date






