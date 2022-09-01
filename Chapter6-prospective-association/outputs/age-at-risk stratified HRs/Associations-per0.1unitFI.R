library(data.table)
library(tidyverse)

## Open HRs 

if (fi_type == "Original FI"){
  
  hrlist = readRDS(file = "J:/R projects/PhD-by-chapter/Chapter6-prospective-association/rds objects/output data/HRs baseline 0.1 unit FI (original) and outcomes.rds")
  
} else if (fi_type == "mFI-1"){
  
  hrlist = readRDS(file = "J:/R projects/PhD-by-chapter/Chapter6-prospective-association/rds objects/output data/HRs baseline 0.1 unit FI (mFI-1) and outcomes.rds")
  
} else if (fi_type == "mFI-3"){
  
  hrlist = readRDS(file = "J:/R projects/PhD-by-chapter/Chapter6-prospective-association/rds objects/output data/HRs baseline 0.1 unit FI (mFI-3) and outcomes.rds")
  
} else {
  
}

# Save ordering of outcome
outcome_name = names(hrlist)

outcome_name = outcome_name %>% 
  str_replace(., "fatal", "(fatal)") %>% 
  str_replace(., "incidence", "(non-fatal)") %>% 
  str_replace(., "Fatal CVD (total)", "CVD mortality") %>%   
  str_replace(., "total", "(any)") %>% 
  str_replace(., "All cause mortality", "All-cause mortality")

outcome_name

# Rename list 
names(hrlist) = outcome_name

hrs_fi0.1_total = data.table::rbindlist(hrlist, idcol = "outcome") %>% 
  mutate(hr = format(round(estimate, 2), nsmall=2),
         lq = format(round(conf.low, 2), nsmall=2),
         uq = format(round(conf.high, 2), nsmall=2)) %>% 
  mutate(hrs = paste0(hr, " (", lq, "-", uq, ")")) %>% 
  select(outcome, rf=term, n, hrs)

# Save ordering of outcome
outcome_order = pull(hrs_fi0.1_total, outcome)

# Combine data
hrs_total = hrs_fi0.1_total %>% 
  mutate(outcome = factor(outcome, levels = outcome_order)) %>% 
  arrange(outcome)

hrs_total

write.csv(hrs_total, file = paste0("J:/R projects/PhD-by-chapter/Chapter6-prospective-association/outputs/age-at-risk stratified HRs/", fi_type, "/HRs_", fi_type, "_per0.1unit_outcomes.csv"))