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

# read in vcf
vcf <- read.vcfR(file)
vcf


# Make depth dataframe
depth <- extract.gt(vcf, element = "DP", as.numeric=TRUE)
print(depth[is.na(depth)])
depth <- data.frame(depth)
mean.depth <- colMeans(depth, na.rm=T)
print(sort(mean.depth))
summary(depth)



###############################################################
#####                       FILTER                        #####
###############################################################

# Quantiles
depth.quantiles <- apply(depth, 2, quantile, probs = c(0.05, 0.1, 0.15, 0.2, 0.25, 0.3, 0.35, 0.4, 0.45, 0.5, 0.55, 0.6, 0.65, 0.7, 0.75, 0.8, 0.85, 0.9, 0.95))


# genotype matrix
gt <- vcf@gt
ht <- gt

# maximum threshold for each individual
max.depth <- depth.quantiles["95%",]

# Broadcast thresholds across all rows
min.pass <- depth >= 10
max.pass <- sweep(depth, 2, max.depth, FUN = "<=")

# Apply the mask to genotype matrix (convert genotype to missing while keeping other data, e.g. depth, allelic depth. etc)
ht[,-1][!min.pass] <- sub("^[^:]+", "./.", ht[,-1][!min.pass])
ht[,-1][!max.pass] <- sub("^[^:]+", "./.", ht[,-1][!max.pass])

# do same thing to depth matrix
depth_filtered <- depth
depth_filtered[!min.pass] <- NA
depth_filtered[!max.pass] <- NA
summary(depth_filtered)


vcf.filtered <- vcf
vcf.filtered@gt <- ht
vcf.filtered

write.vcf(vcf.filtered, file = "07.depth.filtered.10.95.vcf.gz")



###############################################################
#####                        PRE                          #####
###############################################################



#################################
##########     AFS    ###########        
#################################
g <- extract.gt(vcf)
h <- g
h[h == "0/0"] <- 0
h[h == "0/1"] <- 1
h[h == "1/1"] <- 2
h <- apply(h, 2, as.numeric)

allele.counts <- data.frame(samples = "CLGA",
                            counts = rowSums(h, na.rm = T))
# folded
allele.counts[allele.counts$counts > 13, "counts"] <- (26 - allele.counts[allele.counts$counts > 13, "counts"])

pre.afs <- ggplot(allele.counts, aes(x = counts, fill = samples)) +
  geom_histogram(bins = 100) +
  scale_x_continuous(breaks = c(0,2,4,6,8,10,12), limits = c(0,14))
ggsave("pre.afs.pdf", plot = pre.afs, width = 12, height = 8)



#######################################
##########     het/depth    ###########        
#######################################
het <- colSums(g=="0/1", na.rm = T) / colSums(!is.na(g))
het.depth <- data.frame(id=colnames(depth), depth=mean.depth, het=het)

pre.het.depth <- ggplot(het.depth, aes(x=depth, y=het, color = id)) +
  geom_point()
ggsave("pre.het.depth.pdf", plot = pre.het.depth, width = 12, height = 8)



#######################################
###          allele balance        ####        
#######################################
extract.allele.balance <- function (vcfR) {
  ad.matrix <- vcfR::extract.gt(vcfR, element = "AD")
  if (length(grep("AD", vcfR@gt[, 1])) > 0.5) {
    ad.matrix <- vcfR::extract.gt(vcfR, element = "AD")
  }

  gt.matrix <- vcfR::extract.gt(vcfR, element = "GT")
  al1 <- structure(as.numeric(gsub(",.*", "", ad.matrix)), 
                   dim = dim(ad.matrix))
  al2 <- structure(as.numeric(gsub(".*,", "", ad.matrix)), 
                   dim = dim(ad.matrix))
  al.bal <- al2/(al1 + al2)
  return(al.bal)
}

