setwd("~/Documents/Ben's Stuff/0 KU/Dissertation/009.RBV.WGS/00.figures")


library(dplyr)
library(tidyr)
library(ggplot2)
library(gridExtra)
library(grid)
library(stringr)

#######################################
####      Ancestry_hmm timing      ####
#######################################

# BC 2 pulse
BC.2pulse <- read.table("../16.ancestry_hmm/BC.2pulse.txt", col.names = c("type", "time", "proportion"))
BC.2pulse$bootstap <- sort(rep(1:50, 6))

BC.2pulse <- BC.2pulse[seq(1, 300, 2),]
BC.2pulse <- BC.2pulse[BC.2pulse$type == 0,]

BC.2pulse$timeperiod <- NA
BC.2pulse[BC.2pulse$time > 0 & BC.2pulse$time < 500, "timeperiod"] <- "pulse2"
BC.2pulse[BC.2pulse$time > 500 & BC.2pulse$time < 2000, "timeperiod"] <- "single"
BC.2pulse[BC.2pulse$time > 2000 & BC.2pulse$time < 5000, "timeperiod"] <- "pulse1"
BC.2pulse[BC.2pulse$time > 5000, "timeperiod"] <- "ignore"
table(BC.2pulse$timeperiod)

BC.2pulse$num.pulses <- NA
BC.2pulse[BC.2pulse$time > 0 & BC.2pulse$time < 500, "num.pulses"] <- "2"
BC.2pulse[BC.2pulse$time > 500 & BC.2pulse$time < 2000, "num.pulses"] <- "1"
BC.2pulse[BC.2pulse$time > 2000 & BC.2pulse$time < 5000, "num.pulses"] <- "2"
BC.2pulse[BC.2pulse$time > 5000, "num.pulses"] <- "1"

BC.2pulse$pop <- "BC"

# BC 1 pulse
BC.1pulse <- read.table("../16.ancestry_hmm/BC.1pulse.txt", col.names = c("type", "time", "proportion"))
BC.1pulse$bootstap <- sort(rep(1:1000, 4))

BC.1pulse <- BC.1pulse[seq(1, 4000, 2),]
BC.1pulse <- BC.1pulse[BC.1pulse$type == 0,]
BC.1pulse$timeperiod <- "only_one"
BC.1pulse$num.pulses <- 1
BC.1pulse$pop <- "BC"

# SEAK 2 pulse
SEAK.2pulse <- read.table("../16.ancestry_hmm/SEAK.2pulse.txt", col.names = c("type", "time", "proportion"))
SEAK.2pulse$bootstap <- sort(rep(1:50, 6))

SEAK.2pulse <- SEAK.2pulse[seq(1, 300, 2),]
SEAK.2pulse <- SEAK.2pulse[SEAK.2pulse$type == 0,]

SEAK.2pulse$timeperiod <- NA
SEAK.2pulse[SEAK.2pulse$time > 0 & SEAK.2pulse$time < 5000, "timeperiod"] <- "single"
SEAK.2pulse[SEAK.2pulse$time > 5000, "timeperiod"] <- "ignore"
table(SEAK.2pulse$timeperiod)

SEAK.2pulse$num.pulses <- NA
SEAK.2pulse[SEAK.2pulse$time > 0 & SEAK.2pulse$time < 5000, "num.pulses"] <- "1"
SEAK.2pulse[SEAK.2pulse$time > 5000, "num.pulses"] <- "1"

SEAK.2pulse$pop <- "SEAK"

# SEAK 1 pulse
SEAK.1pulse <- read.table("../16.ancestry_hmm/SEAK.1pulse.txt", col.names = c("type", "time", "proportion"))
SEAK.1pulse$bootstap <- sort(rep(1:1000, 4))

SEAK.1pulse <- SEAK.1pulse[seq(1, 4000, 2),]
SEAK.1pulse <- SEAK.1pulse[SEAK.1pulse$type == 0,]
SEAK.1pulse$timeperiod <- "only_one"
SEAK.1pulse$num.pulses <- 1
SEAK.1pulse$pop <- "SEAK"

# Combine
all.pulses <- rbind(BC.2pulse, BC.1pulse, SEAK.2pulse, SEAK.1pulse)

length(all.pulses[all.pulses$pop == "BC" & all.pulses$timeperiod == "pulse1",]$time)
mean(all.pulses[all.pulses$pop == "BC" & all.pulses$timeperiod == "only_one",]$time)
mean(all.pulses[all.pulses$pop == "BC" & all.pulses$timeperiod == "pulse1",]$time)
mean(all.pulses[all.pulses$pop == "BC" & all.pulses$timeperiod == "pulse2",]$time)
mean(all.pulses[all.pulses$pop == "BC" & all.pulses$timeperiod == "single",]$time)
mean(all.pulses[all.pulses$pop == "BC" & all.pulses$timeperiod == "ignore",]$time)

mean(all.pulses[all.pulses$pop == "SEAK" & all.pulses$timeperiod == "only_one",]$time)
mean(all.pulses[all.pulses$pop == "SEAK" & all.pulses$timeperiod == "single",]$time)
mean(all.pulses[all.pulses$pop == "SEAK" & all.pulses$timeperiod == "ignore",]$time)

p <- ggplot(all.pulses[all.pulses$timeperiod != "ignore",], aes(x=time, y=factor(timeperiod, levels= c("only_one", "single", "pulse1", "pulse2")), color=num.pulses)) +
  geom_jitter(cex = 1.5, alpha = 0.5) +
  geom_boxplot(cex = 0.5, fill = NA, color = "black", outliers = F) +
  facet_wrap( ~ pop, ncol = 1, scales = "free_y") +
  xlab("Generations ago") +
  ylab("") +
  scale_x_log10(breaks = c(140, 200, 400, 800, 1600, 3200), 
                limits = c(140, 4000),
                expand = c(0,0),
                sec.axis = sec_axis(~ . / 1.5,
                                    name = "Years ago",
                                    breaks = c(120, 240, 480, 960, 1880),
                                    labels = scales::comma)) +
  scale_y_discrete() +
  #141.4214
  labs(title = ) +
  guides(color = "none") +
  theme(legend.position = "none") +
  #scale_color_manual(values = c("#59b4ac", "#d8b365")) +
  theme_bw()

p
g <- ggplotGrob(p)

# manually set their heights
g$heights[c(10)] <- unit(c(2), units = "null") # example: top panel 3× taller than bottom

grid.newpage()
grid.draw(g)

ggsave("contact_timing.png", g, width = 12, height = 3)



powerpoint.fig <- all.pulses
powerpoint.fig <- powerpoint.fig[(powerpoint.fig$num.pulses == 2 & powerpoint.fig$pop == "BC") | (powerpoint.fig$timeperiod == "only_one" & powerpoint.fig$pop == "SEAK"),]

pp <- ggplot(powerpoint.fig[powerpoint.fig$timeperiod != "ignore",], aes(x=time, y=factor(timeperiod, levels= c("only_one", "single", "pulse1", "pulse2")), color=num.pulses)) +
  geom_jitter(cex = 1.5, alpha = 0.7) +
  geom_boxplot(cex = 0.5, fill = NA, color = "black", outliers = F) +
  facet_wrap( ~ pop, ncol = 1, scales = "free_y") +
  xlab("Generations ago") +
  ylab("") +
  scale_x_log10(breaks = c(140, 200, 400, 800, 1600, 3200), 
                limits = c(140, 4000),
                expand = c(0,0) #,
                #sec.axis = sec_axis(~ . / 1.5,
                #                    name = "Years ago",
                #                    breaks = c(120, 240, 480, 960, 1880),
                #                    labels = scales::comma)
                ) +
  scale_y_discrete() +
  #141.4214
  labs(title = ) +
  guides(color = "none") +
  scale_color_manual(values = c("#4A3C1D", "#78923D")) +
  theme_bw()+
  theme(legend.position = "none",
        strip.text = element_text(size = 12)) 

pp
gg <- ggplotGrob(pp)

# manually set their heights
gg$heights[c(10)] <- unit(c(2), units = "null") # example: top panel 3× taller than bottom

grid.newpage()
grid.draw(gg)

ggsave("contact_timing_pp.pdf", gg, width = 7, height = 3)
ggsave("contact_timing_pp.png", gg, width = 7, height = 3)


