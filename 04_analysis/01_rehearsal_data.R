# 01_rehearsal_data.R ---------------------------------------------------------
# Command:  Rscript 04_analysis/01_rehearsal_data.R
# Outputs:  05_results/tables/T2_rebuild_edges.csv          (rebuild of Table 2)
#           05_results/tables/T2_rebuild_vs_reported.csv     (replication log)
#           05_results/tables/T3_rebuild_centrality.csv      (rebuild of Table 3)
#           03_data/rehearsal/REHEARSAL_*.csv                (practice data, demo only)
#
# Part A rebuilds the baseline network from the published correlation matrix
# (Cho & Kim, 2025, Table 1, N = 687). It needs no raw data and is the first
# result of Supporting Objective A.
# Part B (demo mode only) simulates REHEARSAL data with the structure of your
# survey so every later script can run before real data exist. Rehearsal data
# are for pipeline testing only. They are never reported as findings.
# -----------------------------------------------------------------------------
source("04_analysis/settings.R")
source("04_analysis/functions.R")
suppressPackageStartupMessages({ library(qgraph); library(networktools); library(MASS) })

# ---- Part A: rebuild the baseline from Table 1 -------------------------------
nodes <- c(paste0("SAS", 1:6), paste0("UPPS", 1:5), paste0("DERS", 1:5))
low <- c(.63, .53,.60, .69,.56,.57, .74,.60,.56,.62, .70,.57,.58,.63,.77,
 .41,.33,.29,.41,.38,.37, .39,.24,.16,.34,.34,.34,.84,
 .34,.09,.05,.17,.28,.28,.41,.41, .34,.25,.26,.29,.38,.37,.45,.37,.63,
 -.03,-.02,-.03,-.01,.03,.07,.24,.35,.04,-.14,
 .45,.31,.20,.38,.42,.38,.59,.57,.48,.45,.07,
 .41,.28,.14,.30,.36,.35,.44,.44,.37,.36,.03,.77,
 .45,.26,.15,.32,.36,.33,.47,.47,.44,.42,.00,.84,.76,
 .39,.36,.29,.37,.40,.34,.46,.40,.27,.37,-.02,.73,.61,.70,
 .38,.17,.11,.22,.30,.31,.51,.53,.48,.47,.11,.57,.52,.55,.37)   # Table 1, row by row
stopifnot(length(low) == 120)
R <- diag(16); k <- 0
for (i in 2:16) for (j in 1:(i - 1)) { k <- k + 1; R[i, j] <- R[j, i] <- low[k] }
dimnames(R) <- list(nodes, nodes)
comm_base <- rep(c("SAS", "UPPS", "DERS"), c(6, 5, 5))

net <- suppressWarnings(EBICglasso(R, n = 687, gamma = SETTINGS$gamma))
n_edges <- sum(net[upper.tri(net)] != 0)
msg("Baseline rebuild: ", n_edges, " non-zero edges (paper reports 83 of 120).")
write.csv(round(net, 3), file.path(PATHS$tables, "T2_rebuild_edges.csv"))

# Reported Table 2 (lower triangle, row by row) for the replication log
rep_low <- c(.21, .00,.29, .29,.07,.19, .28,.11,.10,.04, .16,.05,.17,.15,.41,
 .00,.03,.08,.07,.00,.00, .02,.00,-.07,.02,.00,.00,.68,
 .09,-.09,-.09,-.03,.00,.03,.00,.05, .00,.00,.08,.00,.05,.04,.11,.00,.47,
 -.05,-.01,.00,-.03,.00,.06,.00,.27,.03,-.21,
 .00,.00,.00,.01,.02,.00,.09,.06,.11,.00,.00,
 .01,.01,-.04,.00,.01,.02,.00,.00,.00,.00,.00,.29,
 .06,.00,-.06,.00,.00,.00,.00,.00,.04,.00,-.03,.42,.28,
 .00,.07,.05,.03,.02,.00,.02,.00,-.09,.05,-.03,.29,.05,.23,
 .07,-.02,-.03,-.03,.00,.01,.01,.16,.12,.13,.01,.08,.10,.08,-.03)
