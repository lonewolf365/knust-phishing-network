# Data dictionary (derived variables)

| Variable | How it is made | Range | Script |
|---|---|---|---|
| NU, PU, PR, PE, SS | Mean of the 4 short UPPS-P items after reverse coding | 1–4, higher = more impulsive | 04_measurement.R |
| dprime | qnorm(H) − qnorm(F), log-linear correction: H = (hits + 0.5)/(8 + 1), F = (false alarms + 0.5)/(8 + 1) | about −3 to 3, higher = better discrimination | functions.R |
| c_bias | −0.5 × (qnorm(H) + qnorm(F)) | positive = leans toward "safe" | functions.R |
| minutes | end_time − start_time | minutes | 02_import_clean.R |
| flag_* | Screening flags (attention, speed, longstring, duplicate) | TRUE / FALSE | 03_screening.R |
