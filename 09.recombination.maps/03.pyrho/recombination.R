setwd("~/Documents/Ben's Stuff/0 KU/Dissertation/009.RBV.WGS/09.recombination.maps/03.pyrho")


library(dplyr)
library(tidyr)
library(ggplot2)

set.seed(758348)
sort(sample(c(
  "MSB198512","MSB199067","MSB199079","MSB199080","MSB199082",
  "MSB199092","MSB199096","MSB199104","MSB199112","MSB199119",
  "MSB199121","MSB199122","MSB199126","MSB199127","MSB199129",
  "MSB199132","MSB199133","MSB199134","MSB199135","MSB199136",
  "MSB199138"
), 13, replace = F))



CLRU <- read.table("../03.pyrho/CLRU.genome.1Mb.100kb.rmap", header = T, sep = "\t")
CLRU$rate <- as.numeric(CLRU$rate)

CLRU.rmap <- ggplot(CLRU[CLRU$chrom!="CM105791.1",], aes(x=start, y=rate)) +
  facet_wrap(~ chrom, scales = "free_x", ncol = 7) +
  geom_line(cex = 1, alpha=1) +
  xlab("position") +
  ylab("recombination rate") +
  labs(title = ) +
  ylim(0,5e-8) +
  guides(color = "none") +
  theme(legend.position = "none") +
  theme_classic()
CLRU.rmap

CLRU.13 <- read.table("../03.pyrho/CLRU.genome.1Mb.100kb.13.rmap", header = T, sep = "\t")
CLRU.13$rate <- as.numeric(CLRU.13$rate)

CLRU.13.rmap <- ggplot(CLRU.13, aes(x=start, y=rate)) +
  facet_wrap(~ chrom, scales = "free_x") +
  geom_line(cex = 1, alpha=1) +
  xlab("position") +
  ylab("recombination rate") +
  labs(title = ) +
  ylim(0,5e-8) +
  guides(color = "none") +
  theme(legend.position = "none") +
  theme_classic()
CLRU.13.rmap

CLGA <- read.table("../03.pyrho/CLGA.genome.1Mb.100kb.rmap", header = T, sep = "\t")
CLGA$rate <- as.numeric(CLGA$rate)

CLGA.rmap <- ggplot(CLGA[CLGA$chrom!="CM105791.1",], aes(x=start, y=rate)) +
  facet_wrap(~ chrom, scales = "free_x", ncol = 7) +
  geom_line(cex = 1, alpha=1) +
  xlab("position") +
  ylab("recombination rate") +
  labs(title = ) +
  ylim(0,5e-8) +
  guides(color = "none") +
  theme(legend.position = "none") +
  theme_classic()
CLGA.rmap

ggsave("CLRU.genome.png", CLRU.rmap, width = 16, height = 12)
ggsave("CLRU.genome.13.png", CLRU.13.rmap, width = 16, height = 12)

ggsave("CLGA.genome.png", CLGA.rmap, width = 16, height = 12)

all(CLRU$chrom == CLGA$chrom)
all(CLRU$start == CLGA$start)
all(CLRU$end == CLGA$end)


both <- CLRU[,1:3]
both$CLRU.rate <- CLRU$rate
both$CLGA.rate <- CLGA$rate
both$CLRU.13.rate <- CLRU.13$rate


ggplot(both, aes(x=CLRU.rate, y=CLGA.rate)) +
  geom_point(cex = 1, alpha = 1) +
  geom_abline(slope = 1, color = "blue", cex = 2) +
  facet_wrap( ~ chrom) +
  xlab("CLRU") +
  ylab("CLGA") +
  labs(title = ) +
  scale_y_log10(limits = c(1e-10, 2e-8)) + 
  scale_x_log10(limits = c(1e-10, 2e-8)) + 
  guides(color = "none") +
  theme(legend.position = "none") +
  theme_classic()


