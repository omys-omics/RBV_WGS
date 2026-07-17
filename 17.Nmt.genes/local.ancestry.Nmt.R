setwd("~/Documents/Ben's Stuff/0 KU/Dissertation/009.RBV.WGS/17.Nmt.genes")

library(ggplot2)
library(purrr)
library(tidyr)
library(dplyr)




#############################################################
########               all ANCESTRY_HMM               #######
#############################################################

all.ancestry_hmm.intervals <- read.table("../10.local.ancestry/all.ancestry_hmm.intervals.AIMS10.95.CLGAr.bed", sep = "\t", col.names = c("id", "chr", "start", "end", "state"))
all.ancestry_hmm.intervals <- all.ancestry_hmm.intervals[all.ancestry_hmm.intervals$chr %in% unique(all.ancestry_hmm.intervals$chr)[1:27],]


all.lai.ancestry_hmm <- ggplot(all.ancestry_hmm.intervals, aes(xmin = start, xmax = end, y = id, color = factor(state))) +
  geom_linerange(size = 3) +
  facet_wrap(~ chr, scales = "free_x", ncol = 7) +
  scale_color_manual(values = c("0" = "#D8B365", "1" = "grey", "2" = "#5AB4AB", "UNASSIGNED" = "black")) +
  #scale_color_manual(values = c("gap,gap" = "#5AB4AB", "gap,old" = "#D8B365", "gap,new" = "coral", "old,old" = "gold4", "old,new" = "grey", "new,new" = "darkred",  "UNASSIGNED" = "white")) +
  scale_x_continuous(breaks = c(0,43000000,86000000)) +
  theme_bw() +
  theme(
    strip.background = element_rect(fill = "white"),
    panel.grid = element_blank(),
    axis.title = element_blank(),
    legend.position = "none"
  ) 
all.lai.ancestry_hmm
ggsave("all.local.ancestry.ancestry_hmm.95.png", all.lai.ancestry_hmm, width = 26, height = 14)

BC.inds <- c("FN3758", "FN3762", "FN3788", "FN3789", "FN3790", "FN3791", "FN3819", "FN3835", "FN3836", "FN3837", "FN3867", "FN3878", "FN3879", "FN3880")
SEAK.inds <- c("FN505", "FN506", "FN534", "FN547", "FN550", "FN572", "FN602", "FN603", "FN605", "FN608", "UAM50293", "UAM50296")
all.ancestry_hmm.intervals$pop <- rep("NA", nrow(all.ancestry_hmm.intervals))
all.ancestry_hmm.intervals[all.ancestry_hmm.intervals$id %in% BC.inds, "pop"] <- "BC"
all.ancestry_hmm.intervals[all.ancestry_hmm.intervals$id %in% SEAK.inds, "pop"] <- "SEAK"

lai.26.ancestry_hmm <- ggplot(all.ancestry_hmm.intervals[all.ancestry_hmm.intervals$chr == "CM105789.1",], aes(xmin = start, xmax = end, y = id, color = factor(state))) +
  geom_linerange(size = 3) +
  facet_wrap(pop ~ chr, nrow = 2, scales = "free_y") +
  scale_color_manual(values = c("0" = "#D8B365", "1" = "grey", "2" = "#5AB4AB", "UNASSIGNED" = "white")) +
  #scale_color_manual(values = c("gap,gap" = "#5AB4AB", "gap,old" = "#D8B365", "gap,new" = "coral", "old,old" = "gold4", "old,new" = "grey", "new,new" = "darkred",  "UNASSIGNED" = "white")) +
  scale_x_continuous(
    breaks = c(0,1e7,2e7,3e7,4e7,46425774),
    expand = c(0.01,0)
  ) +
  theme_bw() +
  theme(
    strip.background = element_rect(fill = "white"),
    panel.grid = element_blank(),
    axis.title = element_blank(),
    legend.position = "none"
  ) 
lai.26.ancestry_hmm
ggsave("all.local.ancestry.ancestry_hmm.95.png", all.lai.ancestry_hmm, width = 26, height = 14)


# total bp assigned per ind
total.bp <- sum(all.ancestry_hmm.intervals$end - all.ancestry_hmm.intervals$start) / 26

bc.total.bp <- sum(all.ancestry_hmm.intervals[all.ancestry_hmm.intervals$pop == "BC",]$end - all.ancestry_hmm.intervals[all.ancestry_hmm.intervals$pop == "BC",]$start) / 14
seak.total.bp <- sum(all.ancestry_hmm.intervals[all.ancestry_hmm.intervals$pop == "SEAK",]$end - all.ancestry_hmm.intervals[all.ancestry_hmm.intervals$pop == "SEAK",]$start) / 12

# average bp of segments per ind
bc.un.bp <- sum(all.ancestry_hmm.intervals[all.ancestry_hmm.intervals$pop == "BC" & all.ancestry_hmm.intervals$state == "UNASSIGNED",]$end - all.ancestry_hmm.intervals[all.ancestry_hmm.intervals$pop == "BC" & all.ancestry_hmm.intervals$state == "UNASSIGNED",]$start) / 14
seak.un.bp <- sum(all.ancestry_hmm.intervals[all.ancestry_hmm.intervals$pop == "SEAK" & all.ancestry_hmm.intervals$state == "UNASSIGNED",]$end - all.ancestry_hmm.intervals[all.ancestry_hmm.intervals$pop == "SEAK" & all.ancestry_hmm.intervals$state == "UNASSIGNED",]$start) / 14

bc.0.bp <- sum(all.ancestry_hmm.intervals[all.ancestry_hmm.intervals$pop == "BC" & all.ancestry_hmm.intervals$state == "0",]$end - all.ancestry_hmm.intervals[all.ancestry_hmm.intervals$pop == "BC" & all.ancestry_hmm.intervals$state == "0",]$start) / 14
bc.1.bp <- sum(all.ancestry_hmm.intervals[all.ancestry_hmm.intervals$pop == "BC" & all.ancestry_hmm.intervals$state == "1",]$end - all.ancestry_hmm.intervals[all.ancestry_hmm.intervals$pop == "BC" & all.ancestry_hmm.intervals$state == "1",]$start) / 14
bc.2.bp <- sum(all.ancestry_hmm.intervals[all.ancestry_hmm.intervals$pop == "BC" & all.ancestry_hmm.intervals$state == "2",]$end - all.ancestry_hmm.intervals[all.ancestry_hmm.intervals$pop == "BC" & all.ancestry_hmm.intervals$state == "2",]$start) / 14

