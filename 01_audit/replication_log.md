# Replication log: baseline rebuild (Supporting Objective A)

Baseline: Cho, J., & Kim, H. (2025). Scientific Reports, 15, 1852. https://doi.org/10.1038/s41598-025-85680-1

The script `04_analysis/01_rehearsal_data.R` rebuilds the network from Table 1 (N = 687) and writes:

- `05_results/tables/T2_rebuild_vs_reported.csv`: every edge, reported beside rebuilt
- `05_results/tables/T3_rebuild_centrality.csv`: EI, BEI(1), BEI(2), reported beside rebuilt

## Result of the tested run (R 4.5.3, qgraph 1.10.1, networktools 1.6.0)

| Check | Paper | Rebuilt | Status |
|---|---|---|---|
| Non-zero edges | 83 of 120 [p. 4] | 83 | Reproduced |
| Edge agreement with Table 2 | — | r = 0.997, largest gap 0.042 | Reproduced within rounding |
| EI agreement with Table 3 | — | r = 1.00 | Reproduced |
| BEI(1), BEI(2) agreement | — | r = 0.998, 0.999 | Reproduced |
| Bootstrap CIs, CS (0.75), NCT by gender | [p. 8–9] | Needs raw data (on request only) | Rehearsal only |

## Your notes (fill as you work)

| Date | What you ran | What you saw | What it means |
|---|---|---|---|
| | | | |
