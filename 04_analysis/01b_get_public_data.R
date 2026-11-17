# 01b_get_public_data.R -------------------------------------------------------
# Command:  Rscript 04_analysis/01b_get_public_data.R
# The public Ghana dataset (Appau et al., 2026, CC BY 4.0) is fetched by you and
# never committed. Download it in a browser:
#   https://data.mendeley.com/datasets/38wdwdd5ww/1  ->  "Download All"
# Unzip it into 03_data/raw/public_ghana/ . Then run this script. It finds the
# data file, records its checksum and checks the 23 item columns against the
# codebook. If the column names differ, write the public names into the
# public_name column of 03_data/codebook.csv and save the file as
# 03_data/raw/public_ghana/public_ghana.csv.
# -----------------------------------------------------------------------------
source("04_analysis/settings.R")
dir <- "03_data/raw/public_ghana"
dir.create(dir, showWarnings = FALSE, recursive = TRUE)
files <- list.files(dir, pattern = "\\.(csv|xlsx|sav)$", full.names = TRUE, recursive = TRUE)
if (length(files) == 0) stop("No data file in ", dir, ". Download the dataset first (see the header of this script).")
sums <- data.frame(file = files, md5 = unname(tools::md5sum(files)), checked_on = format(Sys.Date()))
write.csv(sums, file.path(dir, "CHECKSUMS.csv"), row.names = FALSE)
cat("Files found and checksums recorded:\n"); print(sums, row.names = FALSE)
csvs <- files[grepl("\\.csv$", files)]
if (length(csvs) > 0) {
  hdr <- names(read.csv(csvs[1], nrows = 1, check.names = FALSE))
  cb <- read.csv(PATHS$codebook, stringsAsFactors = FALSE)
  want <- cb$public_name[cb$block == "shared23"]
  cat("\nCodebook names not found in", basename(csvs[1]), ":\n")
  print(setdiff(want, hdr))
  cat("\nIf names are missing, map them in codebook.csv (column public_name). Check item wording and the 5-point format in the dataset codebook.\n")
} else {
  cat("No CSV found. Export the data file to CSV first (for example from Excel or SPSS).\n")
}
