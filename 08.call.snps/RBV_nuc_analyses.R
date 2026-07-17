setwd("~/Documents/Ben's Stuff/0 KU/Dissertation/009.RBV.WGS/08.call.snps/01.analyses")


library(readr)
library(adegenet)
library(adegraphics)
library(StAMPP)
library(ggplot2)
library(SNPfiltR)
library(triangulaR)
library(vcfR)
library(reshape2)

##########################################
###      Define helpful functions     ####
##########################################
vcfR2splitstree <- function(vcfR = NULL, popmap = NULL, file.prefix = NULL) {
  if (!identical(colnames(extract.gt(vcfR)), popmap$id)) {
    stop("order of inds in vcfR and popmap doesn't match")
  }
  # Make a genlight of subsamples
  gl <- vcfR2genlight(vcfR)
  # Assign populations
  pop(gl) <- popmap$pop
  # Make a distance matrix for splitstree
  dist <- stamppNeisD(gl, pop = FALSE)
  #export for splitstree
  stamppPhylip(distance.mat=dist, file=paste0(file.prefix, ".txt"))

  # name inds by pop
  dist.pop <- dist
  row.names(dist.pop) <- paste(popmap$pop, 1:nrow(popmap), sep = "_")
  stamppPhylip(distance.mat=dist.pop, file=paste0(file.prefix, ".pop.txt"))
  return(dist)
}



#  function for plotting structure results
betterStructurePlot <- function(
  q.mat, 
  ind.col = 1,
  pop.col = 3, 
  prob.col = 4, 
  sort.probs = TRUE,
  label.pops = FALSE,
  label.inds = TRUE,
  col = NULL, 
  horiz = TRUE, 
  type = NULL,
  legend.position = c("top", "left", "right", "bottom", "none"),
  plot = TRUE
) {
  
  legend.position <- match.arg(legend.position)
  
  # convert q.mat to sorted data.table
  prob.cols <- prob.col:ncol(q.mat)
  qm <- as.data.frame(q.mat)[, c(ind.col, pop.col, prob.cols), drop = FALSE]
  qm[, 2] <- factor(
    qm[, 2], 
    levels = sort(unique(qm[, 2]), decreasing = !horiz)
  )
  sort.cols <- c(2, if(sort.probs) 3:ncol(qm) else NULL)
  i <- do.call(
    order, 
    c(as.list(qm[, sort.cols, drop = FALSE]), decreasing = TRUE)
  )
  qm <- qm[i, ] # this reverses the order of pops for plotting
  qm$x <- 1:nrow(qm)
  
  # Get population frequencies, centers and dividing points
  pop.freq <- table(qm[, 2])
  levels(qm[, 2]) <- paste(
    levels(qm[, 2]), "\n(n = ", pop.freq, ")", sep = ""
  )
  pop.cntr <- tapply(qm$x, qm[, 2], mean)
  ind.cntr <- tapply(qm$x, qm[, 1], mean)
  pop.div <- rev(tapply(qm$x, qm[, 2], min))[-1] - 0.5
  
  # Create data.frame for plotting
  df <- melt(qm[, c("x", colnames(qm)[-ncol(qm)])], id.vars = c(1:3),
             variable.name = "Group", value.name = "probability")
  colnames(df)[1:3] <- c("x", "id", "population")
  df <- df[order(-as.numeric(df$Group), df$probability), ]
  
  type <- if(is.null(type)) {
    if(nrow(df) <= 100) "bar" else "area"
  } else {
    match.arg(type, c("bar", "area"))
  }
  
  # Plot stacked bar graphs
  g <- ggplot2::ggplot(df, ggplot2::aes_string("x", "probability")) +  
    switch(
      type,
      area = ggplot2::geom_area(
        ggplot2::aes_string(fill = "Group"), 
        stat = "identity"
      ),
      bar = ggplot2::geom_bar(
        ggplot2::aes_string(fill = "Group"), 
        stat = "identity"
      )
    ) +
    ggplot2::ylab("Pr(Group Membership)") +
    ggplot2::scale_y_continuous(expand = c(0, 0)) +
    ggplot2::theme(
      axis.ticks.x = ggplot2::element_blank(),
      legend.position = legend.position,
      legend.title = ggplot2::element_blank(),
      panel.grid = ggplot2::element_blank(),
      panel.background = ggplot2::element_blank()
    )
  if(label.pops) {
    g <- g + 
      ggplot2::geom_vline(xintercept = pop.div, size = 1.5) +
      ggplot2::scale_x_continuous(
        name = "", 
        breaks = pop.cntr, 
        labels = names(pop.cntr),
        expand = c(0, 0)
      )
  } else if (label.inds) {
    g <- g + 
      ggplot2::geom_vline(xintercept = pop.div, size = 1.5) +
      ggplot2::scale_x_continuous(
        name = "", 
        breaks = ind.cntr, 
        labels = names(ind.cntr),
        expand = c(0, 0)
      ) +
      ggplot2::theme(axis.text.x=element_text(angle=90,hjust=1,vjust=0.5))
  } else {
    g <- g + 
      ggplot2::xlab("") + 
      ggplot2::scale_x_continuous(expand = c(0, 0)) +
      ggplot2::theme(axis.text.x = ggplot2::element_blank())
  }
  if(horiz) g <- g + ggplot2::coord_flip()
  if(!is.null(col)) g <- g + ggplot2::scale_fill_manual(values = col)
  
  if(plot) print(g)
  invisible(g)
}

