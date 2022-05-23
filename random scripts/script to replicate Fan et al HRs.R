#### Script to output HRs to compare main results from Fan et al. (2020) paper

library(broom)      # for tidy() to get clean HRs and confidence intervals from model fit
library(cowplot)
library(data.table)
library(Epi)        # for float(), which compute floating absolute risks using the method by Easton et al.
library(kableExtra)
library(knitr)
library(lubridate)
library(survival)   # for Surv(), cox regression
library(tidyverse)

## Open and process data

### Open baseline frailty score

data_baseline_fi_all = readRDS("J:/R projects/ckb-frailty-index/code/analysis/data_baseline_fi_all.rds")

frailty = data_baseline_fi_all %>% 
  select(csid, fi.score_full, fi.cat_full, fi.score_no_cv, fi.cat_no_cv)
### Open baseline covariates

covariates = readRDS("J:/R projects/PhD-by-chapter/rds objects/covariates_for_everyone.rds")

### Open outcome data

events = readRDS("J:/R projects/PhD-by-chapter/rds objects/cvd_event_for_everyone.rds")

### Merge data

mydata = events %>% 
  left_join(covariates, by = "csid") %>% 
  left_join(frailty, by = "csid")

mydata = mydata %>% 
  mutate_at(c("region_code", "is_female", "household_income", "marital_status", "occupation", "highest_education", "hypertension_diag", "diabetes_diag", "alcohol_category", "smoking_group", "poor_adiposity", "self_rated_health", "poor_diet"), ~as.factor(.))

mydata = mydata %>% 
  select(event_All_cause_mortality_ind = died, event_All_cause_mortality_date = date_of_death, everything()) %>% 
  mutate_at(vars(contains("_ind")), ~replace(., is.na(.), 0)) # replace missing values with zeros for dummy variables 

# Save a dataframe to carry out normal CoxPH
mydata = mydata %>% 
  mutate_at(vars(contains("mortality_date"), contains("total_date"), contains("incidence_date"), contains("fatal_date")), ~replace(., is.na(.), censoring_date)) %>% # if empty dates (i.e. no event), then replace empty values with censoring date
  mutate(
    across( .cols = c(contains("mortality_date"), contains("total_date"), contains("incidence_date"), contains("fatal_date")), ~ .x - study_date) # calculate the time between study entry date and date of event/censoring
  )

mydata$fi_0.1 = mydata$fi.score_full/0.1 # per 0.1 unit increment

model = survival::coxph(Surv(event_Stroke_fatal_date, event_Stroke_fatal_ind) ~ fi_0.1 + age_at_study_date_x100 + is_female + region_code + highest_education + smoking_group + alcohol_category + daily_fresh_fruit + daily_fresh_veg + daily_meat, data = mydata)

hrs = model %>% 
  tidy(conf.int = TRUE, exponentiate = TRUE) %>% 
  select(term, estimate, starts_with("conf"))

hrs[1, ]

model = survival::coxph(Surv(event_IHD_fatal_date, event_IHD_fatal_ind) ~ fi_0.1 + age_at_study_date_x100 + is_female + region_code + highest_education + smoking_group + alcohol_category + daily_fresh_fruit + daily_fresh_veg + daily_meat, data = mydata)

hrs = model %>% 
  tidy(conf.int = TRUE, exponentiate = TRUE) %>% 
  select(term, estimate, starts_with("conf"))

hrs[1, ]

model = survival::coxph(Surv(event_All_cause_mortality_date, event_All_cause_mortality_ind) ~ fi_0.1 + age_at_study_date_x100 + is_female + region_code + highest_education + smoking_group + alcohol_category + daily_fresh_fruit + daily_fresh_veg + daily_meat, data = mydata)

hrs = model %>% 
  tidy(conf.int = TRUE, exponentiate = TRUE) %>% 
  select(term, estimate, starts_with("conf"))

hrs[1, ]