idx <- which(lower.tri(R), arr.ind = TRUE); idx <- idx[order(idx[, 1], idx[, 2]), ]
log_tab <- data.frame(node_a = nodes[idx[, 1]], node_b = nodes[idx[, 2]],
                      reported = rep_low, rebuilt = round(net[idx], 3))
log_tab$abs_diff <- round(abs(log_tab$reported - log_tab$rebuilt), 3)
write.csv(log_tab, file.path(PATHS$tables, "T2_rebuild_vs_reported.csv"), row.names = FALSE)
msg("Edge agreement with Table 2: r = ", round(cor(log_tab$reported, log_tab$rebuilt), 3),
    ", largest gap = ", max(log_tab$abs_diff))

z <- function(x) round(as.numeric(scale(x)), 2)
ei <- centrality(net)$InExpectedInfluence
br <- bridge(net, communities = comm_base)
t3 <- data.frame(node = nodes,
  EI_rebuilt = z(ei), EI_reported = c(.93,-.39,-.52,-.20,.61,.77,.74,1.08,-.68,-.40,-2.57,1.63,-.30,.51,-.62,-.59),
  BEI1_rebuilt = z(br$`Bridge Expected Influence (1-step)`),
  BEI1_reported = c(.44,-.96,-1.32,-.67,-.22,.18,1.11,.41,-.33,1.44,-1.38,1.10,-.73,-.85,-.13,1.91),
  BEI2_rebuilt = z(br$`Bridge Expected Influence (2-step)`),
  BEI2_reported = c(.49,-1.10,-1.68,-.56,-.13,-.12,1.42,.57,.09,1.14,-1.76,.99,-.49,-.36,-.03,1.52))
write.csv(t3, file.path(PATHS$tables, "T3_rebuild_centrality.csv"), row.names = FALSE)
msg("Centrality agreement: EI r = ", round(cor(t3$EI_rebuilt, t3$EI_reported), 3),
    ", BEI(1) r = ", round(cor(t3$BEI1_rebuilt, t3$BEI1_reported), 3),
    ", BEI(2) r = ", round(cor(t3$BEI2_rebuilt, t3$BEI2_reported), 3))
saveRDS(list(R = R, net = net, comm = comm_base), file.path(PATHS$clean, "baseline_rebuild.rds"))

