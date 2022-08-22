# R script to open and process data to analyse baseline frailty and CVD outcomes

## Open and process data

### Open participant list for the main analysis

ptlist_main_analysis = readRDS("J:/R projects/PhD-by-chapter/rds objects/ptlist_main_analysis.rds")

### Open baseline frailty score

data_baseline_fi_all = readRDS("J:/R projects/PhD-by-chapter/data/scripts/data_baseline_fi_all.rds")

frailty = data_baseline_fi_all %>% 
  select(csid, fi.score_full, fi.cat_full, fi.score_no_cv, fi.cat_no_cv, fi.score_no_adiposity, fi.cat_no_adiposity, fi.score_no_21, fi.cat_no_21) %>% 
  filter(csid %in% ptlist_main_analysis) # filter participants for main analysis

### Open baseline covariates

covariates = readRDS("J:/R projects/PhD-by-chapter/rds objects/covariates_for_everyone.rds")
covariates = covariates[covariates$main_analysis==1, ] # select participants in main analysis
covariates = covariates[, -("main_analysis")] # remove columns not required for analysis

### Open outcome data

events = readRDS("J:/R projects/PhD-by-chapter/rds objects/cvd_event_for_everyone.rds")
events = events[events$main_analysis==1, ] # select participants in main analysis
events = events[, -("main_analysis")] # remove columns not required for analysis

### Merge data

mydata = events %>% 
  left_join(covariates, by = "csid") %>% 
  left_join(frailty, by = "csid")

mydata = mydata %>% 
  mutate_at(c("region_code", "is_female", "household_income", "marital_status", "occupation", "highest_education", "hypertension_diag", "diabetes_diag", "alcohol_category", "smoking_group", "poor_adiposity", "self_rated_health", "poor_diet"), ~as.factor(.))
