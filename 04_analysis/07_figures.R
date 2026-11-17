# 07_figures.R ----------------------------------------------------------------
# Command:  Rscript 04_analysis/07_figures.R
# Outputs (05_results/figures, PNG for drafts and PDF for the journal):
#   Fig1_rebuild_vs_reported   baseline edges, reported against rebuilt
#   Fig2_network               primary network, bridge nodes outlined in olive
#   Fig3_centrality            expected influence and bridge influence
#   Fig4_stability             case-dropping stability (CS)
#   Fig5_edge_accuracy         bootstrap CIs of the strongest edges
# Greyscale first, one olive highlight. Demo figures carry a watermark.
# -----------------------------------------------------------------------------
source("04_analysis/settings.R")
suppressPackageStartupMessages({ library(qgraph); library(bootnet); library(ggplot2) })
fits <- readRDS(file.path(PATHS$clean, "network_fits.rds"))
fig <- function(name) file.path(PATHS$figures, paste0(TAG, name))
mark <- function() if (IS_DEMO) mtext(WATERMARK, side = 1, line = 0, cex = 0.8, col = "grey40")
both <- function(name, w, h, draw) {
  png(paste0(fig(name), ".png"), width = w, height = h, units = "in", res = 200); draw(); dev.off()
  pdf(paste0(fig(name), ".pdf"), width = w, height = h); draw(); dev.off()
}

# Fig 1: the rebuild is real (from the published table), so it carries no watermark
log <- read.csv(file.path(PATHS$tables, "T2_rebuild_vs_reported.csv"))
both("Fig1_rebuild_vs_reported", 5, 5, function() {
  plot(log$reported, log$rebuilt, pch = 16, col = "grey30", xlab = "Edge weight reported (Table 2)",
       ylab = "Edge weight rebuilt from Table 1", main = "Baseline rebuild (Cho & Kim, 2025)")
  abline(0, 1, col = OLIVE, lwd = 2)
  mtext(sprintf("r = %.3f across %d node pairs", cor(log$reported, log$rebuilt), nrow(log)), side = 3, line = 0.2, cex = 0.8)
})

# Fig 2: network
W <- fits$net_p$graph; comm <- SETTINGS$communities
top_bridges <- head(fits$cen$node[order(-fits$cen$BEI1)], 3)
greys <- c(Impulsivity = "grey95", SocialMedia = "grey80", Disengagement = "grey65", RiskyPractice = "grey50", Judgment = "white")
both("Fig2_network", 8, 7, function() {
  qgraph(W, layout = "spring", groups = split(seq_along(comm), factor(comm, levels = names(greys))),
         color = greys, posCol = "black", negCol = "grey55", negDashed = TRUE, labels = colnames(W),
         border.color = ifelse(colnames(W) %in% top_bridges, OLIVE, "black"),
         border.width = ifelse(colnames(W) %in% top_bridges, 4, 1), legend.cex = 0.45, vsize = 5,
         title = "Primary network (bridge nodes outlined in olive)")
  mark()
})

# Fig 3: centrality
cen <- fits$cen
both("Fig3_centrality", 7, 8, function() {
  o <- order(cen$BEI1); par(mfrow = c(1, 2), mar = c(4, 7, 3, 1))
  barplot(cen$EI[o], names.arg = cen$node[o], horiz = TRUE, las = 1, cex.names = 0.6, col = "grey60", main = "Expected influence (z)")
  barplot(cen$BEI1[o], names.arg = cen$node[o], horiz = TRUE, las = 1, cex.names = 0.6,
          col = ifelse(cen$node[o] %in% top_bridges, OLIVE, "grey60"), main = "Bridge EI, 1-step (z)")
  mark()
})

# Fig 4 and Fig 5: bootnet plots (ggplot)
cap <- labs(caption = WATERMARK)
g4 <- suppressMessages(plot(fits$b_case, statistics = c("expectedInfluence", "bridgeExpectedInfluence")) + cap + theme_bw() +
  scale_colour_manual(values = c("grey20", OLIVE)) + scale_fill_manual(values = c("grey70", OLIVE)))
es <- summary(fits$b_edge, statistics = "edge")
es <- es[es$sample != 0 | es$mean != 0, ]
es <- es[order(es$sample), ]; es$rank <- seq_len(nrow(es))
g5 <- ggplot(es, aes(x = rank)) +
  geom_ribbon(aes(ymin = CIlower, ymax = CIupper), fill = "grey80") +
  geom_line(aes(y = mean), colour = "grey20") +
  geom_point(aes(y = sample), colour = OLIVE, size = 0.8) +
  geom_hline(yintercept = 0, colour = "grey50") + coord_flip() + theme_bw() +
  labs(x = "Edges, ordered by sample weight", y = "Edge weight (olive = sample, line = bootstrap mean, band = 95% CI)", caption = WATERMARK) +
  theme(axis.text.y = element_blank(), axis.ticks.y = element_blank())
for (ext in c("png", "pdf")) {
  ggsave(paste0(fig("Fig4_stability"), ".", ext), g4, width = 7, height = 4.5, dpi = 200)
  ggsave(paste0(fig("Fig5_edge_accuracy"), ".", ext), g5, width = 6, height = 7, dpi = 200)
}
msg("Figures written to ", PATHS$figures, ". Next: Rscript 04_analysis/08_integrity_report.R")
