setwd("/kuhpc/work/colella/ben/009.RBV.WGS/08.call.snps/")

args <- commandArgs()
print(args)
file <- args[2]
print(file)


setwd("/kuhpc/scratch/bi/b686w673/009.RBV.WGS/08.call.snps/")
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