AB <- data.frame(matrix(nrow = 0, ncol = 2))
for (i in colnames(extract.gt(vcf))) {
  AB <- rbind(AB, cbind(i, extract.allele.balance(vcf[,,i]), c(g[,i])))
  print(i)
  print(date())
}

colnames(AB) <- c("id", "AB", "gt")
AB$AB <- as.numeric(AB$AB)
AB <- AB[!is.na(AB$gt),]
pre.AB <- ggplot(AB, aes(x = AB, color = id)) +
  facet_wrap(~gt) +
  geom_density() +
  ylim(0,10)
ggsave("pre.AB.pdf", plot = pre.AB, width = 12, height = 8)






###############################################################
#####                        POST                         #####
###############################################################
g <- extract.gt(vcf.filtered)
depth <- extract.gt(vcf.filtered, element = "DP", as.numeric=TRUE)
depth[is.na(g)] <- NA
print(depth[is.na(depth)])
depth <- data.frame(depth)
mean.depth <- colMeans(depth, na.rm=T)
print(sort(mean.depth))
summary(depth)



#################################
##########     AFS    ###########        
#################################

h <- g
h[h == "0/0"] <- 0
h[h == "0/1"] <- 1
h[h == "1/1"] <- 2
h <- apply(h, 2, as.numeric)

allele.counts <- data.frame(samples = "CLGA",
                            counts = rowSums(h, na.rm = T))
# folded
allele.counts[allele.counts$counts > 13, "counts"] <- (26 - allele.counts[allele.counts$counts > 13, "counts"])

post.afs <- ggplot(allele.counts, aes(x = counts, fill = samples)) +
  geom_histogram(bins = 100) +
  scale_x_continuous(breaks = c(0,2,4,6,8,10,12), limits = c(0,14))
ggsave("post.afs.pdf", plot = post.afs, width = 12, height = 8)



#######################################
##########     het/depth    ###########        
#######################################
het <- colSums(g=="0/1", na.rm = T) / colSums(!is.na(g))
het.depth <- data.frame(id=colnames(depth), depth=mean.depth, het=het)

post.het.depth <- ggplot(het.depth, aes(x=depth, y=het, color = id)) +
  geom_point()
ggsave("post.het.depth.pdf", plot = post.het.depth, width = 12, height = 8)



#######################################
###          allele balance        ####        
#######################################
extract.allele.balance <- function (vcfR) {
  ad.matrix <- vcfR::extract.gt(vcfR, element = "AD")
  if (length(grep("AD", vcfR@gt[, 1])) > 0.5) {
    ad.matrix <- vcfR::extract.gt(vcfR, element = "AD")
  }

  gt.matrix <- vcfR::extract.gt(vcfR, element = "GT")
  al1 <- structure(as.numeric(gsub(",.*", "", ad.matrix)), 
                   dim = dim(ad.matrix))
  al2 <- structure(as.numeric(gsub(".*,", "", ad.matrix)), 
                   dim = dim(ad.matrix))
  al.bal <- al2/(al1 + al2)
  return(al.bal)
}

AB <- data.frame(matrix(nrow = 0, ncol = 2))
for (i in colnames(extract.gt(vcf.filtered))) {
  AB <- rbind(AB, cbind(i, extract.allele.balance(vcf[,,i]), c(g[,i])))
  print(i)
  print(date())
}

colnames(AB) <- c("id", "AB", "gt")
AB$AB <- as.numeric(AB$AB)
AB <- AB[!is.na(AB$gt),]
post.AB <- ggplot(AB, aes(x = AB, color = id)) +
  facet_wrap(~gt) +
  geom_density() +
  ylim(0,10)
ggsave("post.AB.pdf", plot = post.AB, width = 12, height = 8)



#################################
############   pi    ############        
#################################

pis <- data.frame(matrix(ncol = 3, nrow = 0))
for (i in 10:50) {
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
post.pi.plot <- ggplot(pis, aes(x = depth, y = pi, color = id)) +
  geom_line()
ggsave("post.pi.plot.pdf", plot = post.pi.plot, width = 12, height = 8)
