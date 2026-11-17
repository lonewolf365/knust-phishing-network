# 00_check_env.R --------------------------------------------------------------
# Command:  Rscript 04_analysis/00_check_env.R
# Output:   05_results/tables/environment.txt
# Checks R, the packages this study needs, memory and disk. Run it first.
# -----------------------------------------------------------------------------
source("04_analysis/settings.R")
need <- c("qgraph", "bootnet", "networktools", "NetworkComparisonTest", "mgm",
          "psych", "MASS", "testthat")
lines <- c(paste("R version:", R.version.string), paste("Run mode:", RUN_MODE))
missing <- character(0)
for (p in need) {
  if (requireNamespace(p, quietly = TRUE)) {
    lines <- c(lines, sprintf("  OK  %-22s %s", p, as.character(packageVersion(p))))
  } else {
    lines <- c(lines, sprintf("  MISSING  %s", p)); missing <- c(missing, p)
  }
}
mem <- tryCatch(as.numeric(system("awk '/MemTotal/ {print $2}' /proc/meminfo", intern = TRUE)) / 1024^2,
                error = function(e) NA)
if (!is.na(mem)) lines <- c(lines, sprintf("RAM: %.1f GB", mem))
writeLines(lines, file.path(PATHS$tables, "environment.txt"))
cat(lines, sep = "\n")
if (length(missing) > 0) {
  stop("Install the missing packages first: install.packages(c(\"",
       paste(missing, collapse = "\", \""), "\")). See Appendix A, section A4.")
}
msg("Environment OK. Next: Rscript 04_analysis/01_rehearsal_data.R")
