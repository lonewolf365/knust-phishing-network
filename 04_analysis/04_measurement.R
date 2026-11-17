# 04_measurement.R ------------------------------------------------------------
# Command:  Rscript 04_analysis/04_measurement.R
# Outputs:  05_results/tables/reliability.csv, descriptives_knust.csv,
#           correlations_knust.csv, correlations_public.csv, redundancy.csv,
#           03_data/clean/nodes_screened.rds, nodes_unscreened.rds
# Scores the five impulsivity facets (mean of 4 items), scores d' and c from
# the 16 emails, reports reliability, the correlation matrix with means, SDs
# and N for both samples, and the redundancy check (goldbricker) that must run
# before any centrality is read.
# -----------------------------------------------------------------------------
source("04_analysis/settings.R")
source("04_analysis/functions.R")
suppressPackageStartupMessages({ library(psych); library(networktools) })
key <- read.csv(PATHS$email_key)
is_phish <- key$label == "phishing"

make_nodes <- function(dat) {
  out <- dat[SETTINGS$shared_items]
  for (f in SETTINGS$facets) out[[f]] <- rowMeans(dat[paste0(f, 1:4)])
  sdt <- sdt_scores(as.matrix(dat[key$email]), is_phish, SETTINGS$email_phish_cut)
  out$dprime <- sdt$dprime; out$c_bias <- sdt$c_bias
  out[SETTINGS$primary_nodes]
}
scr <- readRDS(file.path(PATHS$clean, "knust_screened.rds"))
uns <- readRDS(file.path(PATHS$clean, "knust_unscreened.rds"))
pub <- readRDS(file.path(PATHS$clean, "public.rds"))
nodes_s <- make_nodes(scr); nodes_u <- make_nodes(uns)
saveRDS(nodes_s, file.path(PATHS$clean, "nodes_screened.rds"))
saveRDS(nodes_u, file.path(PATHS$clean, "nodes_unscreened.rds"))

alpha_of <- function(df) round(suppressWarnings(psych::alpha(df, check.keys = FALSE))$total$raw_alpha, 2)
rel <- data.frame(scale = c("Social media engagement (11)", "Security disengagement (4)", "Risky practice (8)", SETTINGS$facets),
  alpha_knust = c(alpha_of(scr[SETTINGS$sm_items]), alpha_of(scr[SETTINGS$sd_items]), alpha_of(scr[SETTINGS$rp_items]),
                  sapply(SETTINGS$facets, function(f) alpha_of(scr[paste0(f, 1:4)]))),
  alpha_public = c(alpha_of(pub[SETTINGS$sm_items]), alpha_of(pub[SETTINGS$sd_items]), alpha_of(pub[SETTINGS$rp_items]), rep(NA, 5)))
write.csv(rel, file.path(PATHS$tables, paste0(TAG, "reliability.csv")), row.names = FALSE)

desc <- data.frame(node = names(nodes_s), M = round(colMeans(nodes_s), 2), SD = round(apply(nodes_s, 2, sd), 2), N = nrow(nodes_s))
write.csv(desc, file.path(PATHS$tables, paste0(TAG, "descriptives_knust.csv")), row.names = FALSE)
write.csv(round(cor(nodes_s), 2), file.path(PATHS$tables, paste0(TAG, "correlations_knust.csv")))
write.csv(round(cor(pub), 2), file.path(PATHS$tables, paste0(TAG, "correlations_public.csv")))

gb <- suppressMessages(goldbricker(nodes_s, p = 0.05, method = "hittner2003", threshold = 0.25, corMin = 0.5, progressbar = FALSE))
red <- if (length(gb$suggested_reductions) == 0) data.frame(pair = "none", share_different = NA) else
  data.frame(pair = names(gb$suggested_reductions), share_different = round(as.numeric(gb$suggested_reductions), 2))
write.csv(red, file.path(PATHS$tables, paste0(TAG, "redundancy.csv")), row.names = FALSE)
msg("Redundancy check: ", nrow(red[red$pair != "none", , drop = FALSE]), " candidate pair(s). Read redundancy.csv before centrality.")
msg("Measurement done. Next: Rscript 04_analysis/05_structural.R")
