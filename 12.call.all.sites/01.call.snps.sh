#!/bin/bash
#SBATCH --job-name=call
#SBATCH --partition=eeb
#SBATCH --time=10-00:00:00
#SBATCH --mem=250G
#SBATCH --nodes=1
#SBATCH --ntasks=1
#SBATCH --output=outputs/out.%j.call.txt
#SBATCH --array=20-27

#bi  1-19
#eeb 20-27

date

module load bcftools

chromosomes="CM105764.1 CM105765.1 CM105766.1 CM105767.1 CM105768.1 CM105769.1 CM105770.1 CM105771.1 CM105772.1 CM105773.1 CM105774.1 CM105775.1 CM105776.1 CM105777.1 CM105778.1 CM105779.1 CM105780.1 CM105781.1 CM105782.1 CM105783.1 CM105784.1 CM105785.1 CM105786.1 CM105787.1 CM105788.1 CM105789.1 CM105790.1"

# figure out which chromosome of this iteration of the array
chromosome=$(echo "$chromosomes" | cut -f"${SLURM_ARRAY_TASK_ID}" -d" ")
echo $chromosome


#find the bam files
bams=`ls /kuhpc/work/colella/ben/009.RBV.WGS/06.alignments.CLRU/01.alignments/*.bam`
echo $bams
for bam in $bams
do
  KU=`basename $bam`
  echo $KU
done

# assign the reference genome
ref=/kuhpc/work/colella/ben/009.RBV.WGS/00.rutilus.ref.genome/GCA_040207285.2_mMyoRut1_p1.0_genomic.fna

# output directory
out_dir=/kuhpc/scratch/bi/b686w673/009.RBV.WGS/12.call.all.sites/01.chromosomes
reheader=/kuhpc/work/colella/ben/009.RBV.WGS/12.call.all.sites/reheader.txt
popmap=/kuhpc/work/colella/ben/009.RBV.WGS/12.call.all.sites/popmap.txt

bcftools mpileup --threads 96 -a DP,AD -Q 30 -Ou -r $chromosome -G $reheader -f $ref $bams | bcftools call -G $popmap -f GQ -m -V indels -Ou -o $out_dir/01.raw.$chromosome.bcf
#-G, --read-groups FILE

#-f the faidx index reference genome in the fasta format
#-a DP output the depth for each sample at each snp, AD output allelic depth
#-q minimum mapping quality for an alignment to be considered (default 0)
#-Q minimum base quality for a base to be considered
#-Ou output uncompressed bcf
# Use the -Ou option when piping between bcftools subcommands 
#-r Only generate mpileup output in given regions. Requires the alignment files to be indexed. 

#-f GQ output genotype quality ######## ADD THIS TO GET GENOTYPE QUALITY ##############
#-m multi-allelic caller
#-v output variant sites only
#-V indels  #skips indels
#-Ou output uncompressed bcf
#-Ov output a vcf

# -G This option groups samples into populations and apply the HWE assumption within but not across the populations. FILE is a tab-delimited text file with sample names in the first column and group names in the second column.


date