# vcf2str function (thanks Ben)
vcf2str <- function(vcfR = NULL, popmap = NULL, filename = NULL, missing.character = -9) {
  
  # extract genotype matrix
  m <- extract.gt(vcfR)
  m <- t(m)
  
  # recode missing data
  m[is.na(m)] <- (paste0(missing.character, "/", missing.character))
  
  # get unique values in matrix
  snp.values <- names(table(m))
  if (!all(snp.values %in% c("-9/-9", "0/0", "0/1", "1/1"))) {
    stop("unexpected values in genotype matrix")
  }
  
  # put popmap in same order as rownames in genotype matrix
  pm <- popmap[order(match(popmap$id, colnames(m))),]
  if (!identical(rownames(m), pm$id)) {
    stop("the individuals in the popmap and genotype matrix cannot be put in the same order... are some missing?")
  }
  
  # add id and pop columns to matrix
  id <- paste0(pm$id, "/", pm$id)
  pop <- paste0(pm$pop, "/", pm$pop)
  int.pop <- pop
  # convert pop to integer
  int <- 2
  for (p in unique(pop)) {
    int.pop[int.pop==p] <- paste0(int, "/", int)
    int <- int + 1
  }
  
  m <- cbind(id, int.pop, m)
  
  # make new matrix in structure format
  n <- matrix(nrow = 0, ncol = ncol(m))
  colnames(n) <- colnames(m)
  
  # populate new matrix
  for(i in 1:nrow(m)) {
    allele1 <- sapply(strsplit(m[i,], "/"), '[', 1)
    n <- rbind(n, allele1)
    
    allele2 <- sapply(strsplit(m[i,], "/"), '[', 2)
    n <- rbind(n, allele2)
  }
  
  # rename columns for structure
  colnames(n) <- c(" ", " ", colnames(n)[-1:-2])
  
  # write file
  write.table(n, file = filename, append = F, quote = F, sep = "\t", col.names = F, row.names = F)
}

#########################################
######        Setup data       ##########
#########################################


# read in vcf file
rbv_filtered <- read.vcfR("08.distance.10000.vcf.gz")

# read in full popmap
detailed.popmap <- read_delim("~/Documents/Ben's Stuff/0 KU/Dissertation/009.RBV.WGS/WGS_RBV_popmap_20251022.csv", 
                              delim = ",", escape_double = FALSE, 
                              trim_ws = TRUE)

# subset popmap for individuals in vcf (no Alticola)
popmap <- data.frame(detailed.popmap[detailed.popmap$id %in% colnames(extract.gt(rbv_filtered)),])

# make sure popmap is in same order as ids in the vcf
identical(colnames(extract.gt(rbv_filtered)), popmap$id)
popmap <- popmap[order(match(popmap$id, colnames(extract.gt(rbv_filtered)))),]
identical(colnames(extract.gt(rbv_filtered)), popmap$id)