seak.0.bp <- sum(all.ancestry_hmm.intervals[all.ancestry_hmm.intervals$pop == "SEAK" & all.ancestry_hmm.intervals$state == "0",]$end - all.ancestry_hmm.intervals[all.ancestry_hmm.intervals$pop == "SEAK" & all.ancestry_hmm.intervals$state == "0",]$start) / 12
seak.1.bp <- sum(all.ancestry_hmm.intervals[all.ancestry_hmm.intervals$pop == "SEAK" & all.ancestry_hmm.intervals$state == "1",]$end - all.ancestry_hmm.intervals[all.ancestry_hmm.intervals$pop == "SEAK" & all.ancestry_hmm.intervals$state == "1",]$start) / 12
seak.2.bp <- sum(all.ancestry_hmm.intervals[all.ancestry_hmm.intervals$pop == "SEAK" & all.ancestry_hmm.intervals$state == "2",]$end - all.ancestry_hmm.intervals[all.ancestry_hmm.intervals$pop == "SEAK" & all.ancestry_hmm.intervals$state == "2",]$start) / 12

# average rutilus ancestry
(bc.0.bp + (bc.1.bp * 0.5)) / bc.total.bp
(seak.0.bp + (seak.1.bp * 0.5)) / seak.total.bp

# average unassigned ancestry
bc.un.bp / bc.total.bp
seak.un.bp / seak.total.bp

# locations of Nmt genes
Nmt.genes.bed <- read.table("Nmt.genes.chrnames.bed", header = F, col.names = c("gene", "chr", "start", "end"))
summary(Nmt.genes.bed$end - Nmt.genes.bed$start)
sort(Nmt.genes.bed$end - Nmt.genes.bed$start, decreasing = T)
hist(Nmt.genes.bed$end - Nmt.genes.bed$start, breaks = 1000, xlim = c(0,100000))

# make unique
Nmt.genes.bed$v <- 0
for (i in 1:nrow(Nmt.genes.bed)) {
  j <- Nmt.genes.bed$gene[i]
  k <- max(Nmt.genes.bed[Nmt.genes.bed$gene == j,]$v)
  Nmt.genes.bed[i, "v"] <- k+1
}


all_trimmed <- data.frame(matrix(ncol=7, nrow=0))
for (i in 1:nrow(Nmt.genes.bed)) {
  Nmt_gene <- paste0(Nmt.genes.bed$gene[i]," (",Nmt.genes.bed$chr[i],") ",Nmt.genes.bed$v[i])
  Nmt_chr <- Nmt.genes.bed$chr[i]
  Nmt_start <- Nmt.genes.bed$start[i]
  Nmt_end <- Nmt.genes.bed$end[i]
  
  subset_trimmed <- all.ancestry_hmm.intervals %>%
    filter(
      chr == Nmt_chr,
      start <= Nmt_end,
      end   >= Nmt_start
    ) %>%
    mutate(
      start = pmax(start, Nmt_start),
      end   = pmin(end, Nmt_end),
      gene = Nmt_gene
    )
  
  all_trimmed <- rbind(all_trimmed, subset_trimmed)
}



Nmt.genes.ancestry <- ggplot(all_trimmed, aes(xmin = start, xmax = end, y = id, color = factor(state))) +
  geom_linerange(size = 3) +
  facet_wrap(~ gene, scales = "free_x", ncol = 34) +
  scale_color_manual(values = c("0" = "#D8B365", "1" = "grey", "2" = "#5AB4AB", "UNASSIGNED" = "black")) +
  #scale_color_manual(values = c("gap,gap" = "#5AB4AB", "gap,old" = "#D8B365", "gap,new" = "coral", "old,old" = "gold4", "old,new" = "grey", "new,new" = "darkred",  "UNASSIGNED" = "black")) +
  scale_x_continuous(
    breaks = function(x) range(x, na.rm = TRUE),
    expand = c(0,0)
  ) +
  theme_bw() +
  theme(
    strip.background = element_rect(fill = "white"),
    panel.grid = element_blank(),
    axis.title = element_blank(),
    legend.position = "none",
    axis.text.x = element_text(angle = 45, hjust = 1)
  ) 
Nmt.genes.ancestry
#ggsave("Nmt.genes.ancestry.95.BC2.png", Nmt.genes.ancestry, width = 50, height = 120, limitsize = F)




with_buffer_trimmed <- data.frame(matrix(ncol=7, nrow=0))
for (i in 1:nrow(Nmt.genes.bed)) {
  Nmt_gene <- paste0(Nmt.genes.bed$gene[i]," (",Nmt.genes.bed$chr[i],") ",Nmt.genes.bed$v[i])
  Nmt_chr <- Nmt.genes.bed$chr[i]
  Nmt_start <- Nmt.genes.bed$start[i] - 20000
  Nmt_end <- Nmt.genes.bed$end[i] + 20000
  
  subset_trimmed <- all.ancestry_hmm.intervals %>%
    filter(
      chr == Nmt_chr,
      start <= Nmt_end,
      end   >= Nmt_start
    ) %>%
    mutate(
      start = pmax(start, Nmt_start),
      end   = pmin(end, Nmt_end),
      gene = Nmt_gene
    )
  
  with_buffer_trimmed <- rbind(with_buffer_trimmed, subset_trimmed)
}




Nmt.genes.ancestry.with.buffer <- ggplot(with_buffer_trimmed, aes(xmin = start, xmax = end, y = id, color = factor(state))) +
  geom_linerange(size = 3) +
  facet_wrap(~ gene, scales = "free_x", ncol = 34) +
  #scale_color_manual(values = c("0" = "#D8B365", "1" = "grey", "2" = "#5AB4AB", "UNASSIGNED" = "black")) +
  scale_color_manual(values = c("gap,gap" = "#5AB4AB", "gap,old" = "#D8B365", "gap,new" = "coral", "old,old" = "gold4", "old,new" = "grey", "new,new" = "darkred",  "UNASSIGNED" = "black")) +
  scale_x_continuous(
    breaks = function(x) {
      r <- range(x, na.rm = TRUE)
      c(r[1] + 20000, r[2] - 20000)
    },
    expand = c(0,0)
    ) +
  theme_bw() +
  theme(
    strip.background = element_rect(fill = "white"),
    panel.grid = element_blank(),
    axis.title = element_blank(),
    legend.position = "none",
    axis.text.x = element_text(angle = 45, hjust = 1)
  ) 