pp <- ggplot(powerpoint.fig[powerpoint.fig$timeperiod != "ignore",], aes(y=time, x=factor(timeperiod, levels= c("only_one", "single", "pulse1", "pulse2")), color=num.pulses)) +
  geom_jitter(shape = 21, cex = 2, alpha = 0.5, fill = "gray60", stroke = 1, color = "gray40") +
  geom_boxplot(cex = 1.1, fill = NA, outliers = F) +
  facet_wrap( ~ pop, ncol = 2, scales = "free_x") +
  ylab("Generations ago") +
  xlab("") +
  scale_y_continuous(breaks = c(150, 165, 180, 195), 
                limits = c(140, 4000),
                expand = c(0,0),
                sec.axis = sec_axis(~ . / 1.5,
                                    name = "Years ago",
                                    breaks = c(100, 110, 120, 130),
                                    labels = scales::comma)) +
  scale_x_discrete() +
  #141.4214
  labs(title = ) +
  guides(color = "none") +
  theme(legend.position = "none") +
  scale_color_manual(values = c("#4A3C1D", "#78923D")) +
  theme_bw() +
  coord_cartesian(ylim = c(150,200)) +
  theme(legend.position = "none",
        strip.background = element_blank(), # Removes the background box
        strip.text = element_blank(),        # Removes the text labels
        axis.text.x = element_text(size = 13),
        axis.text.y = element_text(size = 13)
  )
set.seed(4359)
pp
set.seed(4359)
gg <- ggplotGrob(pp)

# manually set their widths
gg$widths[c(11)] <- unit(c(0.5), units = "null") # example: top panel 3× taller than bottom

grid.newpage()
grid.draw(gg)

ggsave("contact_timing_pp_bottom.pdf", gg, width = 3.5, height = 2)

pp <- ggplot(powerpoint.fig[powerpoint.fig$timeperiod != "ignore",], aes(y=time, x=factor(timeperiod, levels= c("only_one", "single", "pulse1", "pulse2")), color=num.pulses)) +
  geom_jitter(shape = 21, cex = 2, alpha = 0.5, fill = "gray60", stroke = 1, color = "gray40") +
  geom_boxplot(cex = 1.1, fill = NA, outliers = F) +
  facet_wrap( ~ pop, ncol = 2, scales = "free_x") +
  ylab("Generations ago") +
  xlab("") +
  scale_y_continuous(breaks = c(2400, 3000, 3600), 
                limits = c(140, 4000),
                expand = c(0,0),
                sec.axis = sec_axis(~ . / 1.5,
                                    name = "Years ago",
                                    breaks = c(1600, 2000, 2400),
                                    labels = scales::comma)) +
  scale_x_discrete() +
  #141.4214
  labs(title = ) +
  guides(color = "none") +
  theme(legend.position = "none") +
  scale_color_manual(values = c("#4A3C1D", "#78923D")) +
  theme_bw() +
  coord_cartesian(ylim = c(2300,3900)) +
  theme(legend.position = "none",
        strip.text = element_text(size = 13),
        axis.text.x = element_text(size = 13),
        axis.text.y = element_text(size = 13)
  )

set.seed(234512)
pp
set.seed(234512)
gg <- ggplotGrob(pp)

# manually set their widths
gg$widths[c(11)] <- unit(c(0.5), units = "null") # example: top panel 3× taller than bottom

grid.newpage()
set.seed(234512)
grid.draw(gg)
set.seed(234512)
ggsave("contact_timing_pp_top.pdf", gg, width = 3.71875, height = 3.5)











ggplot(BC.2pulse[BC.2pulse$timeperiod != "ignore",], aes(x=time, fill=num.pulses)) +
  geom_histogram(bins = 200) +
  facet_wrap( ~ num.pulses) +
  xlab("") +
  ylab("") +
  labs(title = ) +
  scale_x_log10(breaks = c(100, 200, 400, 800, 1600, 3200), limits = c(100, 4000)) +
  guides(color = "none") +
  theme(legend.position = "none") +
  #scale_color_manual(values = c("#59b4ac", "#d8b365")) +
  theme_bw()
#











##########################################
###   100kb windows, sliding by 10kb   ###
##########################################
pi.100kb.10kb <- read.table("../14.pixy/pixy.100kb.10kb_pi.txt.gz", header = T)
dxy.100kb.10kb <- read.table("../14.pixy/pixy.100kb.10kb_dxy.txt.gz", header = T)
fst.100kb.10kb <- read.table("../14.pixy/pixy.100kb.10kb_fst.txt.gz", header = T)
td.100kb.10kb <- read.table("../14.pixy/pixy.100kb.10kb_tajima_d.txt.gz", header = T)
wt.100kb.10kb <- read.table("../14.pixy/pixy.100kb.10kb_watterson_theta.txt.gz", header = T)

pi.100kb.10kb$window_pos_mid <- (pi.100kb.10kb$window_pos_1 + pi.100kb.10kb$window_pos_2) / 2
dxy.100kb.10kb$window_pos_mid <- (dxy.100kb.10kb$window_pos_1 + dxy.100kb.10kb$window_pos_2) / 2
fst.100kb.10kb$window_pos_mid <- (fst.100kb.10kb$window_pos_1 + fst.100kb.10kb$window_pos_2) / 2
td.100kb.10kb$window_pos_mid <- (td.100kb.10kb$window_pos_1 + td.100kb.10kb$window_pos_2) / 2
wt.100kb.10kb$window_pos_mid <- (wt.100kb.10kb$window_pos_1 + wt.100kb.10kb$window_pos_2) / 2

pi.100kb.10kb <- pi.100kb.10kb[pi.100kb.10kb$window_pos_mid %% 10000 == 0,]
dxy.100kb.10kb <- dxy.100kb.10kb[dxy.100kb.10kb$window_pos_mid %% 10000 == 0,]
fst.100kb.10kb <- fst.100kb.10kb[fst.100kb.10kb$window_pos_mid %% 10000 == 0,]
td.100kb.10kb <- td.100kb.10kb[td.100kb.10kb$window_pos_mid %% 10000 == 0,]
wt.100kb.10kb <- wt.100kb.10kb[wt.100kb.10kb$window_pos_mid %% 10000 == 0,]

fst.100kb.10kb.refs <- fst.100kb.10kb[(fst.100kb.10kb$pop1=="BC_ref_rutilus" | fst.100kb.10kb$pop1=="BC_ref_gapperi") & (fst.100kb.10kb$pop2=="BC_ref_rutilus" | fst.100kb.10kb$pop2=="BC_ref_gapperi"),]
dxy.100kb.10kb.refs <- dxy.100kb.10kb[(dxy.100kb.10kb$pop1=="BC_ref_rutilus" | dxy.100kb.10kb$pop1=="BC_ref_gapperi") & (dxy.100kb.10kb$pop2=="BC_ref_rutilus" | dxy.100kb.10kb$pop2=="BC_ref_gapperi"),]



#########################################
###   1Mb windows, sliding by 100kb   ###
#########################################
pi.1Mb.100kb <- read.table("../14.pixy/1Mb.100kb/pixy.1Mb.100kb_pi.txt", header = T)
dxy.1Mb.100kb <- read.table("../14.pixy/1Mb.100kb/pixy.1Mb.100kb_dxy.txt", header = T)
fst.1Mb.100kb <- read.table("../14.pixy/1Mb.100kb/pixy.1Mb.100kb_fst.txt", header = T)
td.1Mb.100kb <- read.table("../14.pixy/1Mb.100kb/pixy.1Mb.100kb_tajima_d.txt", header = T)
wt.1Mb.100kb <- read.table("../14.pixy/1Mb.100kb/pixy.1Mb.100kb_watterson_theta.txt", header = T)

pi.1Mb.100kb$window_pos_mid <- (pi.1Mb.100kb$window_pos_1 + pi.1Mb.100kb$window_pos_2) / 2
dxy.1Mb.100kb$window_pos_mid <- (dxy.1Mb.100kb$window_pos_1 + dxy.1Mb.100kb$window_pos_2) / 2
fst.1Mb.100kb$window_pos_mid <- (fst.1Mb.100kb$window_pos_1 + fst.1Mb.100kb$window_pos_2) / 2
td.1Mb.100kb$window_pos_mid <- (td.1Mb.100kb$window_pos_1 + td.1Mb.100kb$window_pos_2) / 2
wt.1Mb.100kb$window_pos_mid <- (wt.1Mb.100kb$window_pos_1 + wt.1Mb.100kb$window_pos_2) / 2

pi.1Mb.100kb <- pi.1Mb.100kb[pi.1Mb.100kb$window_pos_mid %% 100000 == 0,]
dxy.1Mb.100kb <- dxy.1Mb.100kb[dxy.1Mb.100kb$window_pos_mid %% 100000 == 0,]
fst.1Mb.100kb <- fst.1Mb.100kb[fst.1Mb.100kb$window_pos_mid %% 100000 == 0,]
td.1Mb.100kb <- td.1Mb.100kb[td.1Mb.100kb$window_pos_mid %% 100000 == 0,]
wt.1Mb.100kb <- wt.1Mb.100kb[wt.1Mb.100kb$window_pos_mid %% 100000 == 0,]

