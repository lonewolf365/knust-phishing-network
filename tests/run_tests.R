# Command (from the project folder):  Rscript tests/run_tests.R
library(testthat)
res <- test_dir("tests/testthat", reporter = "summary", stop_on_failure = TRUE)
