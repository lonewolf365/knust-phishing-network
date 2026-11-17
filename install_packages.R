# install_packages.R ----------------------------------------------------------
# Command:  Rscript install_packages.R
# Installs the packages from CRAN. Option A (simple): this script.
# Option B (exact versions): install.packages("renv"); renv::restore()
# -----------------------------------------------------------------------------
pkgs <- c("qgraph", "bootnet", "networktools", "NetworkComparisonTest", "mgm", "psych", "testthat", "renv")
missing <- pkgs[!vapply(pkgs, requireNamespace, logical(1), quietly = TRUE)]
if (length(missing) > 0) install.packages(missing, repos = "https://cloud.r-project.org")
cat("Installed. Next: Rscript 04_analysis/00_check_env.R\n")
