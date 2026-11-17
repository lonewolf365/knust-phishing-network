# Impulsivity, risky cybersecurity practice and phishing-email judgment among Ghanaian undergraduates

A psychometric network study with a two-sample comparison. This repository holds every
script, setting and template the study needs. Data live in `03_data/` and are never pushed.

**Read every file in your student pack in order, from 00 to the last file, before you run anything here.**
Then follow Appendix A (file 02 of the pack). It explains each command below in full.

## Quick start (demo on rehearsal data)

```
Rscript 04_analysis/00_check_env.R      # checks R and packages
Rscript tests/run_tests.R               # checks the screening and scoring rules
Rscript run_demo.R                      # runs the whole study on REHEARSAL data
```

The demo writes tables to `05_results/tables/` and figures to `05_results/figures/`.
Every demo file starts with `REHEARSAL_`. **Demo numbers are never findings.** Delete them
before your real run with `Rscript clean_demo.R` (Appendix A, section A10).

## Step table

| Step | Script | What it does | Feeds | RQ |
|---|---|---|---|---|
| 0 | `04_analysis/00_check_env.R` | R version, packages, memory | `environment.txt` | — |
| 1 | `04_analysis/01_rehearsal_data.R` | Rebuilds the baseline network from Cho and Kim (2025) Table 1. Demo mode also simulates rehearsal data | Table 2, Figure 1 | RQ2 |
| 2 | `04_analysis/02_import_clean.R` | Reads the survey export. Consent rule first, then names, ranges and reverse coding | `import_log.csv` | — |
| 3 | `04_analysis/03_screening.R` | Attention, speed, long-string and duplicate rules. Keeps screened and unscreened data | `screening_summary.csv` | RQ2 |
| 4 | `04_analysis/04_measurement.R` | Facet scores, d′ and c, reliability, correlation matrices with M, SD and N, redundancy check | `reliability.csv`, `correlations_*.csv` | RQ1 |
| 5 | `04_analysis/05_structural.R` | Primary network, expected influence, bridge influence, predictability, bootstraps, stability, sensitivity | Table 3, Figures 2 to 5 | RQ1 |
| 6 | `04_analysis/06_options.R` | Network comparison test across the two Ghanaian samples | Table 4 | RQ3 |
| 7 | `04_analysis/07_figures.R` | Figures 1 to 5, PNG and PDF, greyscale with one olive highlight | Figures | RQ1 to RQ3 |
| 8 | `04_analysis/08_integrity_report.R` | Integrity table for the supervisor | `integrity_report.csv` | — |
| 9 | `04_analysis/09_cvi.R` | Expert panel: I-CVI, S-CVI/Ave, email label agreement, Fleiss' kappa | `cvi_*.csv` | Instrument |

Every setting (seed, γ, bootstrap counts, screening cut-offs, communities) lives in
`04_analysis/settings.R`. No setting is hard-coded in a script.

## Real run

1. Put your survey export at `03_data/raw/knust_export.csv` with the column names in `03_data/codebook.csv`.
2. Put the public Ghana data at `03_data/raw/public_ghana/public_ghana.csv` (see `04_analysis/01b_get_public_data.R`).
3. Run each script with `RUN_MODE=real`, for example `RUN_MODE=real Rscript 04_analysis/02_import_clean.R` (Appendix A, section A10).

## Rules

- Never commit raw responses, consent records, pilot answers, identifiers or keys. `.gitignore` blocks them.
- Never send survey responses, rater notes or campus materials to any AI service.
- Clean data with scripts only. Never edit an export by hand.
- Never invent, copy or top up a response. The integrity report makes it visible.
- Log every real use of an AI assistant in `06_docs/AI_USE_LOG.md`.

## Scale and data licences

| Material | Source | Licence or permission |
|---|---|---|
| Short UPPS-P (20 items) | Cyders et al. (2014), corrected key at impulsivity.org | Permission route to confirm (CHECK). Items are not stored in this repository |
| 23 shared items and public data | Appau et al. (2026), https://doi.org/10.17632/38wdwdd5ww.1 | CC BY 4.0. Data are fetched by you, never committed |
| Baseline correlation matrix | Cho and Kim (2025), https://doi.org/10.1038/s41598-025-85680-1 | Published numbers, cited. Article licence CC BY-NC-ND 4.0 |
| Email stimuli | Researcher-built | Written UITS permission for KNUST branding (CHECK) |

## Repository visibility

Public while you build and analyse, so your supervisor can review it. Private once results are final
and writing starts. Public again with a Zenodo release when the editor asks or at acceptance.

## Packages

R 4.5 with qgraph, bootnet, networktools, NetworkComparisonTest, mgm, psych, MASS and testthat.
Versions are pinned in `renv.lock`. Tested versions are listed in Appendix A, section A11.
