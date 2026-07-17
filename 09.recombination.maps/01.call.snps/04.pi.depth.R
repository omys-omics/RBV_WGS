setwd("/kuhpc/work/colella/ben/009.RBV.WGS/09.recombination.maps/01.call.snps/")

args <- commandArgs()
print(args)
file <- args[2]
print(file)
species <- args[3]
print(species)

setwd(paste0("/kuhpc/scratch/bi/b686w673/009.RBV.WGS/09.recombination.maps/01.call.snps/", species))
getwd()

library(vcfR)
library(ggplot2)
library(SNPfiltR)

# read in vcf
vcf <- read.vcfR(file)
vcf

# Make depth dataframe
depth <- extract.gt(vcf, element = "DP", as.numeric=TRUE)
print(depth[is.na(depth)])
depth <- data.frame(depth)


# Make genotype matrix
g <- extract.gt(vcf)


pis <- data.frame(matrix(ncol = 3, nrow = 0))
for (i in 1:100) {
  temp.g <- g
  temp.g[depth!=i] <- NA
  print(i)

  # count number of sites with i depth
  count <- colSums(!is.na(temp.g))
  
  # calculate pi for each sample for given depth
  pi <- colSums(temp.g=="0/1", na.rm = T) / count
  
  # build dataframe
  pis <- rbind(pis, cbind(names(pi), i, pi, count))
} 
colnames(pis) <- c("id", "depth", "pi", "count")

# make numeric
pis$depth <- as.numeric(pis$depth)
pis$pi <- as.numeric(pis$pi)
pis$count <- as.numeric(pis$count)

# fix the divide by 0 issue
pis[pis$pi == "NaN", "pi"] <- 0

# Plot pi
pi.plot <- ggplot(pis, aes(x = depth, y = pi, color = id)) +
  geom_line()
pi.plot
ggsave("pi.plot.pdf", plot = pi.plot, width = 12, height = 8)

pi.plot.50 <- ggplot(pis, aes(x = depth, y = pi, color = id)) +
  geom_line() +
  scale_x_continuous(limits = c(0,50))
pi.plot.50
ggsave("pi.plot.50.pdf", plot = pi.plot.50, width = 12, height = 8)

# Plot count
count.plot <- ggplot(pis, aes(x = depth, y = count, color = id)) +
  geom_line()
count.plot
ggsave("count.plot.pdf", plot = count.plot, width = 12, height = 8)

count.plot.50 <- ggplot(pis, aes(x = depth, y = count, color = id)) +
  geom_line() +
  scale_x_continuous(limits = c(0,50))
count.plot.50
ggsave("count.plot.50.pdf", plot = count.plot.50, width = 12, height = 8)



# Filter hets by allelic depth
vcf.ad <- filter_allele_balance(vcf, min.ratio = 0.1, max.ratio = 0.9)
vcf.ad <- min_mac(vcf.ad, min.mac = 2)

# Make depth dataframe
depth.ad <- extract.gt(vcf.ad, element = "DP", as.numeric=TRUE)
print(depth.ad[is.na(depth.ad)])
depth.ad <- data.frame(depth.ad)


# Make genotype matrix
g.ad <- extract.gt(vcf.ad)


pis.ad <- data.frame(matrix(ncol = 3, nrow = 0))
for (i in 1:100) {
  temp.g.ad <- g.ad
  temp.g.ad[depth.ad!=i] <- NA
  print(i)

  # count number of sites with i depth
  count.ad <- colSums(!is.na(temp.g.ad))
  
  # calculate pi for each sample for given depth
  pi.ad <- colSums(temp.g.ad=="0/1", na.rm = T) / count.ad
  
  # build dataframe
  pis.ad <- rbind(pis.ad, cbind(names(pi.ad), i, pi.ad, count.ad))
} 
colnames(pis.ad) <- c("id", "depth", "pi", "count")

# make numeric
pis.ad$depth <- as.numeric(pis.ad$depth)
pis.ad$pi <- as.numeric(pis.ad$pi)
pis.ad$count <- as.numeric(pis.ad$count)

# fix the divide by 0 issue
pis.ad[pis.ad$pi == "NaN", "pi"] <- 0

# Plot pi
pi.plot.ad <- ggplot(pis.ad, aes(x = depth, y = pi, color = id)) +
  geom_line()
pi.plot.ad
ggsave("pi.plot.ad.pdf", plot = pi.plot.ad, width = 12, height = 8)

pi.plot.50.ad <- ggplot(pis.ad, aes(x = depth, y = pi, color = id)) +
  geom_line() +
  scale_x_continuous(limits = c(0,50))
pi.plot.50.ad
ggsave("pi.plot.50.ad.pdf", plot = pi.plot.50.ad, width = 12, height = 8)

# Plot count
count.plot.ad <- ggplot(pis.ad, aes(x = depth, y = count, color = id)) +
  geom_line()
count.plot.ad
ggsave("count.plot.ad.pdf", plot = count.plot.ad, width = 12, height = 8)

count.plot.50.ad <- ggplot(pis.ad, aes(x = depth, y = count, color = id)) +
  geom_line() +
  scale_x_continuous(limits = c(0,50))
count.plot.50.ad
ggsave("count.plot.50.ad.pdf", plot = count.plot.50.ad, width = 12, height = 8)

