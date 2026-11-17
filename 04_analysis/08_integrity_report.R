# 08_integrity_report.R -------------------------------------------------------
# Command:  Rscript 04_analysis/08_integrity_report.R
# Outputs:  05_results/tables/integrity_report.csv, integrity_by_day.csv
# One table for the supervisor. It makes fabrication and careless collection
# visible: submissions per day and hour, completion times, exact and near
# duplicates, straight-lining, attention failures, and correlations that look
# too clean. Run it after every collection day.
# -----------------------------------------------------------------------------
source("04_analysis/settings.R")
dat <- readRDS(file.path(PATHS$clean, "knust_unscreened.rds"))
items <- SETTINGS$shared_items
t0 <- as.POSIXct(dat$start_time, tz = "UTC")

by_day <- as.data.frame(table(day = format(t0, "%Y-%m-%d")))
by_hour <- table(format(t0, "%H"))
m <- as.matrix(dat[items])
d <- as.matrix(dist(m, method = "manhattan"))
diag(d) <- NA
near_dup <- sum(apply(d, 1, function(r) any(r <= 2, na.rm = TRUE)))
r <- cor(m); offd <- abs(r[upper.tri(r)])

rep <- data.frame(check = c(
    "Responses (after consent)", "Busiest day (share of all responses)", "Busiest hour (share)",
    "Median completion time (minutes)", "Faster than the speed cut-off",
    "Exact duplicate answer patterns", "Near duplicates (differ on 2 points or fewer)",
    "Long strings at or above the limit", "Attention check failures",
    "Item correlations above 0.90"),
  value = c(nrow(dat), sprintf("%.0f%%", 100 * max(by_day$Freq) / nrow(dat)),
            sprintf("%.0f%%", 100 * max(by_hour) / nrow(dat)),
            round(median(dat$minutes, na.rm = TRUE), 1), sum(dat$flag_speed, na.rm = TRUE),
            sum(dat$flag_duplicate), near_dup, sum(dat$flag_longstring, na.rm = TRUE),
            sum(dat$flag_attention), sum(offd > .90)),
  look_closer_if = c("", "above 30%", "above 20%", "far below the pilot median", "more than a few",
                     "any", "more than a few", "more than a few", "more than a few", "any"))
write.csv(rep, file.path(PATHS$tables, paste0(TAG, "integrity_report.csv")), row.names = FALSE)
write.csv(by_day, file.path(PATHS$tables, paste0(TAG, "integrity_by_day.csv")), row.names = FALSE)
print(rep, row.names = FALSE)
msg("Integrity report written. Next (expert panel): Rscript 04_analysis/09_cvi.R")