Nmt.genes.ancestry.with.buffer
#ggsave("Nmt.genes.ancestry.with.buffer.95.BC2.png", Nmt.genes.ancestry.with.buffer, width = 50, height = 120, limitsize = F)





#################################################


# Code written with the assistance of ChatGPT


# Calculate percent rutilus ancestry in each population at each Nmt gene
Nmt_percent_rut <- all_trimmed %>%
  
  # 1. Compute base-pair length of each ancestry interval
  #    and translate ancestry states into rut-weighted bp
  mutate(
    bp = end - start,
    
    # Total diploid bp assigned (exclude UNASSIGNED)
    assigned_bp = if_else(state != "UNASSIGNED", bp * 2, 0),
    
    # Rut ancestry contribution:
    #   homozygous rut (state 0) = 2 rut alleles
    #   heterozygous rut (state 1) = 1 rut allele
    rut_bp = case_when(
      state == 0 ~ bp * 2,
      state == 1 ~ bp * 1,
      TRUE       ~ 0
    )
  ) %>%
  
  # 2. Sum assigned bp and rut bp for each individual within each gene
  group_by(gene, id, pop) %>%
  summarise(
    assigned_bp = sum(assigned_bp),
    rut_bp = sum(rut_bp),
    .groups = "drop"
  ) %>%
  
  # 3. Compute proportion of rut ancestry per individual at each gene
  mutate(
    perc_rut = rut_bp / assigned_bp
  ) %>%
  
  # 4. Keep only the final outputs needed downstream
  select(gene, id, pop, perc_rut)

# Add same unique gene name to bed
Nmt.genes.bed$gene_unique <- paste0(Nmt.genes.bed$gene," (",Nmt.genes.bed$chr,") ",Nmt.genes.bed$v)

# Table with r for each Nmt gene
Nmt.r <- read.table("04.Nmt.r.bed", header = F, col.names = c("chr", "start", "end", "r"))

# Add chr, start, end, and r for each Nmt gene
Nmt_percent_rut$chr <- NA
Nmt_percent_rut$start <- NA
Nmt_percent_rut$end <- NA
Nmt_percent_rut$r <- NA
for (i in unique(Nmt_percent_rut$gene)) {
  t.chr <- Nmt.genes.bed[Nmt.genes.bed$gene_unique == i,]$chr
  t.start <- Nmt.genes.bed[Nmt.genes.bed$gene_unique == i,]$start
  t.end <- Nmt.genes.bed[Nmt.genes.bed$gene_unique == i,]$end
  
  t.r <- Nmt.r[Nmt.r$chr == t.chr & Nmt.r$start == t.start & Nmt.r$end == t.end,]$r
  
  Nmt_percent_rut[Nmt_percent_rut$gene == i, "chr"] <- t.chr
  Nmt_percent_rut[Nmt_percent_rut$gene == i, "start"] <- t.start
  Nmt_percent_rut[Nmt_percent_rut$gene == i, "end"] <- t.end
  Nmt_percent_rut[Nmt_percent_rut$gene == i, "r"] <- t.r
  
}



# length of each Nmt gene
Nmt.genes.bed$bps <- Nmt.genes.bed$end - Nmt.genes.bed$start

# Genome-wide windows, of size equal to the average cM of the Nmt genes
Nmt.cM.windows.rmap <- read.table("Nmt.cM.windows.rmap", header = F, col.names = c("chr", "start", "end", "M"))
Nmt.cM.windows.rmap$bps <- Nmt.cM.windows.rmap$end - Nmt.cM.windows.rmap$start
summary(Nmt.cM.windows.rmap$bps)
sort(Nmt.cM.windows.rmap$bps, decreasing = F)
hist(Nmt.cM.windows.rmap$M, breaks = 1000, xlim = c(0, 0.0005))
hist(Nmt.cM.windows.rmap$bps, breaks = 1000, xlim = c(0, 200000))

# Remove windows with M less than the Nmt average (these are at end of chromosomes)
Nmt.cM.windows.rmap <- Nmt.cM.windows.rmap[!Nmt.cM.windows.rmap$M < 0.00008648929,]
summary(Nmt.cM.windows.rmap$bps)

# Remove windows that are fewer bps than the smallest Nmt gene
nrow(Nmt.cM.windows.rmap[Nmt.cM.windows.rmap$bps < 155,])
Nmt.cM.windows.rmap <- Nmt.cM.windows.rmap[!Nmt.cM.windows.rmap$bps < 155,]

# Remove windows that are longer in M than 0.0005
nrow(Nmt.cM.windows.rmap[Nmt.cM.windows.rmap$M > 0.0005,])
Nmt.cM.windows.rmap <- Nmt.cM.windows.rmap[!Nmt.cM.windows.rmap$M > 0.0005,]
hist(Nmt.cM.windows.rmap$bps, breaks = 1000, xlim = c(0, 200000))
hist(Nmt.cM.windows.rmap$M, breaks = 1000, xlim = c(0, 0.0002))


# Remove windows that overlap with Nmt genes
library(GenomicRanges)

windows_gr <- GRanges(
  seqnames = Nmt.cM.windows.rmap$chr,
  ranges   = IRanges(
    start = Nmt.cM.windows.rmap$start,
    end   = Nmt.cM.windows.rmap$end
  )
)

genes_gr <- GRanges(
  seqnames = Nmt.genes.bed$chr,
  ranges   = IRanges(
    start = Nmt.genes.bed$start,
    end   = Nmt.genes.bed$end
  )
)

no_gene_hits <- !overlapsAny(windows_gr, genes_gr)
Nmt.cM.windows.rmap <- Nmt.cM.windows.rmap[no_gene_hits, ]


# Add window number
Nmt.cM.windows.rmap$window <- 1:nrow(Nmt.cM.windows.rmap)