fst.1Mb.100kb.refs <- fst.1Mb.100kb[(fst.1Mb.100kb$pop1=="BC_ref_rutilus" | fst.1Mb.100kb$pop1=="BC_ref_gapperi") & (fst.1Mb.100kb$pop2=="BC_ref_rutilus" | fst.1Mb.100kb$pop2=="BC_ref_gapperi"),]
dxy.1Mb.100kb.refs <- dxy.1Mb.100kb[(dxy.1Mb.100kb$pop1=="BC_ref_rutilus" | dxy.1Mb.100kb$pop1=="BC_ref_gapperi") & (dxy.1Mb.100kb$pop2=="BC_ref_rutilus" | dxy.1Mb.100kb$pop2=="BC_ref_gapperi"),]

mean(fst.1Mb.100kb.refs$avg_wc_fst)
mean(dxy.1Mb.100kb.refs$avg_dxy)
mean(pi.1Mb.100kb[pi.1Mb.100kb$pop == "BC_ref_gapperi",]$avg_pi)
mean(pi.1Mb.100kb[pi.1Mb.100kb$pop == "BC_ref_rutilus",]$avg_pi)

pi <- ggplot(pi.1Mb.100kb[pi.1Mb.100kb$chromosome == "CM105789.1" & pi.1Mb.100kb$pop %in% c("BC_ref_rutilus", "BC_ref_gapperi"),], aes(x=window_pos_mid, y=avg_pi, color = pop)) +
  facet_wrap( ~ chromosome, scales = "free_x", ncol = 7) +
  geom_line(cex = 0.8, alpha = 0.5) +
  scale_x_continuous(
    breaks = c(0,1e7,2e7,3e7,4e7,46425774),
    expand = c(0.01,0)
  ) +
  #xlab("position") +
  ylab("pi") +
  labs(title = ) +
  #ylim(0,3e-8) +
  scale_color_manual(values = c("#59b4ac", "#d8b365")) +
  guides(color = "none") +
  theme_bw() +
  theme(legend.position = "none",
        axis.title.x = element_blank())
pi

fst <- ggplot(fst.1Mb.100kb.refs[fst.1Mb.100kb.refs$chromosome == "CM105789.1",], aes(x=window_pos_mid, y=avg_wc_fst)) +
  geom_line(cex = 0.8, alpha = 0.5) +
  scale_x_continuous(
    breaks = c(0,1e7,2e7,3e7,4e7,46425774),
    expand = c(0.01,0)
  ) +
  #xlab("position") +
  ylab("fst") +
  labs(title = ) +
  guides(color = "none") +
  theme_bw() +
  theme(legend.position = "none",
        axis.title.x = element_blank())
fst

dxy <- ggplot(dxy.1Mb.100kb.refs[dxy.1Mb.100kb.refs$chromosome == "CM105789.1",], aes(x=window_pos_mid, y=avg_dxy)) +
  geom_line(cex = 0.8, alpha = 0.5) +
  scale_x_continuous(
    breaks = c(0,1e7,2e7,3e7,4e7,46425774),
    expand = c(0.01,0)
  ) +
  #xlab("position") +
  ylab("dxy") +
  labs(title = ) +
  guides(color = "none") +
  theme_bw() +
  theme(legend.position = "none",
      axis.title.x = element_blank())
dxy





CLRU <- read.table("../09.recombination.maps/03.pyrho/CLRU.genome.1Mb.100kb.rmap", header = T, sep = "\t")
CLRU$rate <- as.numeric(CLRU$rate)

CLGA <- read.table("../09.recombination.maps/03.pyrho/CLGA.genome.1Mb.100kb.rmap", header = T, sep = "\t")
CLGA$rate <- as.numeric(CLGA$rate)

CLRU$species <- "BC_ref_rutilus"
CLGA$species <- "BC_ref_gapperi"
both_long <- rbind(CLRU, CLGA)
both_long$window_pos_mid <- (both_long$start + both_long$end) / 2

both_long <- both_long[both_long$window_pos_mid %% 100000 == 0,]

recombination <- ggplot(both_long[both_long$chrom=="CM105789.1",], aes(x=window_pos_mid, y=rate, color = species)) +
  geom_line(cex = 0.8, alpha = 0.8) +
  xlab("Position (bp)") +
  ylab("Recombination Rate") +
  labs(title = ) +
  scale_x_continuous(
    breaks = c(0,1e7,2e7,3e7,4e7,46425774),
    expand = c(0.01,0)
  ) +
  guides(color = "none") +
  theme(legend.position = "none") +
  scale_color_manual(values = c("#59b4ac", "#d8b365")) +
  theme_bw()
recombination

?cor.test
all(both_long[both_long$species == "BC_ref_rutilus",]$start == both_long[both_long$species == "BC_ref_gapperi",]$start)
rutilus.rates <- both_long[both_long$species == "BC_ref_rutilus",]$rate
gapperi.rates <- both_long[both_long$species == "BC_ref_gapperi",]$rate
cor.test(rutilus.rates, gapperi.rates, method = "spearman")
mean(rutilus.rates, na.rm = T)
mean(gapperi.rates, na.rm = T)





#######################################
##    Make stat figure all at once   ##
#######################################
stats.1Mb.100kb <- data.frame(pop1 = c(dxy.1Mb.100kb.refs$pop1, fst.1Mb.100kb.refs$pop1, pi.1Mb.100kb$pop, both_long$species),
                              pop2 = c(dxy.1Mb.100kb.refs$pop2, fst.1Mb.100kb.refs$pop2, pi.1Mb.100kb$pop, both_long$species),
                              chromosome = c(dxy.1Mb.100kb.refs$chromosome, fst.1Mb.100kb.refs$chromosome, pi.1Mb.100kb$chromosome, both_long$chrom),
                              window_pos_1 = c(dxy.1Mb.100kb.refs$window_pos_1, fst.1Mb.100kb.refs$window_pos_1, pi.1Mb.100kb$window_pos_1, both_long$start),
                              window_pos_2 = c(dxy.1Mb.100kb.refs$window_pos_2, fst.1Mb.100kb.refs$window_pos_2, pi.1Mb.100kb$window_pos_2, both_long$end),
                              window_pos_mid = c(dxy.1Mb.100kb.refs$window_pos_mid, fst.1Mb.100kb.refs$window_pos_mid, pi.1Mb.100kb$window_pos_mid, both_long$window_pos_mid),
                              value = c(dxy.1Mb.100kb.refs$avg_dxy, fst.1Mb.100kb.refs$avg_wc_fst, pi.1Mb.100kb$avg_pi, both_long$rate),
                              stat = c(rep("Dxy", nrow(dxy.1Mb.100kb.refs)), rep("Fst", nrow(fst.1Mb.100kb.refs)), rep("Pi", nrow(pi.1Mb.100kb)), rep("Recombination rate", nrow(both_long)))
)

stats.1Mb.100kb <- stats.1Mb.100kb[stats.1Mb.100kb$pop1 %in% c("BC_ref_gapperi", "BC_ref_rutilus"),]
stats.1Mb.100kb <- stats.1Mb.100kb[stats.1Mb.100kb$chromosome == "CM105789.1",]

stats.1Mb.100kb$color <- NA
stats.1Mb.100kb[stats.1Mb.100kb$pop1 == "BC_ref_gapperi" & stats.1Mb.100kb$pop2 == "BC_ref_gapperi", "color"] <- "BC_ref_gapperi"
stats.1Mb.100kb[stats.1Mb.100kb$pop1 == "BC_ref_rutilus" & stats.1Mb.100kb$pop2 == "BC_ref_rutilus", "color"] <- "BC_ref_rutilus"
stats.1Mb.100kb[stats.1Mb.100kb$pop1 != stats.1Mb.100kb$pop2, "color"] <- "compare"

fst_scaler <- data.frame(window_pos_mid = c(0, 46425774),
                     value = c(0,1),
                     stat = c("Fst", "Fst"),
                     color = c("BC_ref_gapperi", "BC_ref_rutilus"))
dxy_scaler <- data.frame(window_pos_mid = c(0, 46425774),
                         value = c(0,0.01),
                         stat = c("Dxy", "Dxy"),
                         color = c("BC_ref_gapperi", "BC_ref_rutilus"))

  
  
stats.26 <- ggplot(stats.1Mb.100kb, aes(x=window_pos_mid, y=value, color = color)) +
  geom_line(cex = 0.8, alpha = 0.8) +
  geom_blank(data = fst_scaler, aes(x=window_pos_mid, y=value, color = color)) +
  geom_blank(data = dxy_scaler, aes(x=window_pos_mid, y=value, color = color)) +
  facet_wrap( ~ stat, ncol = 1, scales = "free_y") +
  xlab("Position (bp)") +
  ylab("") +
  labs(title = ) +
  scale_x_continuous(
    breaks = c(0,1e7,2e7,3e7,4e7,46425774),
    labels = scales::label_scientific(digits = 2),
    expand = c(0.01,0)
  ) +
  scale_y_continuous(n.breaks = 3) +
  guides(color = "none") +
  scale_color_manual(values = c("#59b4ac", "#d8b365", "black")) +
  theme_bw() +
  theme(legend.position = "none",
        strip.background = element_blank(), # Removes the background box
        strip.text = element_blank()        # Removes the text labels
  )
