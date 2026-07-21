#!/bin/bash
awk '$2=="BC_discordant" || $2=="BC_ref_rutilus" || $2=="BC_ref_gapperi" {print}' popmap.txt > popmap.BC.txt
awk '$2=="SEAK_discordant" || $2=="BC_ref_rutilus" || $2=="BC_ref_gapperi" {print}' popmap.txt > popmap.SEAK.txt

sed -i 's/BC_ref_rutilus/0/g' popmap.BC.txt
sed -i 's/BC_ref_gapperi/1/g' popmap.BC.txt
sed -i 's/BC_discordant/admixed/g' popmap.BC.txt

sed -i 's/BC_ref_rutilus/0/g' popmap.SEAK.txt
sed -i 's/BC_ref_gapperi/1/g' popmap.SEAK.txt
sed -i 's/SEAK_discordant/admixed/g' popmap.SEAK.txt

sort -k1,1 popmap.BC.txt > popmap.BC.sorted.txt
sort -k1,1 popmap.SEAK.txt > popmap.SEAK.sorted.txt

rm popmap.BC.txt
rm popmap.SEAK.txt