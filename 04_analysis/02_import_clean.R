# 02_import_clean.R -----------------------------------------------------------
# Command:  Rscript 04_analysis/02_import_clean.R
# Inputs:   the survey export (KoboToolbox or Google Forms CSV), codebook.csv
# Outputs:  03_data/clean/knust_consented.rds, 03_data/clean/public.rds
#           05_results/tables/import_log.csv
# Rule 0 comes first: rows without all five consent boxes are dropped, and an
# export without the full set of consent columns is refused. Then reverse
# coding. Raw files are never edited by hand.
# -----------------------------------------------------------------------------
source("04_analysis/settings.R")
source("04_analysis/functions.R")

cb <- read.csv(PATHS$codebook, stringsAsFactors = FALSE)
cb$reverse <- as.logical(cb$reverse)
if (!file.exists(PATHS$export)) stop("Export not found: ", PATHS$export,
  ". In real mode, save your survey export there. See Appendix A, section A9.")
raw <- read.csv(PATHS$export, stringsAsFactors = FALSE, check.names = FALSE)
n_raw <- nrow(raw)

# 1. Consent rule (rule 0)
dat <- apply_consent(raw, SETTINGS$consent_cols)
n_consent_drop <- attr(dat, "n_dropped_consent")

# 2. Every codebook item must exist in the export
needed <- cb$item[cb$block %in% c("shared23", "supps", "email", "attention", "meta")]
miss <- setdiff(needed, names(dat))
if (length(miss) > 0) stop("Columns missing from the export: ", paste(miss, collapse = ", "),
                           ". Rename them to the codebook names in your survey tool.")

# 3. Numeric items within range
num_items <- cb$item[cb$block %in% c("shared23", "supps", "email", "attention")]
for (it in num_items) {
  dat[[it]] <- suppressWarnings(as.numeric(dat[[it]]))
  rng <- cb[cb$item == it, c("scale_min", "scale_max")]
  bad <- !is.na(dat[[it]]) & (dat[[it]] < rng$scale_min | dat[[it]] > rng$scale_max)
  if (any(bad)) stop("Out-of-range values in ", it, ". Check the export settings.")
}

# 4. Reverse coding (short UPPS-P: higher = more impulsive after recoding)
dat <- reverse_code(dat, cb)
dat$minutes <- as.numeric(difftime(as.POSIXct(dat$end_time, tz = "UTC"),
                                   as.POSIXct(dat$start_time, tz = "UTC"), units = "mins"))
dat$row_id <- seq_len(nrow(dat))
saveRDS(dat, file.path(PATHS$clean, "knust_consented.rds"))

# Public comparison sample: same 23 items (map names via codebook$public_name)
pub <- read.csv(PATHS$public, stringsAsFactors = FALSE)
map <- cb[cb$block == "shared23", c("item", "public_name")]
pub <- pub[, map$public_name]; names(pub) <- map$item
saveRDS(pub, file.path(PATHS$clean, "public.rds"))

log <- data.frame(step = c("rows in export", "dropped: consent incomplete", "kept after consent", "public sample rows"),
                  n = c(n_raw, n_consent_drop, nrow(dat), nrow(pub)))
write.csv(log, file.path(PATHS$tables, paste0(TAG, "import_log.csv")), row.names = FALSE)
print(log, row.names = FALSE)
msg("Import done. Next: Rscript 04_analysis/03_screening.R")
