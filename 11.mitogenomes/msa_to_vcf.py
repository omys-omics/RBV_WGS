#!/usr/bin/env python3
import sys
from itertools import groupby


# This script was written with assistance from ChatGPT

fasta = sys.argv[1]
vcf = sys.argv[2]

# read FASTA
seqs = {}
with open(fasta) as fh:
    for is_header, group in groupby(fh, lambda x: x.startswith(">")):
        if is_header:
            header = next(group).strip()[1:]
        else:
            seqs[header] = "".join(l.strip() for l in group)

samples = list(seqs.keys())
L = len(next(iter(seqs.values())))

with open(vcf, "w") as out:
    out.write("##fileformat=VCFv4.2\n")
    out.write("##source=msa_to_vcf\n")
    out.write("##contig=<ID=alignment,length=16374>\n")
    out.write('##FORMAT=<ID=GT,Number=1,Type=String,Description="Genotype">\n')
    out.write("#CHROM\tPOS\tID\tREF\tALT\tQUAL\tFILTER\tINFO\tFORMAT\t" +
              "\t".join(samples) + "\n")

    chrom = "alignment"

    for pos in range(L):
        column = [seq[pos].upper() for seq in seqs.values()]

        # alleles excluding missing
        bases = [b for b in column if b not in ["N", "-"]]
        uniq = sorted(set(bases))

        # reference = first allele or N if all missing
        if uniq:
            REF = uniq[0]
            ALT_list = uniq[1:]
            ALT = ",".join(ALT_list) if ALT_list else "."
        else:
            REF = "N"
            ALT = "."

        # Write VCF row
        out.write(f"{chrom}\t{pos+1}\t.\t{REF}\t{ALT}\t.\t.\t.\tGT")

        # Haploid genotype calls
        for samp in samples:
            b = column[samples.index(samp)]
            if b in uniq:
                gt = uniq.index(b)
                out.write(f"\t{gt}")
            else:
                out.write("\t.")  # missing data
        out.write("\n")