stats.26
ggsave("stats.26.png", stats.26, width = 3, height = 2)


#############################################################
########               all ANCESTRY_HMM               #######
#############################################################


all.ancestry_hmm.intervals <- read.table("../10.local.ancestry/all.ancestry_hmm.intervals.AIMS10.95.CLGAr.bed", sep = "\t", col.names = c("id", "chr", "start", "end", "state"))


BC.inds <- c("FN3758", "FN3762", "FN3788", "FN3789", "FN3790", "FN3791", "FN3819", "FN3835", "FN3836", "FN3837", "FN3867", "FN3878", "FN3879", "FN3880")
SEAK.inds <- c("FN505", "FN506", "FN534", "FN547", "FN550", "FN572", "FN602", "FN603", "FN605", "FN608", "UAM50293", "UAM50296")
all.ancestry_hmm.intervals$pop <- rep("NA", nrow(all.ancestry_hmm.intervals))
all.ancestry_hmm.intervals[all.ancestry_hmm.intervals$id %in% BC.inds, "pop"] <- "BC"
all.ancestry_hmm.intervals[all.ancestry_hmm.intervals$id %in% SEAK.inds, "pop"] <- "SEAK"

all.ancestry_hmm.intervals.26 <- all.ancestry_hmm.intervals[all.ancestry_hmm.intervals$chr == "CM105789.1",]
lai.26.ancestry_hmm <- ggplot(all.ancestry_hmm.intervals.26, aes(xmin = start, xmax = end, y = id, color = factor(state))) +
  geom_linerange(size = 3) +
  facet_wrap(~ pop, nrow = 2, scales = "free_y") +
  scale_color_manual(values = c("0" = "#D8B365", "1" = "grey", "2" = "#5AB4AB", "UNASSIGNED" = "white")) +
  #scale_color_manual(values = c("gap,gap" = "#5AB4AB", "gap,old" = "#D8B365", "gap,new" = "coral", "old,old" = "gold4", "old,new" = "grey", "new,new" = "darkred",  "UNASSIGNED" = "white")) +
  scale_x_continuous(
    breaks = c(0,1e7,2e7,3e7,4e7,46425774),
    labels = scales::label_scientific(digits = 2),
    expand = c(0.01,0)
  ) +
  theme_bw() +
  theme(
    strip.background = element_rect(fill = "white"),
    panel.grid = element_blank(),
    axis.title = element_blank(),
    axis.text.y = element_text(size = 7.7),
    #axis.text.y = element_blank(),
    legend.position = "none"
  ) 
lai.26.ancestry_hmm


ggsave("lai.26.ancestry_hmm.pdf", lai.26.ancestry_hmm, width = 12, height = 5)




#######################################
###           Figure 2             ###
#######################################
chr26.all <- arrangeGrob(lai.26.ancestry_hmm, stats.26, heights = c(1.2,1))
grid.draw(chr26.all)
ggsave("chr26.all.R.pdf", chr26.all, width = 6, height = 7)
ggsave("chr26.all.wide.R.pdf", chr26.all, width = 12, height = 7)









############################################
###               POSTER                 ###
############################################

################################
###           AHMM           ###
################################

# Add real chromosome name
ahmm.poster <- all.ancestry_hmm.intervals
ahmm.poster$chrom_name <- NA
for (i in 1:27) {
  name <- i
  print(name)
  
  temp_chrom <- 105763.1
  curr_chrom <- temp_chrom + i
  curr_chrom <- paste0("CM", curr_chrom)
  print(curr_chrom)
  
  ahmm.poster[ahmm.poster$chr == curr_chrom, "chrom_name"] <- name
  
}

ahmm.poster$chrom_name <- factor(ahmm.poster$chrom_name, levels = 1:27)

sorted_chroms <- str_sort(unique(ahmm.poster$chrom_name), numeric = T)

ahmm.poster$facet <- factor(
  paste(ahmm.poster$chrom_name, ahmm.poster$pop, sep = "_"),
  levels = as.vector(rbind(
    paste(sorted_chroms, "BC", sep = "_"),
    paste(sorted_chroms, "SEAK", sep = "_")
  ))
)

poster_ahmm <- ggplot(ahmm.poster, aes(xmin = start, xmax = end, y = id, color = factor(state))) +
  geom_linerange(size = 3) +
  #facet_wrap(chrom_name ~ pop, nrow = 2, scales = "free") +
  facet_grid(pop ~ chrom_name, scales = "free", space = "free") +
  #facet_grid(facet ~ ., scales = "free", space = "free", switch = "y") +
  scale_color_manual(values = c("0" = "#D8B365", "1" = "grey", "2" = "#5AB4AB", "UNASSIGNED" = "white")) +
  #scale_color_manual(values = c("gap,gap" = "#5AB4AB", "gap,old" = "#D8B365", "gap,new" = "coral", "old,old" = "gold4", "old,new" = "grey", "new,new" = "darkred",  "UNASSIGNED" = "white")) +
  scale_x_continuous(
    breaks = c(25000000,50000000,75000000,100000000,125000000),
    labels = scales::label_number(scale = 1e-6, suffix = " Mb"),
    #n.breaks = 3,
    expand = c(0.0001,0)
  ) +
  theme_bw() +
  theme(
    strip.background = element_rect(fill = "white"),
    panel.grid = element_blank(),
    axis.title = element_blank(),
    axis.text.y = element_blank(),
    strip.text.y = element_blank(),
    #axis.ticks.y = element_blank(),
    #axis.text.y = element_blank(),
    legend.position = "none",
    
    #strip.placement = "outside",
    #strip.text.y.left = element_text(angle = 0),
  ) 
poster_ahmm
ggsave("poster_ahmm2.pdf", poster_ahmm, width = 47, height = 3.5, limitsize = F)


################################
###           FST            ###
################################

# Add real chromosome name
fst.poster <- fst.1Mb.100kb.refs
fst.poster$chrom_name <- NA
for (i in 1:27) {
  name <- paste0(i)
  print(name)
  
  temp_chrom <- 105763.1
  curr_chrom <- temp_chrom + i
  curr_chrom <- paste0("CM", curr_chrom)
  print(curr_chrom)
  
  fst.poster[fst.poster$chromosome == curr_chrom, "chrom_name"] <- name
  
}

sorted_chroms <- str_sort(unique(fst.poster$chrom_name), numeric = T)


for (i in 1:27) {
  fst_max <- max(fst.poster[fst.poster$chrom_name == i,]$window_pos_mid)
  print(fst_max)
  
  ahmm_max <- max(ahmm.poster[ahmm.poster$chrom_name == i,]$end)
  print(ahmm_max)
  
  max_row <- fst.poster[fst.poster$chrom_name == i & fst.poster$window_pos_mid == fst_max,]
  max_row[8] <- ahmm_max
  max_row[c(4,5,7)] <- NA
  fst.poster <- rbind(fst.poster, max_row)
  
  ahmm_min <- min(ahmm.poster[ahmm.poster$chrom_name == i,]$start)
  print(ahmm_min)
  
  min_row <- fst.poster[fst.poster$chrom_name == i & fst.poster$window_pos_mid == 500000,]
  min_row[8] <- ahmm_min
  min_row[c(4,5,7)] <- NA
  fst.poster <- rbind(fst.poster, min_row)
}

poster_fst <- ggplot(fst.poster, aes(x=window_pos_mid, y=avg_wc_fst)) +
  facet_grid(~ factor(chrom_name, levels = sorted_chroms), scales = "free_x", space = "free_x") +
  geom_line(linewidth = 0.5) +
  scale_x_continuous(
    breaks = c(25000000,50000000,75000000,100000000,125000000),
    labels = scales::label_number(scale = 1e-6, suffix = " Mb"),
    #n.breaks = 3,
    expand = c(0.0001,0)
  ) +
  scale_y_continuous(
    limits = c(0,1),
    breaks = c(0.0, 0.5, 1.0),
    expand = c(0,0)
  ) +
  #xlab("position") +
  ylab("fst") +
  labs(title = ) +
  guides(color = "none") +
  theme_bw() +
  theme(legend.position = "none",
        strip.background = element_rect(fill = "white"),
        axis.title.x = element_blank(),
        axis.title.y = element_blank(),
        axis.text.y = element_blank()
        #axis.text.x = element_blank()
  )
poster_fst
ggsave("poster_fst.pdf", poster_fst, width = 47, height = 1.5, limitsize = F)


################################
###      recombination       ###
################################

