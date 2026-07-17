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
mean.depth <- colMeans(depth, na.rm = T)
print(sort(mean.depth))


# Collapse columns for plotting
depth2 <- data.frame(
  id = rep(names(depth), each = nrow(depth)),
  depth = as.vector(as.matrix(depth))
)

# Remove NA values
depth2 <- depth2[!is.na(depth2$depth), ]
depth2 <- depth2[is.finite(depth2$depth), ]


# Quantiles
depth.quantiles <- apply(depth, 2, quantile, probs = c(0.05, 0.1, 0.15, 0.2, 0.25, 0.3, 0.35, 0.4, 0.45, 0.5, 0.55, 0.6, 0.65, 0.7, 0.75, 0.8, 0.85, 0.9, 0.95), na.rm=T)
write.table(depth.quantiles, file = "depth.quantiles.txt", col.names = T, row.names = T, sep = "\t", quote = F)


# Histograms
depth.histogram.all <- ggplot(depth2, aes(x = depth, fill = id)) +
  geom_histogram(bins = 100) +
  facet_wrap(~ id)
ggsave("depth.histogram.all.pdf", plot = depth.histogram.all, width = 16, height = 8)

depth.histogram.100 <- ggplot(depth2, aes(x = depth, fill = id)) +
  geom_histogram(bins = 100) +
  facet_wrap(~ id) +
  scale_x_continuous(limits = c(0,50))
ggsave("depth.histogram.50.pdf", plot = depth.histogram.100, width = 16, height = 8)

# Points
#ggplot(depth2, aes(x = id, y = depth, color = id)) +
#  geom_jitter() +
#  scale_y_continuous(limits = c(0,100)) +
#  theme(axis.text.x = element_text(angle = 90, vjust = 0.5, hjust = 1))

# Violins
depth.violin.all <- ggplot(depth2, aes(x = id, y = depth, fill = id)) +
  geom_violin() +
  theme(axis.text.x = element_text(angle = 90, vjust = 0.5, hjust = 1))
ggsave("depth.violin.all.pdf", plot = depth.violin.all, width = 12, height = 8)

depth.violin.100 <- ggplot(depth2, aes(x = id, y = depth, fill = id)) +
  geom_violin() +
  scale_y_continuous(limits = c(0,50)) +
  theme(axis.text.x = element_text(angle = 90, vjust = 0.5, hjust = 1))
ggsave("depth.violin.50.pdf", plot = depth.violin.100, width = 12, height = 8)