any(overlapsAny(
  GRanges(seqnames = Nmt.cM.windows.rmap$chr,
          ranges = IRanges(Nmt.cM.windows.rmap$start,
                           Nmt.cM.windows.rmap$end)),
  genes_gr
))



# Break the local ancestry map by the windows
library(data.table)

# Convert to data.table
setDT(all.ancestry_hmm.intervals)
setDT(Nmt.cM.windows.rmap)

# Rename to avoid column collisions
setnames(
  Nmt.cM.windows.rmap,
  old = c("start", "end"),
  new = c("window_start", "window_end")
)

# Set keys for interval overlap
setkey(all.ancestry_hmm.intervals, chr, start, end)
setkey(Nmt.cM.windows.rmap, chr, window_start, window_end)

# Overlap join: ancestry intervals × windows
windows_ancestry <- foverlaps(
  all.ancestry_hmm.intervals,
  Nmt.cM.windows.rmap,
  by.x = c("chr", "start", "end"),
  by.y = c("chr", "window_start", "window_end"),
  type = "any",
  nomatch = 0L
)

# Trim intervals to window boundaries
windows_ancestry[, `:=`(
  start = pmax(start, window_start),
  end   = pmin(end, window_end)
)]

# Keep / order columns as needed
windows_ancestry <- windows_ancestry[
  , .(id, chr, start, end, state, pop, window)
]




# Get the average rutilus ancestry for each individual for each window
windows_percent_rut <- windows_ancestry %>%
  
  # 1. Compute base-pair length of each ancestry interval
  #    and translate ancestry states into rut-weighted bp
  mutate(
    bp = end - start,
    
    # Total diploid bp assigned (exclude UNASSIGNED)
    assigned_bp = if_else(state != "UNASSIGNED", bp * 2, 0),
    
    # Rut ancestry contribution:
    #   homozygous rut (state 0) = 2 rut alleles
    #   heterozygous rut (state 1) = 1 rut allele
    rut_bp = case_when(
      state == 0 ~ bp * 2,
      state == 1 ~ bp * 1,
      TRUE       ~ 0
    )
  ) %>%
  
  # 2. Sum assigned bp and rut bp for each individual within each window
  group_by(window, id, pop) %>%
  summarise(
    assigned_bp = sum(assigned_bp),
    rut_bp = sum(rut_bp),
    .groups = "drop"
  ) %>%
  
  # 3. Compute proportion of rut ancestry per individual at each window
  mutate(
    perc_rut = rut_bp / assigned_bp
  ) %>%
  
  # 4. Keep only the final outputs needed downstream
  select(window, id, pop, perc_rut)



# Add chr, start, end, and r for each Nmt gene
windows_percent_rut$chr <- NA
windows_percent_rut$start <- NA
windows_percent_rut$end <- NA
windows_percent_rut$M <- NA

idx <- match(windows_percent_rut$window, Nmt.cM.windows.rmap$window)

windows_percent_rut$chr   <- Nmt.cM.windows.rmap$chr[idx]
windows_percent_rut$start <- Nmt.cM.windows.rmap$window_start[idx]
windows_percent_rut$end   <- Nmt.cM.windows.rmap$window_end[idx]
windows_percent_rut$M     <- Nmt.cM.windows.rmap$M[idx]








# Pivot the dataframe to matrix input for CAnD style test
BC_rut_Nmts <- Nmt_percent_rut %>%
  filter(pop == "BC") %>%
  select(id, gene, perc_rut) %>%
  pivot_wider(
    names_from  = gene,
    values_from = perc_rut
  ) %>%
  arrange(id)

SEAK_rut_Nmts <- Nmt_percent_rut %>%
  filter(pop == "SEAK") %>%
  select(id, gene, perc_rut) %>%
  pivot_wider(
    names_from  = gene,
    values_from = perc_rut
  ) %>%
  arrange(id)


BC_rut_windows <- windows_percent_rut %>%
  filter(pop == "BC") %>%
  select(id, window, perc_rut) %>%
  pivot_wider(
    names_from  = window,
    values_from = perc_rut
  ) %>%
  arrange(id)

SEAK_rut_windows <- windows_percent_rut %>%
  filter(pop == "SEAK") %>%
  select(id, window, perc_rut) %>%
  pivot_wider(
    names_from  = window,
    values_from = perc_rut
  ) %>%
  arrange(id)


# Modified functions from CAnD
getDiffMatricesSpecial <- function (chrAncest, diff = TRUE, number) 
{
  numChrs <- ncol(chrAncest)
  n <- nrow(chrAncest)
  rowmns <- function(x) {
    rowMeans(chrAncest[-c(x)], na.rm = T)
  }
  res <- vapply(seq_len(number), rowmns, rep(0, n))
  if (diff) {
    diff_means <- res - chrAncest
  }
  else {
    diff_means <- res
  }
  return(diff_means)
}



#Combine the Nmt and genomic window dataframes
BC_ancestries <- cbind(BC_rut_Nmts[,-1], BC_rut_windows[,-1])
SEAK_ancestries <- cbind(SEAK_rut_Nmts[,-1], SEAK_rut_windows[,-1])

ncol(BC_rut_Nmts[,-1])
ncol(SEAK_rut_Nmts[,-1])

colMeans(BC_ancestries, na.rm = T)
mean(colMeans(BC_ancestries), na.rm = T)
rowMeans(BC_ancestries, na.rm = T)
mean(rowMeans(BC_ancestries, na.rm = T))


library(CAnD)
CAnD()

# CAnD function to only test the Nmt genes for deviations, instead of every window
CAnD_test <- function(ancestries, Nmt, Bonf) {
  
  diff_means <- getDiffMatricesSpecial(ancestries, diff = F, number = Nmt)
  
  pairedTtestSpecial <- function(x) {
    tryCatch(
      t.test(ancestries[, x], diff_means[, x], paired = TRUE)$p.value,
      error = function(e) NA_real_
    )
  }
  
  pval <- vapply(seq_len(Nmt), pairedTtestSpecial, 0)
  pval <- pval * Bonf
  pval <- ifelse(pval > 1, 1, pval)
  
  df <- data.frame(gene = colnames(ancestries[, 1:Nmt]),
             perc_rut = colMeans(ancestries[, 1:Nmt], na.rm = T),
             p = pval)
  return(df)
}

