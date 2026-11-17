# 03_screening.R --------------------------------------------------------------
# Command:  Rscript 04_analysis/03_screening.R
# Outputs:  03_data/clean/knust_screened.rds, 03_data/clean/knust_unscreened.rds
#           05_results/tables/screening_summary.csv
# Applies the screening rules fixed in settings.R BEFORE collection:
# attention checks, speed, long strings and duplicates. Both versions are kept,
# because the paper reports results with and without screening.
# -----------------------------------------------------------------------------
source("04_analysis/settings.R")
source("04_analysis/functions.R")
dat <- readRDS(file.path(PATHS$clean, "knust_consented.rds"))
items <- c(SETTINGS$shared_items, paste0(rep(SETTINGS$facets, each = 4), 1:4))

dat$flag_attention <- !pass_attention(dat, SETTINGS$attention_keys)
dat$flag_speed     <- flag_speed(dat$minutes, SETTINGS$pilot_median_minutes, SETTINGS$speed_fraction)
dat$longstring     <- longstring(dat, SETTINGS$shared_items)
dat$flag_longstring <- dat$longstring >= SETTINGS$longstring_max
answer_cols <- c(items, grep("^EM", names(dat), value = TRUE))
dat$flag_duplicate <- duplicated(dat[answer_cols])
dat$flag_any <- with(dat, flag_attention | flag_speed | flag_longstring | flag_duplicate)

summ <- data.frame(rule = c("attention check failed", "faster than the speed cut-off",
                            "long string at or above the limit", "duplicate answer pattern",
                            "any rule (removed)", "kept after screening"),
                   n = c(sum(dat$flag_attention), sum(dat$flag_speed, na.rm = TRUE), sum(dat$flag_longstring, na.rm = TRUE),
                         sum(dat$flag_duplicate), sum(dat$flag_any, na.rm = TRUE), sum(!dat$flag_any, na.rm = TRUE)))
write.csv(summ, file.path(PATHS$tables, paste0(TAG, "screening_summary.csv")), row.names = FALSE)
print(summ, row.names = FALSE)
saveRDS(dat, file.path(PATHS$clean, "knust_unscreened.rds"))
saveRDS(dat[!dat$flag_any %in% TRUE, ], file.path(PATHS$clean, "knust_screened.rds"))
msg("Screening done. Next: Rscript 04_analysis/04_measurement.R")
