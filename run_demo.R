# run_demo.R ------------------------------------------------------------------
# Command (from the project folder):  Rscript run_demo.R
# Runs the whole study on REHEARSAL data, step by step, and reports the time.
# Every demo table and figure is named REHEARSAL_ and is never a finding.
# Delete the demo outputs before your real run (Appendix A, section A10).
# -----------------------------------------------------------------------------
Sys.setenv(RUN_MODE = "demo")
steps <- c("00_check_env.R", "01_rehearsal_data.R", "02_import_clean.R", "03_screening.R",
           "04_measurement.R", "05_structural.R", "06_options.R", "07_figures.R",
           "08_integrity_report.R", "09_cvi.R")
t_start <- Sys.time()
for (s in steps) {
  cat("\n==================== ", s, " ====================\n", sep = "")
  t1 <- Sys.time()
  source(file.path("04_analysis", s), local = new.env(), echo = FALSE)
  cat(sprintf("-- %s finished in %.1f seconds\n", s, as.numeric(difftime(Sys.time(), t1, units = "secs"))))
}
total <- as.numeric(difftime(Sys.time(), t_start, units = "mins"))
cat(sprintf("\nDEMO COMPLETE in %.1f minutes. Open 05_results/tables and 05_results/figures.\n", total))
cat("Remember: these are SYNTHETIC DEMO DATA, not results.\n")
