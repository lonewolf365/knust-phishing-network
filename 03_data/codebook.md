# Codebook notes

`codebook.csv` is the single source of item names. Your survey tool must export these exact column names.

| Column | Meaning |
|---|---|
| item | Column name in the export |
| block | consent, background, shared23, supps, attention, email, meta |
| community | Node group for bridge centrality |
| scale_min, scale_max | Allowed range. The import stops on out-of-range values |
| reverse | TRUE means the item is reverse-coded on import |
| key_status | What you still have to confirm |
| public_name | Column name of the same item in the public Ghana data |

**Before real collection:** replace the short UPPS-P item order and reverse flags with the corrected key
from impulsivity.org, and confirm the 23 shared items and their 5-point format against the public codebook.
