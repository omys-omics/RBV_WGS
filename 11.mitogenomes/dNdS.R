setwd("~/Documents/Ben's Stuff/0 KU/Dissertation/009.RBV.WGS/11.mitogenomes")

library(ggplot2)
library(readr)

read.phylip <- function(file = NULL, n.rows.rm = 1) {
  # Read the file, skipping the first line which contains the dimensions
  alignment <- read.table(file, skip = n.rows.rm, stringsAsFactors = FALSE)
  # Split the sequences (second column) into individual characters
  alignment_split <- strsplit(alignment$V2, "")
  # Combine into a data frame; do.call(rbind, ...) turns list into matrix
  alignment_df <- as.data.frame(do.call(rbind, alignment_split), stringsAsFactors = FALSE)
  # Add row names using the sequence names (first column of the original file)
  rownames(alignment_df) <- alignment$V1
  # Make column names the position in alignment
  colnames(alignment_df) <- 1:ncol(alignment_df)
  
  return(alignment_df)
}


# make vector of codons
codons <- c()
for (i in c("T", "C", "A", "G")) {
  for (j in c("T", "C", "A", "G")) {
    for (k in c("T", "C", "A", "G")) {
      codon <- paste0(i,j,k)
      codons <- c(codons, codon)
    }
  }
}

# make vector of corresponding amino acids (vertebrate mitochondrial)
aminos <- c("F", "F", "L", "L", "S", "S", "S", "S", "Y", "Y", "*", "*", "C", "C", "W", "W", 
            "L", "L", "L", "L", "P", "P", "P", "P", "H", "H", "Q", "Q", "R", "R", "R", "R",
            "I", "I", "M", "M", "T", "T", "T", "T", "N", "N", "K", "K", "S", "S", "*", "*",
            "V", "V", "V", "V", "A", "A", "A", "A", "D", "D", "E", "E", "G", "G", "G", "G")

# name the aminos acids by their codons
names(aminos) <- codons



# function to determine number of unique combinations
combs <- function(n = NULL, r = NULL) {
  return(factorial(n) / (factorial(n-r) * factorial(r)))
}




