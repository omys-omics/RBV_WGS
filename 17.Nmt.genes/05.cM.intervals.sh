#!/bin/bash

# This script was written with assistance from ChatGPT

#OG CLGA recombination map
CLGA_r=/kuhpc/work/colella/ben/009.RBV.WGS/09.recombination.maps/03.pyrho/CLGA/CLGA.genome.27.rmap

# Average Morgans of Nmt genes is 0.00008648929

# Find equally sized windows, scaled by recombination rate
awk '
BEGIN {
    threshold = 0.00008648929
}

NR == 1 {
    chr = $1
    start = $2
    sum = 0
}

{
    # If chromosome changes, flush current block
    if ($1 != chr) {
        if (sum > 0) {
            printf "%s\t%d\t%d\t%.10g\n", chr, start, prev_end, sum
        }
        chr = $1
        start = $2
        sum = 0
    }

    # length-weighted contribution
    sum += $4 * ($3 - $2)

    # If threshold reached, output and reset
    if (sum >= threshold) {
        printf "%s\t%d\t%d\t%.10g\n", chr, start, $3, sum
        sum = 0
        start = $3
    }

    prev_end = $3
}

END {
    # Flush any remaining block
    if (sum > 0) {
        printf "%s\t%d\t%d\t%.10g\n", chr, start, prev_end, sum
    }
}
' $CLGA_r > Nmt.cM.windows.rmap
