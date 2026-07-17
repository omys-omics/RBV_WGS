#!/bin/bash

module load bioconda


chromosomes="CM105764.1 CM105765.1 CM105766.1 CM105767.1 CM105768.1 CM105769.1 CM105770.1 CM105771.1 CM105772.1 CM105773.1 CM105774.1 CM105775.1 CM105776.1 CM105777.1 CM105778.1 CM105779.1 CM105780.1 CM105781.1 CM105782.1 CM105783.1 CM105784.1 CM105785.1 CM105786.1 CM105787.1 CM105788.1 CM105789.1 CM105790.1 CM105791.1"

in_dir=/kuhpc/scratch/bi/b686w673/009.RBV.WGS/09.recombination.maps/03.pyrho



for species in CLGA CLRU
do 
  for i in $chromosomes 
  do 
    awk -v chr=$i 'BEGIN{OFS="\t"}{print chr,$1,$2,$3}' $in_dir/$species/$species.$i.rmap >> $in_dir/$species/$species.genome.rmap
  done
done

for species in CLGA CLRU
do
  echo -e "chrom\tstart\tend\trate" > $species.genome.1Mb.100kb.rmap
  bedtools map -a sliding.windows.1Mb.100kb.bed -b $in_dir/$species/$species.genome.rmap -c 4 -o mean >> $species.genome.1Mb.100kb.rmap
  # bedtools map allows one to map overlapping features in a B file onto features in an A file and apply statistics and/or summary operations on those features 
  # -c Specify the column from the B file to map onto intervals in A
  # -o Specify the operation that should be applied to -c
done





for species in CLRU
do 
  for i in $chromosomes 
  do 
    awk -v chr=$i 'BEGIN{OFS="\t"}{print chr,$1,$2,$3}' $in_dir/$species/maps.13/$species.$i.rmap >> $in_dir/$species/maps.13/$species.genome.rmap
  done
done

for species in CLRU
do
  echo -e "chrom\tstart\tend\trate" > $species.genome.1Mb.100kb.13.rmap
  bedtools map -a sliding.windows.1Mb.100kb.bed -b $in_dir/$species/maps.13/$species.genome.rmap -c 4 -o mean >> $species.genome.1Mb.100kb.13.rmap
  # bedtools map allows one to map overlapping features in a B file onto features in an A file and apply statistics and/or summary operations on those features 
  # -c Specify the column from the B file to map onto intervals in A
  # -o Specify the operation that should be applied to -c
done