# Run test
BC_Nmt_genes_sig <- CAnD_test(ancestries = BC_ancestries, Nmt = 1124, Bonf = 1124)
SEAK_Nmt_genes_sig <- CAnD_test(ancestries = SEAK_ancestries, Nmt = 1124, Bonf = 1124)


# Filter for genes that have higher rutilus ancestry than genome-wide average, and p-value < 0.05
BC_outliers <- BC_Nmt_genes_sig[BC_Nmt_genes_sig$perc_rut > 0.0783128 & BC_Nmt_genes_sig$p < 0.05,]
SEAK_outliers <- SEAK_Nmt_genes_sig[SEAK_Nmt_genes_sig$perc_rut > 0.01420663 & SEAK_Nmt_genes_sig$p < 0.05,]

# Add same unique gene name to bed
Nmt.genes.bed$gene_unique <- paste0(Nmt.genes.bed$gene," (",Nmt.genes.bed$chr,") ",Nmt.genes.bed$v)
write.table(Nmt.genes.bed, file = "Nmt.genes.ALL.bed", quote = F, sep = "\t", col.names = T, row.names = F)

# Get bed file for locations of Nmt outliers
Nmt.genes.bed[Nmt.genes.bed$gene_unique %in% c(BC_outliers$gene, SEAK_outliers$gene), 1:4]
Nmt.genes.selection.bed <- Nmt.genes.bed[Nmt.genes.bed$gene_unique %in% c(BC_outliers$gene, SEAK_outliers$gene), 1:4]

Nmt.genes.selection.bed$location <- paste0(Nmt.genes.selection.bed$chr, ":", Nmt.genes.selection.bed$start, "-", Nmt.genes.selection.bed$end)
Nmt.genes.selection.bed <- Nmt.genes.selection.bed[,c(1,5)]

write.table(Nmt.genes.selection.bed, file = "Nmt.genes.selection.bed", quote = F, sep = "\t", col.names = F, row.names = F)

# Get bed file for locations of Nmt outliers + 20kb buffer
Nmt.genes.bed[Nmt.genes.bed$gene_unique %in% c(BC_outliers$gene, SEAK_outliers$gene), 1:4]
Nmt.genes.selection.bed <- Nmt.genes.bed[Nmt.genes.bed$gene_unique %in% c(BC_outliers$gene, SEAK_outliers$gene), 1:4]
Nmt.genes.selection.bed$start <- Nmt.genes.selection.bed$start - 20000
Nmt.genes.selection.bed$end <- Nmt.genes.selection.bed$end + 20000

Nmt.genes.selection.bed$location <- paste0(Nmt.genes.selection.bed$chr, ":", Nmt.genes.selection.bed$start, "-", Nmt.genes.selection.bed$end)
Nmt.genes.selection.bed <- Nmt.genes.selection.bed[,c(1,5)]

write.table(Nmt.genes.selection.bed, file = "Nmt.genes.selection.20kb.buffer.bed", quote = F, sep = "\t", col.names = F, row.names = F)




Nmt.genes.selection.bed <- Nmt.genes.bed[Nmt.genes.bed$gene_unique %in% c(BC_outliers$gene, SEAK_outliers$gene), ]
write.table(Nmt.genes.selection.bed, file = "Nmt.genes.selection.dataframe.bed", quote = F, sep = "\t", col.names = T, row.names = T)

with_buffer_trimmed_outliers <- data.frame(matrix(ncol=7, nrow=0))
for (i in 1:nrow(Nmt.genes.selection.bed)) {
  Nmt_gene <- paste0(Nmt.genes.selection.bed$gene[i]," (",Nmt.genes.selection.bed$chr[i],") ",Nmt.genes.selection.bed$v[i])
  Nmt_chr <- Nmt.genes.selection.bed$chr[i]
  Nmt_start <- Nmt.genes.selection.bed$start[i] - 3000000
  Nmt_end <- Nmt.genes.selection.bed$end[i] + 3000000
  
  subset_trimmed <- all.ancestry_hmm.intervals %>%
    filter(
      chr == Nmt_chr,
      start <= Nmt_end,
      end   >= Nmt_start
    ) %>%
    mutate(
      start = pmax(start, Nmt_start),
      end   = pmin(end, Nmt_end),
      gene = Nmt_gene
    )
  
  with_buffer_trimmed_outliers <- rbind(with_buffer_trimmed_outliers, subset_trimmed)
}


ggplot(with_buffer_trimmed_outliers, aes(xmin = start, xmax = end, y = id, color = factor(state))) +
  geom_linerange(size = 3) +
  facet_wrap(~ gene, scales = "free_x", ncol = 6) +
  scale_color_manual(values = c("0" = "#D8B365", "1" = "grey", "2" = "#5AB4AB", "UNASSIGNED" = "black")) +
  scale_x_continuous(
    breaks = function(x) {
      r <- range(x, na.rm = TRUE)
      c(r[1] + 3000000, r[2] - 3000000)
    },
    expand = c(0,0)
  ) +
  theme_bw() +
  theme(
    strip.background = element_rect(fill = "white"),
    panel.grid = element_blank(),
    axis.title = element_blank(),
    legend.position = "none",
    axis.text.x = element_text(angle = 45, hjust = 1)
  ) 

"Hemk1 (CM105767.1) 1"
"Kars (CM105782.1) 1"
"Me2 (CM105777.1) 1"
"Nt5dc2 (CM105769.1) 1"
"Acsm5 (CM105772.1) 1"
"Cox15 (CM105772.1) 1"
"Neu4 (CM105765.1) 1"
"Ndufa6 (CM105783.1) 1"
"Rdh13 (CM105765.1) 1"
"Acadsb (CM105772.1) 1"
ggplot(with_buffer_trimmed_outliers[with_buffer_trimmed_outliers$gene == "Kars (CM105782.1) 1",], aes(xmin = start, xmax = end, y = id, color = factor(state))) +
  geom_linerange(size = 3) +
  facet_wrap(~ gene, scales = "free_x", ncol = 6) +
  scale_color_manual(values = c("0" = "#D8B365", "1" = "grey", "2" = "#5AB4AB", "UNASSIGNED" = "black")) +
  scale_x_continuous(
    breaks = function(x) {
      r <- range(x, na.rm = TRUE)
      c(r[1], r[1] + 3000000, r[2] - 3000000, r[2])
    },
    expand = c(0,0)
  ) +
  theme_bw() +
  theme(
    strip.background = element_rect(fill = "white"),
    panel.grid = element_blank(),
    axis.title = element_blank(),
    legend.position = "none",
    axis.text.x = element_text(angle = 45, hjust = 1)
  ) 





