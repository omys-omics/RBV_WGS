setwd("~/Documents/Ben's Stuff/0 KU/Dissertation/009.RBV.WGS/11.mitogenomes")

library(ape)
library(readr)

# read alignment
aln <- read.dna("all.mitogenomes.aligned.fasta", format = "fasta")
aln
#make pairwise p-distance matrix
?dist.dna
d <- dist.dna(aln, model = "raw", pairwise.deletion = TRUE, as.matrix = TRUE)
# read in full popmap
popmap <- read_delim("~/Documents/Ben's Stuff/0 KU/Dissertation/009.RBV.WGS/WGS_RBV_popmap_20251022.csv", 
                              delim = ",", escape_double = FALSE, 
                              trim_ws = TRUE)
# make sure popmap is in same order as ids in the vcf
identical(rownames(aln), popmap$id)
popmap <- popmap[order(match(popmap$id, rownames(aln))),]
identical(rownames(aln), popmap$id)

# mean p-distance within and between groups
pop <- unique(popmap$class)
ave.p.groups <- matrix(NA, length(pop), length(pop), dimnames = list(pop, pop))

for (i in pop) {
  for (j in pop) {
    ids_i <- popmap$id[popmap$class == i]
    ids_j <- popmap$id[popmap$class == j]
    sub <- d[ids_i, ids_j, drop = FALSE]
    if (i == j) {
      # within-group
      ave.p.groups[i, j] <- if (length(ids_i) > 1) mean(sub[lower.tri(sub)]) else NA  
    } else {
      # between-group
      ave.p.groups[i, j] <- mean(sub)                                                  
    }
  }
}

ave.p.groups <- round(ave.p.groups, 4)