if (IS_DEMO) {

# ---- Part B: REHEARSAL data with the structure of your survey ----------------
# Latent structure. The impulsivity block uses the baseline's reported UPPS-P
# correlations (Table 1). Every other value is an ASSUMPTION for practice only.
lat <- c("NU", "PU", "PR", "PE", "SS", "SM", "SD", "RP", "SKILL", "BIAS")
L <- diag(10); dimnames(L) <- list(lat, lat)
L[1:5, 1:5] <- R[7:11, 7:11]
set_r <- function(a, b, v) { L[a, b] <<- v; L[b, a] <<- v }
set_r("SM","SD",.25); set_r("SM","RP",.30); set_r("SD","RP",.45)
set_r("NU","RP",.25); set_r("PU","RP",.20); set_r("PR","RP",.20); set_r("PE","RP",.20); set_r("SS","RP",.05)
set_r("NU","SM",.25); set_r("PU","SM",.20); set_r("PE","SD",.20)
set_r("SKILL","RP",-.30); set_r("SKILL","SD",-.25); set_r("SKILL","NU",-.20); set_r("BIAS","SM",.20); set_r("BIAS","RP",.15)
L <- make_pd(L)

simulate_people <- function(n) {
  F <- mvrnorm(n, rep(0, 10), L); colnames(F) <- lat
  likert <- function(f, pts, loading = .7) {
    x <- loading * f + rnorm(length(f), 0, sqrt(1 - loading^2))
    cut(x, breaks = c(-Inf, qnorm(seq_len(pts - 1) / pts) + rnorm(1, 0, .2), Inf), labels = FALSE)
  }
  out <- data.frame(row.names = seq_len(n))
  for (i in 1:11) out[[paste0("SM", i)]] <- likert(F[, "SM"], 5)
  for (i in 1:4)  out[[paste0("SD", i)]] <- likert(F[, "SD"], 5)
  for (i in 1:8)  out[[paste0("RP", i)]] <- likert(F[, "RP"], 5)
  list(items = out, F = F)
}

# New KNUST sample (raw export as the survey tool would give it)
n_new <- 520
sim <- simulate_people(n_new); dat <- sim$items; F <- sim$F
for (f in SETTINGS$facets) for (i in 1:4) {
  x <- .7 * F[, f] + rnorm(n_new, 0, sqrt(1 - .49))
  # Source scale: 1 = strongly agree ... 4 = strongly disagree, so high impulsivity -> low raw score
  dat[[paste0(f, i)]] <- 5 - cut(x, c(-Inf, -0.8, 0, 0.8, Inf), labels = FALSE)
}
key <- read.csv(PATHS$email_key)
is_phish <- key$label == "phishing"
dp <- 1.2 + 0.8 * F[, "SKILL"]; cb <- 0.5 * F[, "BIAS"]
for (e in seq_len(nrow(key))) {
  ev <- ifelse(is_phish[e], dp / 2, -dp / 2) + rnorm(n_new)
  dat[[key$email[e]]] <- cut(ev - cb, c(-Inf, -1.5, -0.75, 0, 0.75, 1.5, Inf), labels = FALSE)
}
dat$ATT1 <- 2; dat$ATT2 <- 4
for (i in 1:5) dat[[paste0("consent", i)]] <- "Yes"
dat$BG_gender <- sample(1:2, n_new, TRUE); dat$BG_age <- sample(1:3, n_new, TRUE)
dat$BG_level <- sample(1:4, n_new, TRUE); dat$BG_college <- sample(1:6, n_new, TRUE)
dat$BG_phone <- sample(1:2, n_new, TRUE, prob = c(.85, .15)); dat$BG_kmail <- sample(1:2, n_new, TRUE, prob = c(.8, .2))
start <- as.POSIXct("2027-01-11 08:00", tz = "UTC") + runif(n_new, 0, 21 * 86400)
mins <- rlnorm(n_new, log(SETTINGS$pilot_median_minutes), .3)

# Plant problems that the screening and integrity scripts must catch
bad <- sample(n_new, 40)
dat[bad[1:10], "consent3"] <- "No"                                         # incomplete consent
dat[bad[11:20], SETTINGS$shared_items] <- 3                                 # straight-lining
mins[bad[21:30]] <- runif(10, 1.5, 3.5)                                     # speeders
dat[bad[31:36], "ATT1"] <- 5                                                # failed attention check
dat <- rbind(dat, dat[bad[37:40], ])                                        # exact duplicates
start <- c(start, start[bad[37:40]]); mins <- c(mins, mins[bad[37:40]])
dat$start_time <- format(start, "%Y-%m-%d %H:%M:%S")
dat$end_time <- format(start + mins * 60, "%Y-%m-%d %H:%M:%S")
dat <- dat[sample(nrow(dat)), ]
write.csv(dat, PATHS$export, row.names = FALSE)
msg("REHEARSAL KNUST export: ", nrow(dat), " rows with planted problems (", PATHS$export, ")")

# Public Ghana comparison sample (23 items only)
pub <- simulate_people(372)$items
write.csv(pub, PATHS$public, row.names = FALSE)
msg("REHEARSAL public Ghana sample: ", nrow(pub), " rows (", PATHS$public, ")")

# Expert panel: 7 experts rate 16 emails (relevance 1-4 and label) and 23 shared items
ex <- expand.grid(expert = paste0("E", 1:7), target = c(key$email, SETTINGS$shared_items), stringsAsFactors = FALSE)
ex$relevance <- sample(1:4, nrow(ex), TRUE, prob = c(.05, .10, .35, .50))
truth <- setNames(key$label, key$email)
ex$label <- ifelse(ex$target %in% key$email,
                   ifelse(runif(nrow(ex)) < .88, truth[ex$target], ifelse(truth[ex$target] == "phishing", "genuine", "phishing")), NA)
write.csv(ex, PATHS$experts, row.names = FALSE)
msg("REHEARSAL expert ratings written. Next: Rscript 04_analysis/02_import_clean.R")
} else {
  msg("Real mode: rehearsal data not created. Next: Rscript 04_analysis/02_import_clean.R")
}
