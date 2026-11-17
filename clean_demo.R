# clean_demo.R ----------------------------------------------------------------
# Command (from the project folder):  Rscript clean_demo.R
# Deletes every demo (REHEARSAL) output and the rehearsal data, so nothing from
# the demo can mix with your real results. Run it before your first real run.
# -----------------------------------------------------------------------------
demo_out <- list.files("05_results", pattern = "^REHEARSAL_", recursive = TRUE, full.names = TRUE)
demo_dat <- list.files("03_data/rehearsal", pattern = "\\.csv$", full.names = TRUE)
clean_rds <- list.files("03_data/clean", pattern = "\\.rds$", full.names = TRUE)
unlink(c(demo_out, demo_dat, clean_rds))
cat("Deleted", length(demo_out), "demo outputs,", length(demo_dat), "rehearsal data files and",
    length(clean_rds), "intermediate files.\n")
cat("Next: set RUN_MODE to \"real\" (Appendix A, section A10).\n")
