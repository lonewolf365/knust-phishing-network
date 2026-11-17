# 06_options.R ----------------------------------------------------------------
# Command:  Rscript 04_analysis/06_options.R
# Output:   05_results/tables/nct_two_samples.csv, nct_edges.csv
# Analysis Option 1: network comparison test (NCT) on the shared 23-node
# network, public Ghana sample against the new KNUST sample. It tests global
# strength (S), the largest edge difference (M) and each edge (Holm).
# Analysis Option 2 (Bayesian network) runs only with supervisor approval and
# is not part of this starter.
# -----------------------------------------------------------------------------
source("04_analysis/settings.R")
suppressPackageStartupMessages(library(NetworkComparisonTest))
pub <- readRDS(file.path(PATHS$clean, "public.rds"))
knust <- readRDS(file.path(PATHS$clean, "knust_screened.rds"))[SETTINGS$shared_items]
msg("NCT with ", SETTINGS$nct_perm, " permutations: public n = ", nrow(pub), ", KNUST n = ", nrow(knust))
nct <- suppressMessages(suppressWarnings(NCT(pub, knust, it = SETTINGS$nct_perm, gamma = SETTINGS$gamma,
                                            test.edges = TRUE, edges = "all", p.adjust.methods = "holm",
                                            progressbar = FALSE)))
res <- data.frame(test = c("Global strength difference (S)", "Largest edge difference (M)"),
                  statistic = round(c(nct$glstrinv.real, nct$nwinv.real), 3),
                  p_value = round(c(nct$glstrinv.pval, nct$nwinv.pval), 3))
write.csv(res, file.path(PATHS$tables, paste0(TAG, "nct_two_samples.csv")), row.names = FALSE)
ed <- nct$einv.pvals
names(ed)[names(ed) == "p-value"] <- "p_holm"
names(ed)[names(ed) == "Test statistic E"] <- "edge_difference"
write.csv(ed, file.path(PATHS$tables, paste0(TAG, "nct_edges.csv")), row.names = FALSE)
print(res, row.names = FALSE)
msg(sum(ed$p_holm < .05), " edge(s) differ after Holm correction. A non-significant test is not proof that the networks are identical.")
msg("Option done. Next: Rscript 04_analysis/07_figures.R")