with_buffer_trimmed_outliers <- with_buffer_trimmed[with_buffer_trimmed$gene %in% c(BC_outliers$gene, SEAK_outliers$gene),]
all_trimmed_outliers <- all_trimmed[all_trimmed$gene %in% c(BC_outliers$gene, SEAK_outliers$gene),]

ggplot(with_buffer_trimmed_outliers, aes(xmin = start, xmax = end, y = id, color = factor(state))) +
  geom_linerange(size = 3) +
  facet_wrap(~ gene, scales = "free_x", ncol = 6) +
  scale_color_manual(values = c("0" = "#D8B365", "1" = "grey", "2" = "#5AB4AB", "UNASSIGNED" = "black")) +
  #scale_color_manual(values = c("gap,gap" = "#5AB4AB", "gap,old" = "#D8B365", "gap,new" = "coral", "old,old" = "gold4", "old,new" = "grey", "new,new" = "darkred",  "UNASSIGNED" = "black")) +
  scale_x_continuous(
    breaks = function(x) {
      r <- range(x, na.rm = TRUE)
      c(r[1] + 20000, r[2] - 20000)
    },
    expand = c(0,0)
  ) +
  theme_bw() +
  theme(
    strip.background = element_rect(fill = "white"),
    panel.grid = element_blank(),
    axis.title = element_blank(),
    legend.position = "none",
    axis.text.x = element_text(angle = 45, hjust = 1)
  ) 

ggplot(all_trimmed_outliers, aes(xmin = start, xmax = end, y = id, color = factor(state))) +
  geom_linerange(size = 3) +
  facet_wrap(~ gene, scales = "free_x", ncol = 6) +
  scale_color_manual(values = c("0" = "#D8B365", "1" = "grey", "2" = "#5AB4AB", "UNASSIGNED" = "black")) +
  scale_x_continuous(
    breaks = function(x) range(x, na.rm = TRUE),
    expand = c(0,0)
  ) +
  theme_bw() +
  theme(
    strip.background = element_rect(fill = "white"),
    panel.grid = element_blank(),
    axis.title = element_blank(),
    legend.position = "none",
    axis.text.x = element_text(angle = 45, hjust = 1)
  ) 



###################################################
####         Ancestry and Recombination        ####
###################################################



# Get the average rutilus ancestry for each individual for each window
windows_percent_rut_pops <- windows_ancestry %>%
  
  # 1. Compute base-pair length of each ancestry interval
  #    and translate ancestry states into rut-weighted bp
  mutate(
    bp = end - start,
    
    # Total diploid bp assigned (exclude UNASSIGNED)
    assigned_bp = if_else(state != "UNASSIGNED", bp * 2, 0),
    
    # Rut ancestry contribution:
    #   homozygous rut (state 0) = 2 rut alleles
    #   heterozygous rut (state 1) = 1 rut allele
    rut_bp = case_when(
      state == 0 ~ bp * 2,
      state == 1 ~ bp * 1,
      TRUE       ~ 0
    )
  ) %>%
  
  # 2. Sum assigned bp and rut bp for each individual within each window
  group_by(window, pop) %>%
  summarise(
    assigned_bp = sum(assigned_bp),
    rut_bp = sum(rut_bp),
    .groups = "drop"
  ) %>%
  
  # 3. Compute proportion of rut ancestry per individual at each window
  mutate(
    perc_rut = rut_bp / assigned_bp
  ) %>%
  
  # 4. Keep only the final outputs needed downstream
  select(window, pop, perc_rut)



# Add chr, start, end, and r for each Nmt gene
windows_percent_rut_pops$chr <- NA
windows_percent_rut_pops$start <- NA
windows_percent_rut_pops$end <- NA
windows_percent_rut_pops$M <- NA

idx <- match(windows_percent_rut_pops$window, Nmt.cM.windows.rmap$window)

windows_percent_rut_pops$chr   <- Nmt.cM.windows.rmap$chr[idx]
windows_percent_rut_pops$start <- Nmt.cM.windows.rmap$window_start[idx]
windows_percent_rut_pops$end   <- Nmt.cM.windows.rmap$window_end[idx]
windows_percent_rut_pops$M     <- Nmt.cM.windows.rmap$M[idx]

# Calculate average per base r from Morgans and length
windows_percent_rut_pops$r <- windows_percent_rut_pops$M / (windows_percent_rut_pops$end - windows_percent_rut_pops$start)
# Add identifier 
windows_percent_rut_pops$type <- 'window'






# Calculate percent rutilus ancestry in each population at each Nmt gene
Nmt_percent_rut_pops <- all_trimmed %>%
  
  # 1. Compute base-pair length of each ancestry interval
  #    and translate ancestry states into rut-weighted bp
  mutate(
    bp = end - start,
    
    # Total diploid bp assigned (exclude UNASSIGNED)
    assigned_bp = if_else(state != "UNASSIGNED", bp * 2, 0),
    
    # Rut ancestry contribution:
    #   homozygous rut (state 0) = 2 rut alleles
    #   heterozygous rut (state 1) = 1 rut allele
    rut_bp = case_when(
      state == 0 ~ bp * 2,
      state == 1 ~ bp * 1,
      TRUE       ~ 0
    )
  ) %>%
  
  # 2. Sum assigned bp and rut bp for each individual within each gene
  group_by(gene, pop) %>%
  summarise(
    assigned_bp = sum(assigned_bp),
    rut_bp = sum(rut_bp),
    .groups = "drop"
  ) %>%
  
  # 3. Compute proportion of rut ancestry per individual at each gene
  mutate(
    perc_rut = rut_bp / assigned_bp
  ) %>%
  
  # 4. Keep only the final outputs needed downstream
  select(gene, pop, perc_rut)

# Add same unique gene name to bed
Nmt.genes.bed$gene_unique <- paste0(Nmt.genes.bed$gene," (",Nmt.genes.bed$chr,") ",Nmt.genes.bed$v)

