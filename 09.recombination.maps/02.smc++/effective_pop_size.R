setwd("~/Documents/Ben's Stuff/0 KU/Dissertation/009.RBV.WGS/09.recombination.maps/02.smc++")

library(ggplot2)

CLGA <- read.table("CLGA.ftol1e-3.csv", header = T, sep = ",")
CLRU <- read.table("CLRU.ftol1e-3.csv", header = T, sep = ",")

voles <- rbind(CLGA, CLRU)


# code for plot modified from:
# https://github.com/mishaploid/carrot-demography/blob/main/summarize_smc_results.md#35-plot-results-from-smc-split-fig-3d

estimate_plot <-  
  ggplot() + 
  # shade region
  annotate('rect', 
           xmin = (10700*1.5), 
           xmax = (110000*1.5), 
           ymin = 0, 
           ymax = Inf,
           alpha = 0.5,
           fill = 'gray') + 

  # add lines for marginal estimates 
  geom_path(data = voles, 
            aes(x = x, 
                y = y,
                color = label), 
            size = 1.5,
            lineend = 'round') +
  #scale_color_manual(values = cols) + 
    
  # use a log10 scale for x and y axes and set number of breaks 
  scale_x_log10(breaks = scales::trans_breaks("log10", function(x) 10^x, n = 4),
                labels = scales::trans_format("log10", scales::math_format(10^.x)),
                limits = c(10,1100000),
                expand = c(0,0)) +
  scale_y_log10(breaks = scales::trans_breaks("log10", function(x) 10^x, n = 3),
                labels = scales::trans_format("log10", scales::math_format(10^.x))) + 
  annotation_logticks() +
  xlab("Generations ago") +
  ylab("Effective population size") +
  theme_classic() +
  theme(legend.title = element_blank(),
        legend.position = c(.9,.2)) +
  scale_x_log10(
    breaks = scales::trans_breaks("log10", function(x) 10^x, n = 4),
    labels = scales::trans_format("log10", scales::math_format(10^.x)),
    limits = c(10, 1100000),
    expand = c(0,0),
    sec.axis = sec_axis(~ . / 1.5,
                        name = "Years ago",
                        breaks = c(1e2, 2e3, 7e3, 2e4, 1.3e5, 1e6),
                        labels = scales::comma)) +
  theme(panel.border = element_rect(color = "black", fill = NA, linewidth = 1)) +
  annotate("text", x = 10^4.7, y = 10^5.5, label = "Last Glacial Period", 
           color = "black", size = 3)
estimate_plot 

ggsave("dem_history_FIXED.pdf", plot = estimate_plot, width = 6, height = 3)






estimate_plot <-  
  ggplot() + 
  # shade region
  annotate('rect', 
           xmin = (10700*1.5), 
           xmax = (110000*1.5), 
           ymin = 0, 
           ymax = Inf,
           alpha = 0.5,
           fill = 'gray') + 
  
  # add lines for marginal estimates 
  geom_path(data = voles, 
            aes(x = x, 
                y = y,
                color = label), 
            size = 1.5,
            lineend = 'round') +
  #scale_color_manual(values = cols) + 
  
  # use a log10 scale for x and y axes and set number of breaks 
  scale_x_log10(breaks = scales::trans_breaks("log10", function(x) 10^x, n = 4),
                labels = scales::trans_format("log10", scales::math_format(10^.x)),
                limits = c(10,1100000),
                expand = c(0,0)) +
  scale_y_log10(breaks = scales::trans_breaks("log10", function(x) 10^x, n = 3),
                labels = scales::trans_format("log10", scales::math_format(10^.x))) + 
  annotation_logticks() +
  xlab("Generations ago") +
  ylab("Effective population size") +
  theme_classic() +
  theme(legend.title = element_blank(),
        legend.position = c(.9,.2)) +
  scale_x_log10(
    breaks = scales::trans_breaks("log10", function(x) 10^x, n = 4),
    labels = scales::trans_format("log10", scales::math_format(10^.x)),
    limits = c(10, 1100000),
    expand = c(0,0),
    sec.axis = sec_axis(~ . / 1.5,
                        name = "Years ago",
                        breaks = c(1e2, 2e3, 7e3, 2e4, 1.3e5, 1e6),
                        labels = scales::comma)) +
  theme(panel.border = element_rect(color = "black", fill = NA, linewidth = 1)) +
  annotate("text", x = 10^4.7, y = 10^5.5, label = "Last Glacial Period", 
           color = "black", size = 3) +
  scale_color_manual(values = c("#5AB4AB", "#D8B365"))
estimate_plot 

ggsave("dem_history_POSTER.pdf", plot = estimate_plot, width = 7, height = 3)






