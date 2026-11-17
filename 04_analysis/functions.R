# functions.R -----------------------------------------------------------------
# Small, tested helper functions. tests/testthat/test_rules.R checks each one.
# -----------------------------------------------------------------------------

# Rule 0: consent first. Drop any row without ALL consent boxes ticked.
# Stop if the export does not hold the full set of consent columns.
apply_consent <- function(df, consent_cols) {
  missing <- setdiff(consent_cols, names(df))
  if (length(missing) > 0) {
    stop("Consent columns missing from the export: ", paste(missing, collapse = ", "),
         ". Fix the survey export. Never analyse data without the full consent record.")
  }
  ticked <- function(x) tolower(as.character(x)) %in% c("1", "yes", "true", "y")
  ok <- Reduce(`&`, lapply(df[consent_cols], ticked))
  ok[is.na(ok)] <- FALSE
  attr_dropped <- sum(!ok)
  out <- df[ok, , drop = FALSE]
  attr(out, "n_dropped_consent") <- attr_dropped
  out
}

# Reverse-code flagged items so that higher always means more of the construct.
reverse_code <- function(df, codebook) {
  rev <- codebook[codebook$reverse %in% TRUE & codebook$item %in% names(df), ]
  for (i in seq_len(nrow(rev))) {
    it <- rev$item[i]
    df[[it]] <- (rev$scale_min[i] + rev$scale_max[i]) - df[[it]]
  }
  df
}

# Longest run of identical answers across a set of items (straight-lining).
longstring <- function(df, items) {
  apply(df[items], 1, function(r) {
    r <- r[!is.na(r)]
    if (length(r) == 0) return(NA_integer_)
    max(rle(as.vector(r))$lengths)
  })
}

# Flag respondents faster than a fraction of the pilot median.
flag_speed <- function(minutes, pilot_median, fraction) minutes < fraction * pilot_median

# Attention checks: TRUE when every check has its keyed answer.
pass_attention <- function(df, keys) {
  ok <- rep(TRUE, nrow(df))
  for (k in names(keys)) ok <- ok & !is.na(df[[k]]) & df[[k]] == keys[[k]]
  ok
}

# Signal detection scores with the log-linear correction (Hautus, 1995).
# ratings: matrix (people x emails); is_phish: logical per email; cut: rating
# at or above which an email counts as judged "phishing".
sdt_scores <- function(ratings, is_phish, cut) {
  said_phish <- ratings >= cut
  n_s <- sum(is_phish); n_n <- sum(!is_phish)
  hits <- rowSums(said_phish[, is_phish, drop = FALSE], na.rm = TRUE)
  fas  <- rowSums(said_phish[, !is_phish, drop = FALSE], na.rm = TRUE)
  H <- (hits + 0.5) / (n_s + 1)
  F <- (fas + 0.5) / (n_n + 1)
  data.frame(hit_rate = hits / n_s, fa_rate = fas / n_n,
             dprime = qnorm(H) - qnorm(F),
             c_bias = -0.5 * (qnorm(H) + qnorm(F)))   # c > 0: leans toward "safe"
}

# Item-level content validity index: share of experts rating 3 or 4.
icvi <- function(ratings) colMeans(ratings >= 3, na.rm = TRUE)

# Fleiss' kappa for a subjects x raters matrix of category labels.
fleiss_kappa <- function(m) {
  cats <- sort(unique(as.vector(m[!is.na(m)])))
  n <- ncol(m)
  counts <- t(apply(m, 1, function(r) table(factor(r, levels = cats))))
  p_j <- colSums(counts) / (nrow(m) * n)
  P_i <- (rowSums(counts^2) - n) / (n * (n - 1))
  P_bar <- mean(P_i); P_e <- sum(p_j^2)
  (P_bar - P_e) / (1 - P_e)
}

# Make a correlation matrix positive definite (used only for rehearsal data).
make_pd <- function(R, eps = 1e-3) {
  e <- eigen(R, symmetric = TRUE)
  if (min(e$values) > eps) return(R)
  v <- pmax(e$values, eps)
  R2 <- e$vectors %*% diag(v) %*% t(e$vectors)
  d <- sqrt(diag(R2)); R2 <- R2 / outer(d, d)
  dimnames(R2) <- dimnames(R); R2
}