# Table with r for each Nmt gene
Nmt.r <- read.table("04.Nmt.r.bed", header = F, col.names = c("chr", "start", "end", "r"))

# Add chr, start, end, and r for each Nmt gene
Nmt_percent_rut_pops$chr <- NA
Nmt_percent_rut_pops$start <- NA
Nmt_percent_rut_pops$end <- NA
Nmt_percent_rut_pops$M <- NA
Nmt_percent_rut_pops$r <- NA
for (i in unique(Nmt_percent_rut_pops$gene)) {
  t.chr <- Nmt.genes.bed[Nmt.genes.bed$gene_unique == i,]$chr
  t.start <- Nmt.genes.bed[Nmt.genes.bed$gene_unique == i,]$start
  t.end <- Nmt.genes.bed[Nmt.genes.bed$gene_unique == i,]$end
  
  t.r <- Nmt.r[Nmt.r$chr == t.chr & Nmt.r$start == t.start & Nmt.r$end == t.end,]$r
  
  Nmt_percent_rut_pops[Nmt_percent_rut_pops$gene == i, "chr"] <- t.chr
  Nmt_percent_rut_pops[Nmt_percent_rut_pops$gene == i, "start"] <- t.start
  Nmt_percent_rut_pops[Nmt_percent_rut_pops$gene == i, "end"] <- t.end
  Nmt_percent_rut_pops[Nmt_percent_rut_pops$gene == i, "r"] <- t.r
  
}

# finish dataframe
Nmt_percent_rut_pops$M <- Nmt_percent_rut_pops$r * (Nmt_percent_rut_pops$end - Nmt_percent_rut_pops$start)
Nmt_percent_rut_pops$type <- "Nmt_gene"

# combine Nmt_genes and windows
all_percent_rut_pops <- windows_percent_rut_pops
colnames(all_percent_rut_pops) <- colnames(Nmt_percent_rut_pops)
all_percent_rut_pops <- rbind(all_percent_rut_pops, Nmt_percent_rut_pops)

# Max r for Nmt_gene
max(Nmt_percent_rut_pops$r)







set.seed(56721894)
r_rutilus_anc <- ggplot(all_percent_rut_pops, aes(x = r, y = perc_rut, shape = type, colour = type)) +
  geom_jitter(cex = 0.5, alpha = 1, width = 2.5e-9, height = 0.005) +
  scale_color_manual(values =  c("red3", "grey70")) +
  scale_shape_manual(values =  c(4, 16)) +
  #geom_smooth(aes(group = 1), formula = y ~ x, method = lm, color = "black") +
  
  geom_smooth(
    data = subset(all_percent_rut_pops, type == "window"),
    aes(x = r, y = perc_rut),
    method = lm,
    se = FALSE,
    color = "black"
  ) +
  
  facet_wrap( ~ pop) +
  xlab("average rate") +
  ylab("proportion rutilus ancestry") +
  labs(title = ) +
  coord_cartesian(ylim = c(0, 1)) +
  scale_x_continuous(limits = c(0, 5e-7)) + 
  theme_bw() +
  guides(color = "none") +
  theme(legend.position = "none")
set.seed(56721894)
r_rutilus_anc
set.seed(56721894)
ggsave(filename = "r_vs_rutilus_ancestry.pdf", r_rutilus_anc, width = 8, height = 4)
set.seed(56721894)
ggsave(filename = "r_vs_rutilus_ancestry.png", r_rutilus_anc, width = 8, height = 4)

set.seed(56721894)
r_rutilus_anc_ALL_GREY <- ggplot(all_percent_rut_pops, aes(x = r, y = perc_rut, shape = type, colour = type)) +
  geom_jitter(cex = 0.5, alpha = 1, width = 2.5e-9, height = 0.005) +
  scale_color_manual(values =  c("grey70", "grey70")) +
  scale_shape_manual(values =  c(16, 16)) +
  #geom_smooth(aes(group = 1), formula = y ~ x, method = lm, color = "black") +
  
  geom_smooth(
    data = subset(all_percent_rut_pops, type == "window"),
    aes(x = r, y = perc_rut),
    method = lm,
    se = FALSE,
    color = "black"
  ) +
  
  facet_wrap( ~ pop) +
  xlab("average rate") +
  ylab("proportion rutilus ancestry") +
  labs(title = ) +
  coord_cartesian(ylim = c(0, 1)) +
  scale_x_continuous(limits = c(0, 5e-7)) + 
  theme_bw() +
  guides(color = "none") +
  theme(legend.position = "none")
set.seed(56721894)
r_rutilus_anc_ALL_GREY
set.seed(56721894)
ggsave(filename = "r_vs_rutilus_ancestry_ALL_GREY.png", r_rutilus_anc_ALL_GREY, width = 8, height = 4)

all_percent_rut_pops_no_high_r <- all_percent_rut_pops[all_percent_rut_pops$r < 5e-7,]

summary(lm(perc_rut ~ r, data = all_percent_rut_pops[all_percent_rut_pops$pop == "SEAK" & all_percent_rut_pops$type == "window",]))
summary(lm(perc_rut ~ r, data = all_percent_rut_pops[all_percent_rut_pops$pop == "BC" & all_percent_rut_pops$type == "window",]))

SEAK_window_r <- all_percent_rut_pops[all_percent_rut_pops$pop == "SEAK" & all_percent_rut_pops$type == "window",]$r
SEAK_Nmt_r <- all_percent_rut_pops[all_percent_rut_pops$pop == "SEAK" & all_percent_rut_pops$type == "Nmt_gene",]$r
BC_window_r <- all_percent_rut_pops[all_percent_rut_pops$pop == "BC" & all_percent_rut_pops$type == "window",]$r
BC_Nmt_r <- all_percent_rut_pops[all_percent_rut_pops$pop == "BC" & all_percent_rut_pops$type == "Nmt_gene",]$r
ks.test(SEAK_Nmt_r, SEAK_window_r)
ks.test(BC_Nmt_r, BC_window_r)


ggplot(all_percent_rut_pops_no_high_r, aes(x = type, y = perc_rut, colour = type)) +
  geom_boxplot(cex = 0.5, alpha = 1) +
  scale_color_manual(values =  c("green", "grey")) +
  facet_wrap( ~ pop) +
  xlab("type") +
  ylab("percent rutilus ancestry") +
  labs(title = ) +
  coord_cartesian(ylim = c(0, 1)) +
  guides(color = "none") +
  theme(legend.position = "none") +
  theme_bw()