# Add real chromosome name
both_long$chrom_name <- NA
for (i in 1:27) {
  name <- i
  print(name)
  
  temp_chrom <- 105763.1
  curr_chrom <- temp_chrom + i
  curr_chrom <- paste0("CM", curr_chrom)
  print(curr_chrom)
  
  both_long[both_long$chrom == curr_chrom, "chrom_name"] <- name
  
}

sorted_chroms <- str_sort(unique(both_long$chrom_name), numeric = T)

recom.poster <- both_long
recom.poster <- recom.poster[!is.na(recom.poster$chrom_name),]

for (i in 1:27) {
  r_max <- max(recom.poster[recom.poster$chrom_name == i,]$window_pos_mid)
  print(r_max)
  
  ahmm_max <- max(ahmm.poster[ahmm.poster$chrom_name == i,]$end)
  print(ahmm_max)
  
  max_row <- recom.poster[recom.poster$chrom_name == i & recom.poster$window_pos_mid == r_max,]
  max_row[,6] <- ahmm_max
  max_row[,c(2,3)] <- NA
  recom.poster <- rbind(recom.poster, max_row)
  
  ahmm_min <- min(ahmm.poster[ahmm.poster$chrom_name == i,]$start)
  print(ahmm_min)
  
  min_row <- recom.poster[recom.poster$chrom_name == i & recom.poster$window_pos_mid == 500000,]
  min_row[,6] <- ahmm_min
  min_row[,c(2,3)] <- NA
  recom.poster <- rbind(recom.poster, min_row)
}


all.chrs.recombination <- ggplot(both_long[both_long$chrom != "CM105791.1",], aes(x=window_pos_mid, y=rate, color = species)) +
  geom_line(cex = 0.8, alpha = 0.7) +
  facet_wrap( ~ factor(chrom_name, levels = sorted_chroms), ncol = 4, scales = "free_x") +
  xlab("Position (bp)") +
  ylab("Recombination Rate") +
  labs(title = ) +
  scale_x_continuous(
    breaks = c(0,4e7,8e7,12e7),
    expand = c(0.02,0)
  ) +
  scale_y_continuous(limits = c(0, 1.5e-8)) +
  guides(color = "none") +
  theme(legend.position = "none") +
  scale_color_manual(values = c("#59b4ac", "#d8b365")) +
  theme_bw()
all.chrs.recombination
ggsave("all.chrs.recombination.png", all.chrs.recombination, width = 10, height = 8)




poster_recombination <- ggplot(recom.poster, aes(x=window_pos_mid, y=rate, color = species)) +
  geom_line(cex = 0.8, alpha = 0.7) +
  facet_grid( ~ factor(chrom_name, levels = sorted_chroms), scales = "free", space = "free") +
  xlab("Position (bp)") +
  ylab("Recombination Rate") +
  labs(title = ) +
  scale_x_continuous(
    breaks = c(25000000,50000000,75000000,100000000,125000000),
    labels = scales::label_number(scale = 1e-6, suffix = " Mb"),
    expand = c(0.0001,0)
  ) +
  scale_y_continuous(limits = c(0, 1.5e-8)) +
  guides(color = "none") +
  scale_color_manual(values = c("#59b4ac", "#d8b365")) +
  theme_bw() +
  theme(legend.position = "none",
        strip.background = element_rect(fill = "white"),
        axis.title.x = element_blank(),
        axis.title.y = element_blank(),
        axis.text.y = element_blank()
  )
poster_recombination
ggsave("poster_recombination.pdf", poster_recombination, width = 47, height = 2, limitsize = F)



################################
###      gene locations      ###
################################

Nmt.genes.selection.bed <- read.table("../17.Nmt.genes/Nmt.genes.selection.dataframe.bed", sep = "\t", header = T)

bed <- Nmt.genes.selection.bed

poster.bed <- bed
poster.bed$mid <- (poster.bed$start + poster.bed$end) /2


# Add real chromosome name
poster.bed$chrom_name <- NA
for (i in 1:27) {
  name <- i
  print(name)
  
  temp_chrom <- 105763.1
  curr_chrom <- temp_chrom + i
  curr_chrom <- paste0("CM", curr_chrom)
  print(curr_chrom)
  
  poster.bed[poster.bed$chr == curr_chrom, "chrom_name"] <- name
  
}

poster.bed <- poster.bed[,c(5,8,9)]
poster.bed$type <- "gene"


for (i in 1:27) {
  ahmm_min <- min(ahmm.poster[ahmm.poster$chrom_name == i,]$start)
  print(ahmm_min)
  
  poster.bed <- rbind(poster.bed, c(1, ahmm_min, i, "non"))
  
  ahmm_max <- max(ahmm.poster[ahmm.poster$chrom_name == i,]$end)
  print(ahmm_max)
  
  poster.bed <- rbind(poster.bed, c(1, ahmm_max, i, "non"))
}

poster.bed$mid <- as.numeric(poster.bed$mid)

poster.bed$chrom_name <- factor(poster.bed$chrom_name, levels = 1:27)

poster_bed <- ggplot(poster.bed, aes(x = mid, y = v, color = type)) +
  geom_point(shape = 15, size = 5) +
  #geom_linerange(size = 3) +
  #facet_wrap(chrom_name ~ pop, nrow = 2, scales = "free") +
  facet_grid( ~ chrom_name, scales = "free", space = "free") +
  #facet_grid(facet ~ ., scales = "free", space = "free", switch = "y") +
  scale_color_manual(values = c("grey20", "white")) +
  scale_x_continuous(
    breaks = c(25000000,50000000,75000000,100000000,125000000),
    labels = scales::label_number(scale = 1e-6, suffix = " Mb"),
    #n.breaks = 3,
    expand = c(0.0001,0)
  ) +
  theme_bw() +
  theme(
    strip.background = element_rect(fill = "white"),
    panel.grid = element_blank(),
    axis.title = element_blank(),
    axis.text.y = element_blank(),
    strip.text.y = element_blank(),
    #axis.ticks.y = element_blank(),
    #axis.text.y = element_blank(),
    legend.position = "none",
    
    #strip.placement = "outside",
    #strip.text.y.left = element_text(angle = 0),
  ) 
poster_bed
ggsave("poster_bed.pdf", poster_bed, width = 47, height = 1, limitsize = F)





############################################
###       Bring in genes                 ###
############################################
Nmt.genes.selection.bed <- read.table("../17.Nmt.genes/Nmt.genes.selection.dataframe.bed", sep = "\t", header = T)

bed <- Nmt.genes.selection.bed

