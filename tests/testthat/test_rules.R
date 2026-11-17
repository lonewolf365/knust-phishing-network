# Tests for the rules the analysis depends on. Run: Rscript tests/run_tests.R
source(file.path("..", "..", "04_analysis", "functions.R"), chdir = FALSE)

test_that("consent rule drops rows without all five boxes", {
  df <- data.frame(consent1 = c("Yes", "Yes"), consent2 = c("Yes", "Yes"), consent3 = c("Yes", "No"),
                   consent4 = c("Yes", "Yes"), consent5 = c("Yes", "Yes"), x = 1:2)
  out <- apply_consent(df, paste0("consent", 1:5))
  expect_equal(nrow(out), 1)
  expect_equal(attr(out, "n_dropped_consent"), 1)
})
test_that("consent rule refuses a partial set of consent columns", {
  df <- data.frame(consent1 = "Yes", consent2 = "Yes", x = 1)
  expect_error(apply_consent(df, paste0("consent", 1:5)), "Consent columns missing")
})
test_that("missing consent answers count as not ticked", {
  df <- data.frame(consent1 = NA, consent2 = "Yes", consent3 = "Yes", consent4 = "Yes", consent5 = "Yes")
  expect_equal(nrow(apply_consent(df, paste0("consent", 1:5))), 0)
})
test_that("reverse coding flips only flagged items", {
  cb <- data.frame(item = c("a", "b"), reverse = c(TRUE, FALSE), scale_min = 1, scale_max = 4)
  out <- reverse_code(data.frame(a = c(1, 4), b = c(1, 4)), cb)
  expect_equal(out$a, c(4, 1)); expect_equal(out$b, c(1, 4))
})
test_that("long string finds the longest run", {
  df <- data.frame(i1 = c(3, 1), i2 = c(3, 2), i3 = c(3, 2), i4 = c(1, 2))
  expect_equal(longstring(df, c("i1", "i2", "i3", "i4")), c(3, 3))
})
test_that("speed flag uses the pilot median", {
  expect_equal(flag_speed(c(3, 10), pilot_median = 12, fraction = 1/3), c(TRUE, FALSE))
})
test_that("attention check needs the keyed answer", {
  df <- data.frame(ATT1 = c(2, 5), ATT2 = c(4, 4))
  expect_equal(pass_attention(df, c(ATT1 = 2, ATT2 = 4)), c(TRUE, FALSE))
})
test_that("d-prime with the log-linear correction matches the hand value", {
  r <- matrix(c(rep(6, 8), rep(1, 8)), nrow = 1)          # all hits, no false alarms
  s <- sdt_scores(r, is_phish = rep(c(TRUE, FALSE), each = 8), cut = 4)
  expect_equal(round(s$dprime, 2), round(qnorm(8.5 / 9) - qnorm(0.5 / 9), 2))
  expect_equal(round(s$c_bias, 6), 0)
})
test_that("I-CVI is the share of 3s and 4s", {
  expect_equal(unname(icvi(matrix(c(4, 3, 2, 1, 4, 4), ncol = 2))), c(2/3, 2/3))
})
test_that("Fleiss kappa is 1 under perfect agreement", {
  m <- matrix(rep(c("phishing", "genuine"), each = 3), nrow = 2, byrow = TRUE)
  expect_equal(fleiss_kappa(m), 1)
})
