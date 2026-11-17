# Teardown notes (summary of the baseline audit)

## Supplement and data
- Supplement: Supplementary Table 1 (demographics), Figures S1 and S2 (difference tests). Not needed for the rebuild.
- Data availability: on request only. The rebuild uses the published Table 1.
- Article licence: CC BY-NC-ND 4.0. Cite numbers. Do not publish adapted versions of its figures.

## Flags in the printed tables (none blocks the rebuild)
- F1: Strategies SD printed as 0.10. Typo. The network uses correlations.
- F2: Lack of premeditation with sensation seeking, r = .04, marked **. The star is wrong (p = .30).
- F3: Six alpha values listed for five named factors.
- F5: "Mediator" wording on an undirected network. Use association words only.
- F6: Correlation type not stated. Pearson reproduces Table 2 (r = .997).
- F9: Negative and positive urgency correlate at .84. Check redundancy first.
- F10: Relapse and negative urgency tie for fourth place in EI.

## Leading reconstruction (R1)
Pearson matrix → EBICglasso (γ = 0.5, qgraph defaults) → EI, BEI(1), BEI(2) with three scale
communities → bootnet robustness. Reproduced 83 edges.

## Unrecoverable details and choices made
- Case-drop bootstraps: 1,000 (ASSUMPTION). NCT: 1,000 permutations, Holm (ASSUMPTION).
- Difference tests: bootnet default, alpha .05.
