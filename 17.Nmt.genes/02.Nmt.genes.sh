#!/bin/bash

rm functional.exons.gff3
rm genes.not.annotated.txt
rm manual.check.gff3
rm number.of.hits.txt
rm vague.match.gff3
rm multiple.hits.txt
rm one.hit.txt
rm vague.hits.txt
rm Nmt.genes.bed

one_hit=0
multiple_hits=0
vague_hits=0
no_hits=0
N=0

genes=mMyoRut1_p1.0.GENES.gff

cat MouseMitoCarta3.0.noMT.txt | while read gene; # read in the list of genes
do
N=$(( $N+1 ))
echo "reading gene number $N"
gene_matches=`grep -c -i "gene_name \"$gene\"" $genes` # count the number of genes that match the gene code

if [[ $gene_matches -eq 1 ]]; then # if only one gene is found
  # add location to bed
  location=`grep -i "gene_name \"$gene\"" $genes | cut -f1,4,5`
  printf "$gene\t$location\n" >> Nmt.genes.bed
  # count number of single hits
  one_hit=$(( $one_hit+1 ))

  
elif [[ $gene_matches -gt 1 ]]; then # if more than one gene is found
  # list the genes that match
  grep -i "gene_name \"$gene\"" $genes >> manual.check.gff3
  # count number of multiple hits
  echo "$gene" >> multiple.hits.txt
  multiple_hits=$(( $multiple_hits+1 ))
  # add location to bed
  grep -i "gene_name \"$gene\"" $genes | awk -v gene="$gene" -v OFS='\t' '{print gene,$1,$4,$5}' >> Nmt.genes.bed


else # if no genes are found
  vague_gene_matches=`grep -i -c $gene $genes`
  if [[ $vague_gene_matches -gt 0 ]]; then # if at least one vague match is found
    # list the genes that match
    grep -i $gene $genes >> vague.match.gff3
    # count number of vague hits
    echo "$gene" >> vague.hits.txt
    vague_hits=$(( $vague_hits+1 ))
    
  else
    echo "$gene" >> genes.not.annotated.txt
    no_hits=$(( $no_hits+1 ))
    # count number of no hits
  fi
fi
echo "$one_hit genes with a single hit" >> temp.txt
echo "$multiple_hits genes with multiple hits" >> temp.txt
echo "$vague_hits genes with vague hits" >> temp.txt
echo "$no_hits genes with no hits" >> temp.txt
done

tail -4 temp.txt > number.of.hits.txt
rm temp.txt