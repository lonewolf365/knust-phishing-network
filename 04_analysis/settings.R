# settings.R ------------------------------------------------------------------
# Every analysis choice lives here. Change a value here, never inside a script.
# Run mode: "demo" uses REHEARSAL data simulated for practice. "real" uses your
# survey export. Set it before running, for example:
#   Sys.setenv(RUN_MODE = "real")
# -----------------------------------------------------------------------------

RUN_MODE <- Sys.getenv("RUN_MODE", unset = "demo")
stopifnot(RUN_MODE %in% c("demo", "real"))
IS_DEMO <- RUN_MODE == "demo"

SETTINGS <- list(
  seed = 2026,                       # ASSUMPTION: any fixed number, never changed later

  # Network estimation (baseline: Cho & Kim, 2025, p. 3)
  gamma = 0.5,                       # EBIC hyperparameter, as in the baseline
  cor_primary = "cor_auto",          # polychoric for ordinal items (primary)
  cor_sensitivity = "cor",           # Pearson (sensitivity check)

  # Resampling. Real runs use the full numbers. Demo runs use small numbers so
  # the whole demo finishes in a few minutes on a laptop.
  n_boot_edges = if (IS_DEMO) 100 else 2500,   # baseline: 2,500 [p. 3]
  n_boot_case  = if (IS_DEMO) 100 else 1000,   # ASSUMPTION: bootnet default
  nct_perm     = if (IS_DEMO) 100 else 1000,   # ASSUMPTION
  cs_cor = 0.7,                                # CS rule [p. 3]
  n_cores = 1,

  # Screening rules: fixed BEFORE collection (show results with and without)
  consent_cols = paste0("consent", 1:5),
  attention_keys = c(ATT1 = 2, ATT2 = 4),      # CHECK: keys of the final instrument
  pilot_median_minutes = 13,                    # ASSUMPTION until the pilot
  speed_fraction = 1 / 3,                       # faster than 1/3 of the pilot median
  longstring_max = 15,                          # ASSUMPTION: 15+ identical answers in a row

  # Email-judgment scoring (signal detection)
  email_phish_cut = 4,               # ratings 4 to 6 count as "phishing"
  email_scale = c(1, 6),

  # Expert panel (content validity)
  icvi_cut = 0.78,                   # convention for 6+ experts (Lynn, 1986)
  label_agree_min = 5,               # keep an email if 5+ experts agree on its label

  # Communities for bridge centrality: fixed a priori (Part 3 of the plan)
  facets = c("NU", "PU", "PR", "PE", "SS"),
  sm_items = paste0("SM", 1:11),
  sd_items = paste0("SD", 1:4),
  rp_items = paste0("RP", 1:8),
  judgment = c("dprime", "c_bias")
)
SETTINGS$shared_items <- c(SETTINGS$sm_items, SETTINGS$sd_items, SETTINGS$rp_items)
SETTINGS$primary_nodes <- c(SETTINGS$facets, SETTINGS$shared_items, SETTINGS$judgment)
SETTINGS$communities <- c(rep("Impulsivity", 5), rep("SocialMedia", 11),
                          rep("Disengagement", 4), rep("RiskyPractice", 8),
                          rep("Judgment", 2))

# File locations -------------------------------------------------------------
PATHS <- list(
  codebook   = "03_data/codebook.csv",
  email_key  = "02_instrument/email_answer_key.csv",
  export     = if (IS_DEMO) "03_data/rehearsal/REHEARSAL_knust_export.csv" else "03_data/raw/knust_export.csv",
  public     = if (IS_DEMO) "03_data/rehearsal/REHEARSAL_public_ghana.csv" else "03_data/raw/public_ghana/public_ghana.csv",
  experts    = if (IS_DEMO) "03_data/rehearsal/REHEARSAL_expert_ratings.csv" else "03_data/raw/expert_ratings.csv",
  clean      = "03_data/clean",
  tables     = "05_results/tables",
  figures    = "05_results/figures"
)
for (p in c(PATHS$clean, PATHS$tables, PATHS$figures)) dir.create(p, showWarnings = FALSE, recursive = TRUE)

# Labels: every demo output carries this mark (rule: demo numbers are never findings)
TAG <- if (IS_DEMO) "REHEARSAL_" else ""
WATERMARK <- if (IS_DEMO) "SYNTHETIC DEMO DATA - not a result" else ""
OLIVE <- "#556B2F"

set.seed(SETTINGS$seed)
msg <- function(...) cat("[", format(Sys.time(), "%H:%M:%S"), "] ", ..., "\n", sep = "")
