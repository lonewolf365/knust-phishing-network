# 05_structural.R (the network) -----------------------------------------------
# Command:  Rscript 04_analysis/05_structural.R
# Outputs:  05_results/tables/edges_primary.csv, centrality_primary.csv,
#           stability_cs.csv, sensitivity.csv, 03_data/clean/network_fits.rds
# Estimates the primary network (polychoric correlations, EBICglasso,
# gamma 0.5), expected influence, bridge expected influence (1 and 2 step),
# node predictability, edge accuracy (bootstrap CIs), case-dropping stability
# (CS) and difference tests. Sensitivity: Pearson input and no screening.
# Edges are associations, never causes.
# -----------------------------------------------------------------------------
source("04_analysis/settings.R")
suppressPackageStartupMessages({ library(bootnet); library(qgraph); library(networktools); library(mgm) })
nodes_s <- readRDS(file.path(PATHS$clean, "nodes_screened.rds"))
nodes_u <- readRDS(file.path(PATHS$clean, "nodes_unscreened.rds"))
comm <- SETTINGS$communities

fit <- function(d, cor_method) suppressMessages(suppressWarnings(
  estimateNetwork(d, default = "EBICglasso", corMethod = cor_method, tuning = SETTINGS$gamma, verbose = FALSE)))
net_p <- fit(nodes_s, SETTINGS$cor_primary)       # primary
net_r <- fit(nodes_s, SETTINGS$cor_sensitivity)   # Pearson sensitivity
net_u <- fit(nodes_u, SETTINGS$cor_primary)       # no screening
W <- net_p$graph
ut <- upper.tri(W)
msg("Primary network: ", sum(W[ut] != 0), " non-zero edges of ", sum(ut), ".")

edges <- which(ut & W != 0, arr.ind = TRUE)
et <- data.frame(node_a = colnames(W)[edges[, 1]], node_b = colnames(W)[edges[, 2]], weight = round(W[edges], 3))
et <- et[order(-abs(et$weight)), ]
write.csv(et, file.path(PATHS$tables, paste0(TAG, "edges_primary.csv")), row.names = FALSE)

# Centrality and bridges (z-scores, as in the baseline)
z <- function(x) round(as.numeric(scale(x)), 2)
br <- bridge(W, communities = comm)
pred_fit <- mgm(scale(as.matrix(nodes_s)), type = rep("g", ncol(nodes_s)), level = rep(1, ncol(nodes_s)),
                lambdaSel = "EBIC", lambdaGam = SETTINGS$gamma, k = 2, pbar = FALSE, signInfo = FALSE)
pred <- predict(pred_fit, scale(as.matrix(nodes_s)), errorCon = "R2")
cen <- data.frame(node = colnames(W), community = comm,
                  EI = z(centrality(W)$InExpectedInfluence),
                  BEI1 = z(br$`Bridge Expected Influence (1-step)`),
                  BEI2 = z(br$`Bridge Expected Influence (2-step)`),
                  predictability_R2 = round(pred$errors$R2, 2))
cen <- cen[order(-cen$BEI1), ]
write.csv(cen, file.path(PATHS$tables, paste0(TAG, "centrality_primary.csv")), row.names = FALSE)

# Accuracy and stability
msg("Bootstrapping edges (", SETTINGS$n_boot_edges, " runs). This is the slow step.")
b_edge <- suppressMessages(bootnet(net_p, nBoots = SETTINGS$n_boot_edges, nCores = SETTINGS$n_cores,
                                   statistics = c("edge", "expectedInfluence"), verbose = FALSE))
msg("Case-dropping bootstrap (", SETTINGS$n_boot_case, " runs).")
b_case <- suppressMessages(bootnet(net_p, nBoots = SETTINGS$n_boot_case, type = "case", nCores = SETTINGS$n_cores,
                                   statistics = c("expectedInfluence", "bridgeExpectedInfluence"),
                                   communities = comm, verbose = FALSE))
cs <- corStability(b_case, cor = SETTINGS$cs_cor, verbose = FALSE)
cs_tab <- data.frame(statistic = names(cs), CS = round(as.numeric(cs), 2),
                     reading = ifelse(cs >= .5, "preferred (>= 0.50)", ifelse(cs >= .25, "acceptable (>= 0.25)", "too unstable to interpret")))
write.csv(cs_tab, file.path(PATHS$tables, paste0(TAG, "stability_cs.csv")), row.names = FALSE)
print(cs_tab, row.names = FALSE)

# Sensitivity: how much do the edges move?
cmp <- function(a, b) round(cor(a$graph[ut], b$graph[ut]), 3)
sens <- data.frame(comparison = c("Polychoric vs Pearson", "Screened vs unscreened"),
                   edge_correlation = c(cmp(net_p, net_r), cmp(net_p, net_u)))
write.csv(sens, file.path(PATHS$tables, paste0(TAG, "sensitivity.csv")), row.names = FALSE)
print(sens, row.names = FALSE)
saveRDS(list(net_p = net_p, b_edge = b_edge, b_case = b_case, cen = cen),
        file.path(PATHS$clean, "network_fits.rds"))
msg("Network done. Next: Rscript 04_analysis/06_options.R")