ggplot(both, aes(x=CLRU.rate, y=CLRU.13.rate)) +
  geom_point(cex = 1, alpha = 1) +
  geom_abline(slope = 1, color = "blue", cex = 2) +
  facet_wrap( ~ chrom) +
  xlab("CLRU") +
  ylab("CLRU.13") +
  labs(title = ) +
  scale_y_log10(limits = c(1e-10, 2e-8)) + 
  scale_x_log10(limits = c(1e-10, 2e-8)) + 
  guides(color = "none") +
  theme(legend.position = "none") +
  theme_classic()

ggplot(both, aes(x=CLRU.rate, y=CLRU.13.rate)) +
  geom_point(cex = 1, alpha = 0.1) +
  geom_smooth(method = lm) +
  geom_abline(slope = 1, color = "red", cex = 1) +
  xlab("CLRU") +
  ylab("CLRU.13") +
  labs(title = ) +
  scale_y_log10(limits = c(1e-10, 2e-8)) + 
  scale_x_log10(limits = c(1e-10, 2e-8)) + 
  guides(color = "none") +
  theme(legend.position = "none") +
  theme_classic()

cor.test(both$CLRU.rate, both$CLGA.rate, method='spearman')
cor.test(both[both$chrom != "CM105791.1",]$CLRU.rate, both[both$chrom != "CM105791.1",]$CLGA.rate, method='spearman')

cor.test(both[both$chrom != "CM105791.1",]$CLRU.rate, both[both$chrom != "CM105791.1",]$CLRU.13.rate, method='spearman')
summary(lm(both[both$chrom != "CM105791.1",]$CLRU.rate ~ both[both$chrom != "CM105791.1",]$CLRU.13.rate))

cor.test(both$CLGA.rate, both$CLRU.13.rate, method='spearman')


CLRU$species <- "CLRU"
CLRU.13$species <- "CLRU.13"
CLGA$species <- "CLGA"
both_long <- rbind(CLRU, CLGA)

ggplot(both_long[both_long$chrom!="CM105791.1",], aes(x=start, y=rate, color = species)) +
  facet_wrap(~ chrom, scales = "free_x", ncol = 7) +
  geom_line(cex = 0.8, alpha = 0.5) +
  xlab("position") +
  ylab("recombination rate") +
  labs(title = ) +
  ylim(0,3e-8) +
  #guides(color = "none") +
  #theme(legend.position = "none") +
  theme_classic()

CLRU.21.13 <- rbind(CLRU, CLRU.13)
ggplot(CLRU.21.13, aes(x=start, y=rate, color = species)) +
  facet_wrap(~ chrom, scales = "free_x") +
  geom_line(cex = 0.8, alpha = 0.5) +
  xlab("position") +
  ylab("recombination rate") +
  labs(title = ) +
  ylim(0,3e-8) +
  #guides(color = "none") +
  #theme(legend.position = "none") +
  theme_classic()


CLGA.CLRU.13 <- rbind(CLGA, CLRU.13)
ggplot(CLGA.CLRU.13, aes(x=start, y=rate, color = species)) +
  facet_wrap(~ chrom, scales = "free_x") +
  geom_line(cex = 0.8, alpha = 0.5) +
  xlab("position") +
  ylab("recombination rate") +
  labs(title = ) +
  ylim(0,3e-8) +
  #guides(color = "none") +
  #theme(legend.position = "none") +
  theme_classic()



chr27.both.species.recombination <- ggplot(both_long[both_long$chrom=="CM105790.1",], aes(x=start, y=rate, color = species)) +
  facet_wrap(~ chrom, scales = "free_x") +
  geom_line(cex = 1.5, alpha = 1) +
  xlab("Position (bp)") +
  ylab("Recombination Rate") +
  labs(title = ) +
  #ylim(0,1.5e-8) +
  #guides(color = "none") +
  #theme(legend.position = "none") +
  scale_color_manual(values = c("#59b4ac", "#d8b365")) +
  theme_bw()
chr27.both.species.recombination

ggsave("chr27.both.species.recombination.pdf", chr27.both.species.recombination, width = 8, height = 3)