######################
##   TRIANGLE PLOTS ##
######################
rbv_filtered

# find AIMs and calculate hybrid index and interclass heterozygosity
tri.popmap <- data.frame(id=popmap$id,
                         pop=popmap$class,
                         lat=popmap$lat)
rbv_diff <- alleleFreqDiff(vcfR = rbv_filtered, pm = tri.popmap, p1 = "BC_ref_gapperi", p2 = "BC_ref_rutilus", difference = 1)
hi_het <- hybridIndex(vcfR = rbv_diff, pm = tri.popmap, p1 = "BC_ref_gapperi", p2 = "BC_ref_rutilus")
triangulaR::triangle.plot(hi_het)

hi_het_discordant <- hi_het[hi_het$pop %in% c("BC_discordant", "BC_ref_gapperi", "BC_ref_rutilus", "SEAK_discordant"),]

triangle.plot <- ggplot() + 
  geom_segment(data = hi_het, aes(x = 0.5, xend = 1, y = 1, yend = 0), color = "black") + 
  geom_segment(data = hi_het, aes(x = 0, xend = 0.5, y = 0, yend = 1), color = "black") + 
  geom_segment(data = hi_het, aes(x = 0, xend = 1, y = 0, yend = 0), color = "black") + 
  stat_function(fun = function(hi) 2 * hi * (1 - hi), xlim = c(0, 1), color = "black", linetype = "dashed") + 
  
  # draw all OTHER groups first
  geom_jitter(
    data = subset(hi_het_discordant, pop != "BC_ref_rutilus"),
    aes(x = hybrid.index, y = heterozygosity, color = pop),
    cex = 3.5, alpha = 1, width = 0, height = 0) +
  
  # draw BC_ref_rutilus LAST (on top)
  geom_jitter(
    data = subset(hi_het_discordant, pop == "BC_ref_rutilus"),
    aes(x = hybrid.index, y = heterozygosity, color = pop),
    cex = 3.5, alpha = 1, width = 0, height = 0) +
  
  scale_color_manual(values = c("#78923D", "#5AB4AB", "#D8B365", "#4A3C1D")) +
  xlab("Hybrid Index") + 
  ylab("Interclass Heterozygosity") + 
  ylim(c(-0.05, 1.05)) + 
  xlim(c(-0.05, 1.05)) +
  theme_bw() +
  theme(legend.position = "none")
triangle.plot
ggsave("triangle.plot.pdf", triangle.plot, width = 4, height = 3)

# hybrid index by pop
identical(hi_het$id, tri.popmap$id)
geo.pop <- cbind(hi_het, tri.popmap$lat)
colnames(geo.pop) <- c(colnames(hi_het), "lat")
geo.pop <- geo.pop[geo.pop$pop %in% c("BC_rutilus", "BC_discordant"),]
geo.pop[geo.pop$lat < 57.4, "pop"] <- "BC_discordant_south"
ggplot(geo.pop, aes(x = hybrid.index, y = lat, color = pop)) + 
  geom_point() +
  guides(shape = guide_legend(override.aes = list(size = 5), order = 2, label.theme = element_text(face = "italic"))) + 
  xlab(paste("hybrid index")) + 
  ylab(paste("latitude")) + 
  labs(title = "") + 
  #scale_color_manual("pop", values = colors) + 
  theme_bw()
mean(geo.pop[geo.pop$pop == "BC_discordant",]$hybrid.index)
mean(geo.pop[geo.pop$pop == "BC_discordant_south",]$hybrid.index)
mean(geo.pop[geo.pop$pop == "BC_rutilus",]$hybrid.index)

ggplot(hi_het, aes(x = hybrid.index, y = heterozygosity, color = as.factor(pop))) + 
  geom_segment(aes(x = 0.5, xend = 1, y = 1, yend = 0), color = "black") + 
  geom_segment(aes(x = 0, xend = 0.5, y = 0, yend = 1), color = "black") + 
  geom_segment(aes(x = 0, xend = 1, y = 0, yend = 0), color = "black") + 
  stat_function(fun = function(hi) 2 * hi * (1 - hi), xlim = c(0, 1), color = "black", linetype = "dashed") + 
  geom_jitter(cex = 2, alpha = 1, width = 0, height = 0) + 
  guides(shape = guide_legend(override.aes = list(size = 5), order = 2, label.theme = element_text(face = "italic"))) + 
  xlab(paste("Hybrid Index")) + 
  ylab(paste("Interclass Heterozygosity")) + 
  labs(title = "") + 
  #scale_color_manual("pop", values = colors) + 
  coord_cartesian(ylim = c(0, 0.05), xlim = c(0, 0.025)) +
  theme_bw()