with_buffer_trimmed_outliers <- data.frame(matrix(ncol=7, nrow=0))
for (i in 1:nrow(Nmt.genes.selection.bed)) {
  Nmt_gene <- paste0(bed$gene[i]," (",bed$chr[i],") ",bed$v[i])
  Nmt_chr <- bed$chr[i]
  Nmt_start <- bed$start[i] - 3000000
  Nmt_end <- bed$end[i] + 3000000
  
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


all_outliers_plot <- ggplot(with_buffer_trimmed_outliers, aes(xmin = start, xmax = end, y = id, color = factor(state))) +
  geom_linerange(size = 3) +
  facet_wrap(~ gene, scales = "free_x", ncol = 6) +
  scale_color_manual(values = c("0" = "#D8B365", "1" = "grey", "2" = "#5AB4AB", "UNASSIGNED" = "white")) +
  scale_x_continuous(
    breaks = function(x) {
      r <- range(x, na.rm = TRUE)
      c(r[1], r[1] + 3000000, r[2] - 3000000, r[2])
    },
    expand = c(0, 1)
  ) +
  theme_bw() +
  theme(
    strip.background = element_rect(fill = "white"),
    panel.grid = element_blank(),
    axis.title = element_blank(),
    legend.position = "none",
    axis.text.x = element_text(angle = 45, hjust = 1)
  ) 
all_outliers_plot
ggsave("all_outliers_plot.pdf", all_outliers_plot, width = 16, height = 12)

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







###########################################
####     Combine stats for plotting    ####
###########################################
stats.100kb.10kb <- data.frame(pop1 = c(dxy.100kb.10kb$pop1, fst.100kb.10kb$pop1, td.100kb.10kb$pop, both_long$species),
                               pop2 = c(dxy.100kb.10kb$pop2, fst.100kb.10kb$pop2, td.100kb.10kb$pop, both_long$species),
                               chromosome = c(dxy.100kb.10kb$chromosome, fst.100kb.10kb$chromosome, td.100kb.10kb$chromosome, both_long$chrom),
                               window_pos_1 = c(dxy.100kb.10kb$window_pos_1, fst.100kb.10kb$window_pos_1, td.100kb.10kb$window_pos_1, both_long$start),
                               window_pos_2 = c(dxy.100kb.10kb$window_pos_2, fst.100kb.10kb$window_pos_2, td.100kb.10kb$window_pos_2, both_long$end),
                               window_pos_mid = c(dxy.100kb.10kb$window_pos_mid, fst.100kb.10kb$window_pos_mid, td.100kb.10kb$window_pos_mid, both_long$window_pos_mid),
                               value = c(dxy.100kb.10kb$avg_dxy, fst.100kb.10kb$avg_wc_fst, td.100kb.10kb$tajima_d, both_long$rate),
                               stat = c(rep("Dxy", nrow(dxy.100kb.10kb)), rep("Fst", nrow(fst.100kb.10kb)), rep("Tajima's D", nrow(td.100kb.10kb)), rep("r", nrow(both_long)))
                              )


gene_plot <- function(data = NULL, pop1 = NULL, gene = NULL, chr = NULL, start = NULL, end = NULL, buffer = 0, td_buffer = 0) {
  # subset for each focal pop comparison to both ref pops (dxy and fst)
  ref_gap_comp <- data[(data$pop1==pop1 | data$pop1=="BC_ref_gapperi") & (data$pop2==pop1 | data$pop2=="BC_ref_gapperi"),]
  ref_rut_comp <- data[(data$pop1==pop1 | data$pop1=="BC_ref_rutilus") & (data$pop2==pop1 | data$pop2=="BC_ref_rutilus"),]
  
  # remove td for now
  ref_gap_comp <- ref_gap_comp[ref_gap_comp$stat != "Tajima's D",]
  ref_rut_comp <- ref_rut_comp[ref_rut_comp$stat != "Tajima's D",]
  
  # specify which pop is getting compared to
  ref_gap_comp$comp <- "BC_ref_gapperi"
  ref_rut_comp$comp <- "BC_ref_rutilus"
  
  # combine dataframe
  stat <- rbind(ref_gap_comp, ref_rut_comp)

  # set up td
  td <- data[data$stat == "Tajima's D" & data$pop1 == pop1,]
  td$comp <- pop1
  
  # subset td smaller
  td_start <- start - td_buffer
  td_end <- end + td_buffer
  td <- td[td$chromosome==chr & td$window_pos_1 > td_start & td$window_pos_2 < td_end,]
  
  # mask td smaller than -5
  td[td$value < -5, "value"] <- NA
  
  # add td in now
  stat <- rbind(stat, td)
  
  plot_start <- start - buffer
  plot_end <- end + buffer
  
  subset <- stat[stat$chromosome==chr & stat$window_pos_1 > plot_start & stat$window_pos_2 < plot_end,]
  
  dummy1 <- data.frame(window_pos_mid = c(start, end),
                      value = c(0,1),
                      stat = c("Fst", "Fst"),
                      comp = c("BC_ref_gapperi", "BC_ref_rutilus"))
  dummy2 <- data.frame(window_pos_mid = c(start, end),
                       value = c(0,2e-8),
                       stat = c("r", "r"),
                       comp = c("BC_ref_gapperi", "BC_ref_rutilus"))
  dummy3 <- data.frame(window_pos_mid = c(td_start, td_end, plot_start, plot_end, plot_start, plot_end, plot_start, plot_end),
                       value = c(0,0,0,0,0,0,0,0),
                       stat = c("Tajima's D", "Tajima's D", "Dxy", "Dxy", "Fst", "Fst", "r", "r"),
                       comp = c("BC_ref_gapperi", "BC_ref_rutilus", "BC_ref_gapperi", "BC_ref_rutilus", "BC_ref_gapperi", "BC_ref_rutilus", "BC_ref_gapperi", "BC_ref_rutilus"))
  dummy4 <- data.frame(xmin = c(td_start, td_start, td_start, temp_start),
                       xmax = c(td_end, td_end, td_end, temp_end),
                       ymin = c(-Inf, -Inf, -Inf, -Inf),
                       ymax = c(Inf, Inf, Inf, Inf),
                       stat = c("Fst", "Dxy", "r", "Tajima's D"))
  dummy5 <- data.frame(window_pos_mid = c(start, end),
                       value = c(0,0.011),
                       stat = c("Dxy", "Dxy"),
                       comp = c("BC_ref_gapperi", "BC_ref_rutilus"))
  
  gene_mid <- (temp_start + temp_end) / 2
  
  
  plot <- ggplot(subset) +
    geom_rect(data = dummy4, aes(xmin = xmin, xmax = xmax, ymin = ymin, ymax = ymax), 
              fill = "gray90", alpha = 1, inherit.aes = F) +
    geom_vline(xintercept = gene_mid, color = "gray60") +
    geom_rect(aes(xmin = temp_start, xmax = temp_end, ymin = -Inf, ymax = Inf), 
              fill = "gray60", alpha = 1) +
    geom_line(aes(x=window_pos_mid, y=value, colour = comp), cex = 0.6, alpha = 0.9) +
    geom_blank(data = dummy1, aes(x=window_pos_mid, y=value, colour = comp)) +
    geom_blank(data = dummy2, aes(x=window_pos_mid, y=value, colour = comp)) +
    geom_blank(data = dummy3, aes(x=window_pos_mid, y=value, colour = comp)) +
    geom_blank(data = dummy5, aes(x=window_pos_mid, y=value, colour = comp)) +
    
    facet_wrap( ~ stat, scales = "free", ncol = 1) +
    xlab("Position (bp)") +
    ylab("") +
    #labs(title = gene) +
    scale_x_continuous(breaks=c(plot_start, td_start, gene_mid, td_end, plot_end),
                       labels = scales::label_number(scale = 1e-6, suffix = " Mb", accuracy = 0.1)) +
    scale_y_continuous(n.breaks = 3) +
    #scale_color_manual(values = c("#5AB4AB", "#D8B365", "black")) + #SEAK
    scale_color_manual(values = c("black", "#5AB4AB", "#D8B365")) + #BC
    theme_bw() +
    guides(color = "none") +
    theme(legend.position = "none",
          panel.grid = element_blank(),
          strip.background = element_blank(), # Removes the background box
          strip.text = element_blank()        # Removes the text labels
          )
  #print(plot)
  return(plot)
  
}

for (i in 12) {
  print(Nmt.genes.selection.bed$gene[i])
  temp_gene <- Nmt.genes.selection.bed$gene[i]
  temp_gene_unique <- Nmt.genes.selection.bed$gene_unique[i]
  temp_chr <- Nmt.genes.selection.bed$chr[i]
  temp_start <- Nmt.genes.selection.bed$start[i]
  temp_end <- Nmt.genes.selection.bed$end[i]
}
temp.stat.plot <- gene_plot(data = stats.100kb.10kb, pop1 = "SEAK_discordant", gene = temp_gene, 
                  chr = temp_chr, start = temp_start, end = temp_end, 
                  buffer = 3000000, td_buffer = 500000)


gene.lai <- with_buffer_trimmed_outliers[with_buffer_trimmed_outliers$gene == temp_gene_unique & with_buffer_trimmed_outliers$pop == "BC",]
gene.lai$gene_name <- sapply(strsplit(gene.lai$gene, " "), '[', 1)

temp.lai.plot <- ggplot(gene.lai, aes(xmin = start, xmax = end, y = id, color = factor(state))) +
  geom_linerange(size = 3) +
  facet_wrap( ~ gene_name, scales = "free", ncol = 1) +
  scale_color_manual(values = c("0" = "#D8B365", "1" = "grey", "2" = "#5AB4AB", "UNASSIGNED" = "white")) +
  scale_x_continuous(breaks = c(temp_start - 3000000, temp_start, temp_end, temp_end + 3000000)) +
  theme_bw() +
  #labs(title = temp_gene) +
  theme(
    #strip.background = element_rect(fill = "white"),
    #strip.text = element_blank(),
    panel.grid = element_blank(),
    axis.title = element_blank(),
    axis.text.y = element_text(size = 10.5),  # BC
    #axis.text.y = element_text(size = 9.2), # SEAK
    #axis.text.x = element_text(angle = 45, hjust = 1)
    legend.position = "none",
  ) 
temp.lai.plot


grid.arrange(temp.lai.plot, temp.stat.plot, heights = c(1,2))


#Nmt.genes.ALL.bed <- read.table("../17.Nmt.genes/Nmt.genes.ALL.bed", sep = "\t", header = T)

#bed <- Nmt.genes.ALL.bed
bed <- Nmt.genes.selection.bed

j <- 1
#for (i in 161:182) {
for (i in c(1:18)) {
  print(bed$gene[i])
  temp_gene <- bed$gene[i]
  temp_gene_unique <- bed$gene_unique[i]
  temp_chr <- bed$chr[i]
  temp_start <- bed$start[i]
  temp_end <- bed$end[i]
  
  temp.stat.plot <- gene_plot(data = stats.100kb.10kb, pop1 = "SEAK_discordant", gene = temp_gene, 
                    chr = temp_chr, start = temp_start, end = temp_end, 
                    buffer = 3000000, td_buffer = 500000)
  
  
  gene.lai <- with_buffer_trimmed_outliers[with_buffer_trimmed_outliers$gene == temp_gene_unique & with_buffer_trimmed_outliers$pop == "SEAK",]
  gene.lai$gene_name <- sapply(strsplit(gene.lai$gene, " "), '[', 1)
  
  temp.lai.plot <- ggplot(gene.lai, aes(xmin = start, xmax = end, y = id, color = factor(state))) +
    geom_linerange(size = 3) +
    facet_wrap( ~ gene_name, scales = "free", ncol = 1) +
    scale_color_manual(values = c("0" = "#D8B365", "1" = "grey", "2" = "#5AB4AB", "UNASSIGNED" = "white")) +
    scale_x_continuous(breaks = c(temp_start - 3000000, temp_start, temp_end, temp_end + 3000000),
                       labels = scales::label_number(scale = 1e-6, suffix = " Mb", accuracy = 0.1),) +
    theme_bw() +
    #labs(title = temp_gene) +
    theme(
      #strip.background = element_rect(fill = "white"),
      #strip.text = element_blank(),
      panel.grid = element_blank(),
      axis.title = element_blank(),
      #axis.text.y = element_text(size = 10.5),  # BC
      axis.text.y = element_text(size = 7.9), # SEAK
      #axis.text.x = element_text(angle = 45, hjust = 1)
      legend.position = "none",
    ) 
  
  grid.arrange(temp.lai.plot, temp.stat.plot, heights = c(1,1.5))
  
  gene.plot <- arrangeGrob(temp.lai.plot, temp.stat.plot, heights = c(1,1.5))
  
  assign(paste0(temp_gene, ".SEAK.plot"), gene.plot)

}

for (i in c(1:18)) {
  print(bed$gene[i])
  temp_gene <- bed$gene[i]
  temp_gene_unique <- bed$gene_unique[i]
  temp_chr <- bed$chr[i]
  temp_start <- bed$start[i]
  temp_end <- bed$end[i]
  
  temp.stat.plot <- gene_plot(data = stats.100kb.10kb, pop1 = "BC_discordant", gene = temp_gene, 
                              chr = temp_chr, start = temp_start, end = temp_end, 
                              buffer = 3000000, td_buffer = 500000)
  
  
  gene.lai <- with_buffer_trimmed_outliers[with_buffer_trimmed_outliers$gene == temp_gene_unique & with_buffer_trimmed_outliers$pop == "BC",]
  gene.lai$gene_name <- sapply(strsplit(gene.lai$gene, " "), '[', 1)
  
  temp.lai.plot <- ggplot(gene.lai, aes(xmin = start, xmax = end, y = id, color = factor(state))) +
    geom_linerange(size = 3) +
    facet_wrap( ~ gene_name, scales = "free", ncol = 1) +
    scale_color_manual(values = c("0" = "#D8B365", "1" = "grey", "2" = "#5AB4AB", "UNASSIGNED" = "white")) +
    scale_x_continuous(breaks = c(temp_start - 3000000, temp_start, temp_end, temp_end + 3000000),
                       labels = scales::label_number(scale = 1e-6, suffix = " Mb", accuracy = 0.1)) +
    theme_bw() +
    #labs(title = temp_gene) +
    theme(
      #strip.background = element_rect(fill = "white"),
      #strip.text = element_blank(),
      panel.grid = element_blank(),
      axis.title = element_blank(),
      axis.text.y = element_text(size = 10.5),  # BC
      #axis.text.y = element_text(size = 7.9), # SEAK
      #axis.text.x = element_text(angle = 45, hjust = 1)
      legend.position = "none",
    ) 
  
  grid.arrange(temp.lai.plot, temp.stat.plot, heights = c(1,1.5))
  
  gene.plot <- arrangeGrob(temp.lai.plot, temp.stat.plot, heights = c(1,1.5))
  
  assign(paste0(temp_gene, ".BC.plot"), gene.plot)
  
}

grid.draw(Neu4.BC.plot)
grid.draw(Nt5dc2.SEAK.plot)

BC.genes <- grid.arrange(Hemk1.BC.plot, Kars.BC.plot, Me2.BC.plot, Acadsb.BC.plot, Neu4.BC.plot, ncol = 5)
SEAK.genes <- grid.arrange(Hemk1.SEAK.plot, Kars.SEAK.plot, Me2.SEAK.plot, Acadsb.SEAK.plot, Neu4.SEAK.plot, ncol = 5)
grid.draw(BC.genes)
grid.draw(SEAK.genes)

grid.arrange(BC.genes, SEAK.genes, nrow = 2)

ggsave(filename = "BC.genes.R.pdf", BC.genes, width = 10, height = 6)
ggsave(filename = "SEAK.genes.R.pdf", SEAK.genes, width = 10, height = 6)


ls(pattern = "*.BC.plot")

all.BC.genes <- grid.arrange(Cox15.BC.plot, Ndufa6.BC.plot, Acadsb.BC.plot, Smdt1.BC.plot, Me2.BC.plot, Mtarc2.BC.plot, Hmgcs2.BC.plot, Acsm5.BC.plot, 
                             Rdh13.BC.plot, Hemk1.BC.plot, Slc25a2.BC.plot, Kars.BC.plot, Mavs.BC.plot, Arf5.BC.plot, Acsm2.BC.plot, Cyb5r3.BC.plot, 
                             Neu4.BC.plot, Nt5dc2.BC.plot, ncol = 6)
all.SEAK.genes <- grid.arrange(Cox15.SEAK.plot, Ndufa6.SEAK.plot, Acadsb.SEAK.plot, Smdt1.SEAK.plot, Me2.SEAK.plot, Mtarc2.SEAK.plot, Hmgcs2.SEAK.plot, Acsm5.SEAK.plot, 
                               Rdh13.SEAK.plot, Hemk1.SEAK.plot, Slc25a2.SEAK.plot, Kars.SEAK.plot, Mavs.SEAK.plot, Arf5.SEAK.plot, Acsm2.SEAK.plot, Cyb5r3.SEAK.plot, 
                               Neu4.SEAK.plot, Nt5dc2.SEAK.plot , ncol = 6)
grid.draw(all.BC.genes)
grid.draw(all.SEAK.genes)

ggsave(filename = "all.BC.genes.R.pdf", all.BC.genes, width = 10, height = 18)
ggsave(filename = "all.SEAK.genes.R.pdf", all.SEAK.genes, width = 10, height = 18)


for (i in bed$gene) {
  ggsave(filename = paste0("gene.plots/BC/", i, ".BC.plot.png"), get(paste0(i, ".BC.plot")), width = 2, height = 6)
  print(i)
}
for (i in bed$gene) {
  ggsave(filename = paste0("gene.plots/SEAK/", i, ".SEAK.plot.png"), get(paste0(i, ".SEAK.plot")), width = 2, height = 6)
  print(i)
}


#############################################
#####         Poster gene plots        ######
#############################################

# to run this, need to go back and set ahmm borders to 2,000,000
# with_buffer_trimmed_outliers

poster_plot <- function(data = NULL, gene = NULL, pop1 = NULL, chr = NULL, start = NULL, end = NULL, buffer = 0) {

  # subset for each focal pop comparison to both ref pops (dxy and fst)
  ref_gap_comp <- data[(data$pop1==pop1 | data$pop1=="BC_ref_gapperi") & (data$pop2==pop1 | data$pop2=="BC_ref_gapperi"),]
  ref_rut_comp <- data[(data$pop1==pop1 | data$pop1=="BC_ref_rutilus") & (data$pop2==pop1 | data$pop2=="BC_ref_rutilus"),]
  
  # remove dxy
  #ref_gap_comp <- ref_gap_comp[ref_gap_comp$stat != "Dxy",]
  #ref_rut_comp <- ref_rut_comp[ref_rut_comp$stat != "Dxy",]
  
  # remove td
  ref_gap_comp <- ref_gap_comp[ref_gap_comp$stat != "Tajima's D",]
  ref_rut_comp <- ref_rut_comp[ref_rut_comp$stat != "Tajima's D",]
  
  # remove r
  ref_gap_comp <- ref_gap_comp[ref_gap_comp$stat != "r",]
  ref_rut_comp <- ref_rut_comp[ref_rut_comp$stat != "r",]
  
  
  # specify which pop is getting compared to
  ref_gap_comp$comp <- "BC_ref_gapperi"
  ref_rut_comp$comp <- "BC_ref_rutilus"
  
  # combine dataframe
  stat <- rbind(ref_gap_comp, ref_rut_comp)
  
  # add discordant pop
  stat$d_pop <- pop1
  
  plot_start <- start - buffer
  plot_end <- end + buffer
  
  subset <-stat[stat$chromosome==chr & stat$window_pos_1 > plot_start & stat$window_pos_2 < plot_end,]
  


  dummy1 <- data.frame(window_pos_mid = c(start, end),
                       value = c(0,1),
                       stat = c("Fst", "Fst"),
                       comp = c("BC_ref_gapperi", "BC_ref_rutilus"))
  dummy2 <- data.frame(window_pos_mid = c(start, end),
                       value = c(0,0.011),
                       stat = c("Dxy", "Dxy"),
                       comp = c("BC_ref_gapperi", "BC_ref_rutilus"))
  
  
  gene_mid <- (temp_start + temp_end) / 2
  
  
  plot <- ggplot(subset) +

    geom_vline(xintercept = gene_mid, color = "gray60") +
    geom_rect(aes(xmin = temp_start, xmax = temp_end, ymin = -Inf, ymax = Inf), 
              fill = "gray60", alpha = 1) +
    geom_line(aes(x=window_pos_mid, y=value, colour = comp), cex = 0.6, alpha = 0.9) +
    geom_blank(data = dummy1, aes(x=window_pos_mid, y=value, colour = comp)) +
    geom_blank(data = dummy2, aes(x=window_pos_mid, y=value, colour = comp)) +
    
    facet_wrap( ~ stat, scales = "free", ncol = 1) +
    xlab("") +
    ylab("") +
    #labs(title = gene) +
    scale_x_continuous(breaks=c(plot_start, gene_mid, plot_end),
                       labels = scales::label_number(scale = 1e-6, suffix = " Mb", accuracy = 1),) +
    scale_y_continuous(n.breaks = 3) +
    scale_color_manual(values = c("#5AB4AB", "#D8B365", "black")) + #SEAK
    #scale_color_manual(values = c("black", "#5AB4AB", "#D8B365")) + #BC
    theme_bw() +
    guides(color = "none") +
    theme(legend.position = "none",
          panel.grid = element_blank(),
          strip.background = element_blank(),
          strip.text = element_blank(),         
          axis.text.y = element_blank(),
          axis.text.x = element_text(size = 8),
          axis.title.x = element_blank()
    
          )
  #print(plot)
  return(plot)
  
}

for (i in 5) {
  print(Nmt.genes.selection.bed$gene[i])
  temp_gene <- Nmt.genes.selection.bed$gene[i]
  temp_gene_unique <- Nmt.genes.selection.bed$gene_unique[i]
  temp_chr <- Nmt.genes.selection.bed$chr[i]
  temp_start <- Nmt.genes.selection.bed$start[i]
  temp_end <- Nmt.genes.selection.bed$end[i]
}
poster_plot(data = stats.100kb.10kb, pop1 = "SEAK_discordant", gene = temp_gene, 
            chr = temp_chr, start = temp_start, end = temp_end, 
            buffer = 2000000)







for (i in c(1:18)) {
  print(bed$gene[i])
  temp_gene <- bed$gene[i]
  temp_gene_unique <- bed$gene_unique[i]
  temp_chr <- bed$chr[i]
  temp_start <- bed$start[i]
  temp_end <- bed$end[i]
  
  temp.stat.plot <- poster_plot(data = stats.100kb.10kb, pop1 = "BC_discordant", gene = temp_gene, 
                                chr = temp_chr, start = temp_start, end = temp_end, 
                                buffer = 2000000)
  
  
  gene.lai <- with_buffer_trimmed_outliers[with_buffer_trimmed_outliers$gene == temp_gene_unique & with_buffer_trimmed_outliers$pop == "BC",]
  gene.lai$gene_name <- sapply(strsplit(gene.lai$gene, " "), '[', 1)
  
  gene_mid <- (temp_start + temp_end) / 2
  
  temp.lai.plot <- ggplot(gene.lai, aes(xmin = start, xmax = end, y = id, color = factor(state))) +
    geom_linerange(size = 2) +
    facet_wrap( ~ gene_name, scales = "free", ncol = 1) +
    scale_color_manual(values = c("0" = "#D8B365", "1" = "grey", "2" = "#5AB4AB", "UNASSIGNED" = "white")) +
    scale_x_continuous(breaks = c(temp_start - 2000000, gene_mid, temp_end + 2000000),
                       labels = scales::label_number(scale = 1e-6, suffix = " Mb", accuracy = 1),) +
    theme_bw() +
    #labs(title = temp_gene) +
    theme(
      #strip.background = element_rect(fill = "white"),
      #strip.text = element_blank(),
      panel.grid = element_blank(),
      axis.title = element_blank(),
      axis.text.y = element_text(size = 2.9),  # BC
      axis.text.x = element_text(size = 8),
      legend.position = "none",
    ) 
  
  grid.arrange(temp.lai.plot, temp.stat.plot, heights = c(1.1,1))
  
  gene.plot <- arrangeGrob(temp.lai.plot, temp.stat.plot, heights = c(1.1,1))
  
  assign(paste0(temp_gene, ".BC.poster"), gene.plot)
  
}


for (i in c(1:18)) {
  print(bed$gene[i])
  temp_gene <- bed$gene[i]
  temp_gene_unique <- bed$gene_unique[i]
  temp_chr <- bed$chr[i]
  temp_start <- bed$start[i]
  temp_end <- bed$end[i]
  
  temp.stat.plot <- poster_plot(data = stats.100kb.10kb, pop1 = "SEAK_discordant", gene = temp_gene, 
                              chr = temp_chr, start = temp_start, end = temp_end, 
                              buffer = 2000000)
  
  
  gene.lai <- with_buffer_trimmed_outliers[with_buffer_trimmed_outliers$gene == temp_gene_unique & with_buffer_trimmed_outliers$pop == "SEAK",]
  gene.lai$gene_name <- sapply(strsplit(gene.lai$gene, " "), '[', 1)
  
  gene_mid <- (temp_start + temp_end) / 2
  
  temp.lai.plot <- ggplot(gene.lai, aes(xmin = start, xmax = end, y = id, color = factor(state))) +
    geom_linerange(size = 2) +
    facet_wrap( ~ gene_name, scales = "free", ncol = 1) +
    scale_color_manual(values = c("0" = "#D8B365", "1" = "grey", "2" = "#5AB4AB", "UNASSIGNED" = "white")) +
    scale_x_continuous(breaks = c(temp_start - 2000000, gene_mid, temp_end + 2000000),
                       labels = scales::label_number(scale = 1e-6, suffix = " Mb", accuracy = 1),) +
    theme_bw() +
    #labs(title = temp_gene) +
    theme(
      #strip.background = element_rect(fill = "white"),
      #strip.text = element_blank(),
      panel.grid = element_blank(),
      axis.title = element_blank(),
      axis.text.y = element_text(size = 2.1), # SEAK
      axis.text.x = element_text(size = 8),
      legend.position = "none",
    ) 
  
  grid.arrange(temp.lai.plot, temp.stat.plot, heights = c(1.1,1))
  
  gene.plot <- arrangeGrob(temp.lai.plot, temp.stat.plot, heights = c(1.1,1))
  
  assign(paste0(temp_gene, ".SEAK.poster"), gene.plot)
  
}

grid.draw(Neu4.BC.poster)
grid.draw(Nt5dc2.SEAK.poster)

BC.genes <- grid.arrange(Neu4.BC.poster, Rdh13.BC.poster, Arf5.BC.poster, Hemk1.BC.poster, Mtarc2.BC.poster, Nt5dc2.BC.poster, Acadsb.BC.poster, Acsm2.BC.poster, Acsm5.BC.poster, Cox15.BC.poster, Mavs.BC.poster, Me2.BC.poster, Slc25a2.BC.poster, Hmgcs2.BC.poster, Kars.BC.poster, Cyb5r3.BC.poster, Ndufa6.BC.poster, Smdt1.BC.poster, ncol = 18)
SEAK.genes <- grid.arrange(Neu4.SEAK.poster, Rdh13.SEAK.poster, Arf5.SEAK.poster, Hemk1.SEAK.poster, Mtarc2.SEAK.poster, Nt5dc2.SEAK.poster, Acadsb.SEAK.poster, Acsm2.SEAK.poster, Acsm5.SEAK.poster, Cox15.SEAK.poster, Mavs.SEAK.poster, Me2.SEAK.poster, Slc25a2.SEAK.poster, Hmgcs2.SEAK.poster, Kars.SEAK.poster, Cyb5r3.SEAK.poster, Ndufa6.SEAK.poster, Smdt1.SEAK.poster, ncol = 18)
grid.draw(BC.genes)
grid.draw(SEAK.genes)

poster.genes <- grid.arrange(BC.genes, SEAK.genes, nrow = 2)

ggsave(filename = "poster.genes.R.pdf", poster.genes, width = 25, height = 6.6)
ggsave(filename = "poster.genes.R.png", poster.genes, width = 25, height = 6.6)




