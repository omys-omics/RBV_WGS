#!/bin/bash

module load bioconda

index=/kuhpc/work/colella/ben/009.RBV.WGS/00.rutilus.ref.genome/GCA_040207285.2_mMyoRut1_p1.0_genomic.fna.fai

chromosomes="CM105764.1 CM105765.1 CM105766.1 CM105767.1 CM105768.1 CM105769.1 CM105770.1 CM105771.1 CM105772.1 CM105773.1 CM105774.1 CM105775.1 CM105776.1 CM105777.1 CM105778.1 CM105779.1 CM105780.1 CM105781.1 CM105782.1 CM105783.1 CM105784.1 CM105785.1 CM105786.1 CM105787.1 CM105788.1 CM105789.1 CM105790.1 CM105791.1"

for chr in $chromosomes
do
  grep $chr $index | cut -f1,2 >> chromosome.sizes.txt
done

bedtools makewindows -g chromosome.sizes.txt -w 1000000 -s 100000 > sliding.windows.1Mb.100kb.bed
  # -g genome, format <chr>\t<size>
  # -w window size
  # -s step size

bedtools makewindows -g chromosome.sizes.txt -w 100000 -s 10000 > sliding.windows.100kb.10kb.bed
  # -g genome, format <chr>\t<size>
  # -w window size
  # -s step size