ggplot(hi_het, aes(x = hybrid.index, y = heterozygosity, color = as.factor(pop))) + 
  geom_segment(aes(x = 0.5, xend = 1, y = 1, yend = 0), color = "black") + 
  geom_segment(aes(x = 0, xend = 0.5, y = 0, yend = 1), color = "black") + 
  geom_segment(aes(x = 0, xend = 1, y = 0, yend = 0), color = "black") + 
  stat_function(fun = function(hi) 2 * hi * (1 - hi), xlim = c(0, 1), color = "black", linetype = "dashed") + 
  geom_jitter(cex = 2, alpha = 1, width = 0, height = 0) + 
  guides(shape = guide_legend(override.aes = list(size = 5), order = 2, label.theme = element_text(face = "italic"))) + 
  xlab(paste("Hybrid Index")) + 
  ylab(paste("Interclass Heterozygosity")) + 
  labs(title = "") + 
  #scale_color_manual("pop", values = colors) + 
  coord_cartesian(ylim = c(0, 0.05), xlim = c(0.975, 1)) +
  theme_bw()
 
triangulaR::triangle.plot(hi_het)

triangulaR::missing.plot(hi_het)
freq_diff <- specFreqDiff(vcfR = rbv_filtered, pm = tri.popmap, p1 = "BC_ref_gapperi", p2 = "BC_ref_rutilus")
hist(freq_diff$diff)

mean(hi_het[hi_het$pop=="BC_discordant",]$hybrid.index)
mean(hi_het[hi_het$pop=="SEAK_discordant",]$hybrid.index)

spec_freq_diff <- ggplot(data = freq_diff,  aes(x=diff)) +
  geom_histogram(color="#FFFFFF", alpha=1, position = 'identity', bins = 20) +
  xlab(paste("Observed Allele Frequency Difference")) +
  ylab(paste("Count")) +
  #ylim(0,8000) +
  theme_classic() +
  theme(legend.position = "none", axis.title.y = element_text(size = 14), axis.title.x = element_text(size = 14)) +
  theme(axis.title.y = element_text(size = 14),
        axis.title.x = element_text(size = 14),
        axis.text = element_text(size = 12),
        strip.text = element_text(size = 12),
        legend.position = "none") +  theme(panel.border = element_rect(color = "black", fill = NA, linewidth = 1))
spec_freq_diff

ggsave("spec_freq_diff.pdf", plot = spec_freq_diff, path = "./", width = 6, height = 4)

vcfR2splitstree(vcfR = rbv_diff, popmap = tri.popmap, file.prefix = "08.distance.10000.diff")




tri.q <- hi_het[,1:3]
colnames(tri.q) <- c("id", "pop", "Q1")
tri.q$Q2 <- 1-tri.q$Q1



tri.bars <- betterStructurePlot(
    q.mat = tri.q, 
    ind.col = 1,
    pop.col = 2, 
    prob.col = 3, 
    sort.probs = TRUE,
    label.pops = TRUE,
    label.inds = F,
    col = c("#D8B365", "#5AB4AC"), 
    horiz = TRUE, 
    type = "bar",
    legend.position = "none",
    plot = TRUE
)
tri.bars
ggsave("tri.bars.R.pdf", tri.bars, width = 4, height = 8)



##############################
######   Depth 
##############################
depth <- extract.gt(rbv_filtered, element = "DP", as.numeric=TRUE)
g <- extract.gt(rbv_filtered)
depth[is.na(g)] <- NA
identical(colnames(depth), popmap$id)
popmap$depth <- colMeans(depth, na.rm = T)
summary(depth)
popmap$missing <- colSums(is.na(g))/nrow(g)