pairwise.dNdS <- function(alignment_df = NULL, popmap = NULL) {
  
  pops <- unique(popmap$pop)
  inds_1 <- popmap[popmap$pop == pops[1],]$id
  alignment_1 <- alignment_df[inds_1,]
  
  inds_2 <- popmap[popmap$pop == pops[2],]$id
  alignment_2 <- alignment_df[inds_2,]

  
  sum_N <- 0
  sum_S <- 0
  
  # number of comparisons if comparing two groups
  comparisons <- nrow(alignment_1) * nrow(alignment_2)
  
  # counters for fixed diffs
  fixed_N <- 0
  fixed_S <- 0
  
  # count number of potential non-synonymous sites and synonymous sites
  nons_total <- 0
  for (a in 1:nrow(alignment_df)) {
    for (b in 1:ncol(alignment_df)) {
      position <- NA
      # if first position
      if ((b+2) %% 3 == 0) {
        codon_nucs <- c(alignment_df[a,b], alignment_df[a,(b+1)], alignment_df[a,(b+2)])
        position <- 1
      }
      
      # if second position
      if ((b+1) %% 3 == 0) {
        codon_nucs <- c(alignment_df[a,b-1], alignment_df[a,b], alignment_df[a,(b+1)])
        position <- 2
      }
      
      # if third position {
      if (b %% 3 == 0) {
        codon_nucs <- c(alignment_df[a,b-2], alignment_df[a,(b-1)], alignment_df[a,b])
        position <- 3
      }
      # start counter
      nons <- 0
      codon <- paste0(codon_nucs[1], codon_nucs[2], codon_nucs[3])
      for (nuc in c("A", "T", "C", "G")) {
        if (codon_nucs[position] != nuc) {
          new_codon <- ifelse(position==1, paste0(nuc, codon_nucs[2], codon_nucs[3]), 
                              ifelse(position==2, paste0(codon_nucs[1], nuc, codon_nucs[3]), 
                                     paste0(codon_nucs[1], codon_nucs[2], nuc))) 
          if (is.na(aminos[codon] != aminos[new_codon])) {
            print(paste0("Ambiguity code in codon from position: ", b))
            next
          }
          if (aminos[codon] != aminos[new_codon]) {
            nons <- nons + 1
          }
        }
      }
      nons_total <- nons_total + nons
    }
  }
  cN <- (nons_total / 3) / nrow(alignment_df)
  cS <- ncol(alignment_df) - cN
  
  
  # count non-synonymous diffs and synonymous diffs
  for (i in 1:ncol(alignment_df)) {
    N <- 0
    S <- 0
    # if all inds have same nucleotide, skip
    if (length(unique(alignment_df[,i])) == 1) {
      next
      # otherwise, do stuff
    } else {
      # iterate through every pairwise combination once
      for (j in 1:nrow(alignment_1)) {
        
        # if first position
        if ((i+2) %% 3 == 0) {
          j_codon <- paste0(alignment_1[j,i], alignment_1[j,(i+1)], alignment_1[j,(i+2)])
        }
        
        # if second position
        if ((i+1) %% 3 == 0) {
          j_codon <- paste0(alignment_1[j,i-1], alignment_1[j,i], alignment_1[j,(i+1)])
        }
        
        # if third position {
        if (i %% 3 == 0) {
          j_codon <- paste0(alignment_1[j,i-2], alignment_1[j,(i-1)], alignment_1[j,i])
        }
        
        
        for (k in 1:nrow(alignment_2)) {
          same_nuc <- alignment_1[j,i] == alignment_2[k,i]
          # if there is a nucleotide difference, then compare codons
          # otherwise, nothing will happen
          if (!same_nuc) {
            # if first position
            if ((i+2) %% 3 == 0) {
              k_codon <- paste0(alignment_2[k,i], alignment_2[k,(i+1)], alignment_2[k,(i+2)])
            }
            
            # if second position
            if ((i+1) %% 3 == 0) {
              k_codon <- paste0(alignment_2[k,i-1], alignment_2[k,i], alignment_2[k,(i+1)])
            }
            
            # if third position {
            if (i %% 3 == 0) {
              k_codon <- paste0(alignment_2[k,i-2], alignment_2[k,(i-1)], alignment_2[k,i])
            }
            
            # now that j and k codon are identified, see if they give different amino acids
            same_amino <- aminos[j_codon] == aminos[k_codon]
            
            if (is.na(same_amino)) {
              print(paste0("Ambiguity code in codon from position: ", i))
              next
            }
            
            if (same_amino) {
              S <- S + 1
            }
            if (!same_amino) {
              N <- N + 1
            }
            
          }
        }
        
      }
      print(c(i, S, N))
      
    }
    sum_N <- sum_N + N
    sum_S <- sum_S + S
    
    if (N==comparisons) {
      fixed_N <- fixed_N + 1
    }
    if (S==comparisons) {
      fixed_S <- fixed_S + 1
    }
    
  }  
  
  # number of comparisons if comparing two groups
  comparisons <- nrow(alignment_1) * nrow(alignment_2)
  
  N <- sum_N / comparisons
  S <- sum_S / comparisons
  
  dN <- N / cN
  dS <- S / cS
  
  results <- data.frame(comps=comparisons,
                        N=N,
                        cN=cN,
                        dN=dN,
                        fixed_N=fixed_N,
                        S=S,
                        cS=cS,
                        dS=dS,
                        fixed_S=fixed_S,
                        dNdS=dN/dS
                        )
  
  return(results)
}



#############################################################
###                MITO GAPPERI VS RUTILUS               ###
#############################################################



# read in full popmap
popmap <- read_delim("~/Documents/Ben's Stuff/0 KU/Dissertation/009.RBV.WGS/WGS_RBV_popmap_20251022.csv", 
                     delim = ",", escape_double = FALSE, 
                     trim_ws = TRUE)
# simplify popmap
popmap <- popmap[,c("id", "class")]
colnames(popmap) <- c("id", "pop")
# popmap for only the ref pops
refgap.refrut.pm <- popmap[popmap$pop %in% c("BC_ref_gapperi", "BC_ref_rutilus"),]

