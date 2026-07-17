#!/bin/bash

# This script was written with assistance from ChatGPT

#OG CLGA recombination map
CLGA_r=/kuhpc/work/colella/ben/009.RBV.WGS/09.recombination.maps/03.pyrho/CLGA/CLGA.genome.27.rmap

#Nmt genes bed
awk -v OFS='\t' '{print $2, $3, $4}' Nmt.genes.chrnames.bed > Nmt.genes.chrnames.nonames.bed
bed=Nmt.genes.chrnames.nonames.bed

###########################################################
#     find weighted average of r for each ahmm window     #
###########################################################
awk '
# Read A.txt into memory
NR==FNR {
    chrA[NR]   = $1
    startA[NR] = $2
    endA[NR]   = $3
    rA[NR]     = $4
    nA = NR
    next
}

# Process B.txt
{
    chrB   = $1
    startB = $2
    endB   = $3

    sum_wr = 0
    sum_w  = 0

    for (i = 1; i <= nA; i++) {
        if (chrA[i] != chrB)
            continue

        # compute overlap
        ov_start = (startA[i] > startB ? startA[i] : startB)
        ov_end   = (endA[i]   < endB   ? endA[i]   : endB)
        overlap  = ov_end - ov_start

        if (overlap > 0) {
            sum_wr += overlap * rA[i]
            sum_w  += overlap
        }
    }

    avg_r = (sum_w > 0 ? sum_wr / sum_w : "NA")

    print chrB, startB, endB, avg_r
}
' $CLGA_r $bed > 04.Nmt.r.bed

awk '{ sum += $4 * ($3 - $2); len +=($3 - $2) } END { print sum / len }' 04.Nmt.r.bed

# averge r in Nmt genes is 3.18385e-09

# average size of Nmt genes is 27165

# 27165 * 3.18385e-09 = 0.00008648929 M




