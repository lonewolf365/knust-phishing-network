# 09_cvi.R --------------------------------------------------------------------
# Command:  Rscript 04_analysis/09_cvi.R
# Input:    expert ratings (long format: expert, target, relevance 1-4, label)
# Outputs:  05_results/tables/cvi_items.csv, cvi_summary.csv, email_label_agreement.csv
# Expert panel (route IR1). I-CVI is the share of experts rating 3 or 4.
# Keep an item at I-CVI .78 or more with 6+ experts (convention). S-CVI/Ave is
# the mean I-CVI. An email stays only if enough experts agree on its label.
# -----------------------------------------------------------------------------
source("04_analysis/settings.R")
source("04_analysis/functions.R")
ex <- read.csv(PATHS$experts, stringsAsFactors = FALSE)
key <- read.csv(PATHS$email_key)
wide <- reshape(ex[c("expert", "target", "relevance")], idvar = "expert", timevar = "target", direction = "wide")
rel <- as.matrix(wide[, -1]); colnames(rel) <- sub("^relevance\\.", "", colnames(rel))
iv <- icvi(rel)
items <- data.frame(target = names(iv), I_CVI = round(iv, 2), n_experts = nrow(rel),
                    decision = ifelse(iv >= SETTINGS$icvi_cut, "keep", "revise or drop"))
write.csv(items, file.path(PATHS$tables, paste0(TAG, "cvi_items.csv")), row.names = FALSE)

em <- ex[ex$target %in% key$email, ]
truth <- setNames(key$label, key$email)
agree <- do.call(rbind, lapply(split(em, em$target), function(s)
  data.frame(email = s$target[1], intended = truth[s$target[1]], experts_agreeing = sum(s$label == truth[s$target[1]]),
             keep = sum(s$label == truth[s$target[1]]) >= SETTINGS$label_agree_min)))
write.csv(agree, file.path(PATHS$tables, paste0(TAG, "email_label_agreement.csv")), row.names = FALSE)

lab_wide <- reshape(em[c("expert", "target", "label")], idvar = "target", timevar = "expert", direction = "wide")
kappa <- fleiss_kappa(as.matrix(lab_wide[, -1]))
summ <- data.frame(measure = c("Experts", "S-CVI/Ave", "Items below the I-CVI cut", "Emails kept", "Fleiss kappa (email labels)"),
                   value = c(nrow(rel), round(mean(iv), 2), sum(iv < SETTINGS$icvi_cut), sum(agree$keep), round(kappa, 2)))
write.csv(summ, file.path(PATHS$tables, paste0(TAG, "cvi_summary.csv")), row.names = FALSE)
print(summ, row.names = FALSE)
msg("Content validity done.")