# list all gene alignments
genes <- list.files(path = "./gene_alignments/", pattern = "*.phy")
# initiate dataframe
gene.dNdS <- data.frame(matrix(ncol=12, nrow=0))
for (g in genes) {
  # gene name
  gene <- sapply(strsplit(g, "\\."), '[', 1)
  # read in gene alignment
  alignment_df <- read.phylip(paste0("gene_alignments/", g), n.rows.rm = 1)
  # subset for only the ref pops
  refs_alignment <- alignment_df[popmap[popmap$pop %in% c("BC_ref_gapperi", "BC_ref_rutilus"),]$id,]
  # calculate N and S between ref pops
  temp <- pairwise.dNdS(refs_alignment, popmap = refgap.refrut.pm)
  # gene length
  length <- ncol(alignment_df)
  # add to dataframe
  gene.dNdS <- rbind(gene.dNdS, cbind(gene, temp, length))
}
gene.dNdS[gene.dNdS$gene=="ND6_rc", "gene"] <- "ND6"


sum(gene.dNdS$fixed_N)
gene.dNdS.write <- gene.dNdS[,c(1,3,4,7,8,11,12,6,10)]
write.table(gene.dNdS.write, "gene.dNdS.csv", sep = ",", col.names = T, row.names = F, quote = F)

# dNdS
ggplot(gene.dNdS, aes(x = factor(gene, levels = c("ND1", "ND2", "COX1", "COX2", "ATP8", "ATP6", "COX3", "ND3", "ND4L", "ND4", "ND5", "ND6", "CYTB")), y = dNdS)) +
  geom_point(position = position_dodge(width = 0.5), cex = 2.3) +
  labs(title = "",
       x = "Mitochondrial gene",
       y = "dN/dS") +
  theme_minimal() +
  ylim(0,0.25) +
  theme_bw()

# count N
ggplot(gene.dNdS, aes(x = factor(gene, levels = c("ND1", "ND2", "COX1", "COX2", "ATP8", "ATP6", "COX3", "ND3", "ND4L", "ND4", "ND5", "ND6", "CYTB")), y = fixed_N)) +
  geom_point(position = position_dodge(width = 0.5), cex = 2.3) +
  labs(title = "",
       x = "mitochondrial gene",
       y = "fixed differences") +
  theme_minimal() +
  #ylim(0,0.25) +
  theme_bw()

# percent N
ggplot(gene.dNdS, aes(x = factor(gene, levels = c("ND1", "ND2", "COX1", "COX2", "ATP8", "ATP6", "COX3", "ND3", "ND4L", "ND4", "ND5", "ND6", "CYTB")), y = fixed_N/length)) +
  geom_point(position = position_dodge(width = 0.5), cex = 2.3) +
  labs(title = "",
       x = "mitochondrial gene",
       y = "fixed differences") +
  theme_minimal() +
  #ylim(0,0.25) +
  theme_bw()

#pivot longer
library(tidyr)
gene.dNdS.2 <- gene.dNdS %>% 
  pivot_longer(
    cols = c(fixed_N, fixed_S),
    names_to = "fixed",
    values_to = "count"
  )

# percent N and S
ggplot(gene.dNdS.2, aes(x = factor(gene, levels = c("ND1", "ND2", "COX1", "COX2", "ATP8", "ATP6", "COX3", "ND3", "ND4L", "ND4", "ND5", "ND6", "CYTB")), y = count/length, color = fixed)) +
  geom_point(position = position_dodge(width = 0.5), cex = 2.3) +
  labs(title = "",
       x = "mitochondrial gene",
       y = "fixed differences") +
  theme_minimal() +
  #ylim(0,0.25) +
  theme_bw()



# one at a time
alignment_df <- read.phylip("gene_alignments/CYTB.phy", n.rows.rm = 1)
refs_alignment <- alignment_df[popmap[popmap$pop %in% c("BC_ref_gapperi", "BC_ref_rutilus"),]$id,]
pairwise.dNdS(refs_alignment, popmap = refgap.refrut.pm)

#