SEAK_Nmt_perc_rut <- all_percent_rut_pops[all_percent_rut_pops$pop == "SEAK" & all_percent_rut_pops$type == "Nmt_gene",]$perc_rut
SEAK_window_perc_rut <- all_percent_rut_pops[all_percent_rut_pops$pop == "SEAK" & all_percent_rut_pops$type == "window",]$perc_rut
BC_Nmt_perc_rut <- all_percent_rut_pops[all_percent_rut_pops$pop == "BC" & all_percent_rut_pops$type == "Nmt_gene",]$perc_rut
BC_window_perc_rut <- all_percent_rut_pops[all_percent_rut_pops$pop == "BC" & all_percent_rut_pops$type == "window",]$perc_rut


mean(SEAK_Nmt_perc_rut)
set.seed(-145045712)
SEAK_random <- colMeans(replicate(n = 10000, expr = sample(SEAK_window_perc_rut, size = length(SEAK_Nmt_perc_rut), replace = F)), na.rm = T)

mean(BC_Nmt_perc_rut)
set.seed(84675)
BC_random <- colMeans(replicate(n = 10000, expr = sample(BC_window_perc_rut, size = length(BC_Nmt_perc_rut), replace = F)), na.rm = T)
random <- data.frame(perc_rut = c(BC_random, SEAK_random),
                     pop = c(rep("BC", length(BC_random)), rep("SEAK", length(SEAK_random))))

mean <- data.frame(Nmt_mean = c(mean(BC_Nmt_perc_rut), mean(SEAK_Nmt_perc_rut)),
                   pop = c("BC", "SEAK"))
quants <- data.frame(quants = c(quantile(BC_random, probs = c(0.025, 0.975)), quantile(SEAK_random, probs = c(0.025, 0.975))),
                   pop = c("BC", "BC", "SEAK", "SEAK"))
quantile(BC_random, probs = c(0.025, 0.975))
mean(BC_Nmt_perc_rut, na.rm = T)
quantile(BC_random, probs = c(0.999999))

quantile(SEAK_random, probs = c(0.025, 0.975))
mean(SEAK_Nmt_perc_rut, na.rm = T)
quantile(SEAK_random, probs = c(0.9998288))

hist_prop_rut <- ggplot(random, aes(x = perc_rut, fill = pop)) +
  geom_histogram() +
  geom_point(data = mean, aes(x = Nmt_mean, y = 0), color = "red") +
  #geom_point(data = quants, aes(x = quants, y = 0)) +
  #geom_segment(data = mean, aes(x = Nmt_mean, y = 0, yend = 2000), color = "red") +
  geom_segment(data = quants, aes(x = quants, y = 0, yend = 2000), linetype = "dashed", color = "black") +
  scale_fill_manual(values =  c("grey", "grey")) +
  facet_wrap( ~ pop, scales = "free_x") +
  ylab("counts") +
  xlab("proportion rutilus ancestry") +
  labs(title = ) +
  coord_cartesian(ylim = c(0, 1400)) +
  guides(fill = "none") +
  theme(legend.position = "none") +
  theme_bw()
hist_prop_rut
ggsave(filename = "hist_prop_rut.pdf", hist_prop_rut, width = 8, height = 2)


?ks.test
ks.test(SEAK_Nmt_perc_rut, SEAK_window_perc_rut)
ks.test(BC_Nmt_perc_rut, BC_window_perc_rut)

mean(SEAK_Nmt_perc_rut, na.rm = T)
mean(SEAK_window_perc_rut, na.rm = T)
mean(BC_Nmt_perc_rut, na.rm = T)
mean(BC_window_perc_rut, na.rm = T)





density_by_type <- ggplot(all_percent_rut_pops, aes(x = perc_rut)) +
  
  ## window (positive)
  geom_histogram(
    data = subset(all_percent_rut_pops, type == "window"),
    aes(y = after_stat(density)),
    binwidth = 0.04,
    fill = "grey70",
    color = NA,
    alpha = 1
  ) +
  
  ## nmt_gene (negative)
  geom_histogram(
    data = subset(all_percent_rut_pops, type == "Nmt_gene"),
    aes(y = -after_stat(density)),
    binwidth = 0.04,
    fill = "red3",
    color = NA,
    alpha = 1
  ) +
  
  facet_wrap(~ pop, scales = "free_y") +
  geom_hline(yintercept = 0, linetype = "dashed", colour = "black") +
  scale_y_continuous(labels = abs) +
  xlab("proportion rutilus ancestry") +
  ylab("Density (%)") +
  theme_bw() +
  theme(
    legend.position = "none",
    panel.grid = element_blank()
  ) 
density_by_type
ggsave(filename = "density_by_type.pdf", density_by_type, width = 8, height = 4)



density_by_type_zoom <- ggplot(all_percent_rut_pops, aes(x = perc_rut)) +
  
  ## window (positive)
  geom_histogram(
    data = subset(all_percent_rut_pops, type == "window"),
    aes(y = after_stat(density)),
    binwidth = 0.04,
    fill = "gray70",
    color = NA,
    alpha = 1
  ) +
  
  ## nmt_gene (negative)
  geom_histogram(
    data = subset(all_percent_rut_pops, type == "Nmt_gene"),
    aes(y = -after_stat(density)),
    binwidth = 0.04,
    fill = "red3",
    color = NA,
    alpha = 1
  ) +
  
  facet_wrap(~ pop, scales = "free_y") +
  geom_hline(yintercept = 0, linetype = "dashed", colour = "black") +
  scale_y_continuous(labels = abs, breaks = c(-0.2,0,0.2)) +
  #xlab("proportion rutilus ancestry") +
  #ylab("Density (%)") +
  theme_bw() +
  theme(
    legend.position = "none",
    axis.title.x = element_blank(),
    axis.title.y = element_blank(),
    strip.text = element_blank(),
    panel.grid = element_blank()
  ) +
  coord_cartesian(xlim = c(0.4, 1.05), ylim = c(-0.25, 0.25))
density_by_type_zoom
ggsave(filename = "density_by_type_zoom.pdf", density_by_type_zoom, width = 4, height = 1)
