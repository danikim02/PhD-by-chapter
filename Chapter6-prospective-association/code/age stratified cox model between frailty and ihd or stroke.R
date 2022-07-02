############################################################################################
##### Cox regression between baseline frailty and outcomes: age-at-risk stratification #####
############################################################################################

# Required libraries
library(broom)      # for tidy() function
library(ckbplotr)
library(cowplot)
library(data.table)
library(Epi)        # for float(), which compute floating absolute risks using the method by Easton et al.
library(kableExtra)
library(knitr)
library(lubridate)
library(survival)   # for Surv(), cox regression
library(tidyverse)

## Open and process data

# Run external script to open and process data
# Source script that creates working dataset that includes baseline frailty scores and CVD outcomes with key baseline covariates
source("J:/R projects/PhD-by-chapter/Chapter6-prospective-association/code/source/script to open and process dataset to analyse baseline frailty and outcomes.R")

# Further process data for age-at-risk analysis to have following variables:
# - csid
# - dob_anon
# - study_date
# - endpoint - binary variable indicating the endpoint (1/0)
# - endpoint_date - date of endpoint event or censoring
# - frailty quintile group
# - outcome_type - indicate outcome type, e.g. stroke, MI, etc.

mydata = mydata %>% 
  mutate_at(vars(contains("_ind")), ~replace(., is.na(.), 0)) # replace missing values with zeros for dummy variables 

mydata = mydata %>% 
  mutate_at(vars(contains("total_date"), contains("incidence_date"), contains("fatal_date"), date_of_death), ~replace(., is.na(.), censoring_date)) # if empty dates (i.e. no event), then replace empty values with censoring date

# Split FI into quintile groups & create transformed FI to get 1SD change

mydata$fi5= factor(ntile(mydata$fi.score_no_cv, 5)) # split FI into quintile groups 
mydata$ficat = mydata$fi.cat_no_cv
mydata$fi_transformed= (mydata$fi.score_no_cv - mean(mydata$fi.score_no_cv))/sd(mydata$fi.score_no_cv) # per 1 SD
mydata$srh = as.numeric(mydata$self_rated_health)
mydata$srh_transformed = (mydata$srh - mean(mydata$srh))/sd(mydata$srh) # per 1 SD

# Make outcome data long

temp = mydata %>% 
  select(csid, event_All_cause_mortality_ind = died, event_All_cause_mortality_date = date_of_death, contains("event_"))

temp = pivot_longer(temp, cols = -1, names_pattern = "(.*)(ind|date)$", names_to = c("names", ".value"))
# names_pattern = ()()  means look for 2 parts; (.*) means first part should have zero or more characters; (ind|date)$ means the second part should end either as ind or date

temp$names = as.factor(temp$names)

# Split data on outcome and save as list

mylist = split(temp, f = temp$names)

## Age-at-risk stratified Cox proportional hazards

# Create function to run analysis using exposure as categorical variable, i.e. FI quintile

source("J:/R projects/PhD-by-chapter/source codes/ckb resources/expand_age_at_risk.R")

run_age_at_risk_cox_model_exposure = function(dataset, exposure_cat, exposure_cont){
  
  # Variable input character will not be recognised in dplyr
  x = sym(exposure_cat)
  y = sym(exposure_cont)
  
  # Merge dob_anon, study_date and rename variables
  dataset = dataset %>% 
    left_join(select(mydata, csid, dob_anon, study_date, !!x, !!y, is_female), by = "csid") %>% # mydata contains frailty variable and other covariates
    select(csid, dob_anon, study_date, endpoint = ind, endpoint_date = date, !!x, !!y, is_female)

  formula1 = as.formula(paste("Surv(time_in, time_out, endpoint) ~ ", exposure_cat," + strata(as.factor(XAgeGrp)) + strata(is_female) + strata(region_code) + household_income + marital_status + occupation + highest_education + hypertension_diag + diabetes_diag + alcohol_category + smoking_group + poor_diet + fat_body_mass_kg"))
  formula2 = as.formula(paste("Surv(time_in, time_out, endpoint) ~ ", exposure_cont," + strata(as.factor(XAgeGrp)) + strata(is_female) + strata(region_code) + household_income + marital_status + occupation + highest_education + hypertension_diag + diabetes_diag + alcohol_category + smoking_group + poor_diet + fat_body_mass_kg"))
  
  # Expand data by age-at-risk
  dataset_long = expand_age_at_risk(df = dataset,
                                    ages = c(40, 45, 50, 55, 60, 65, 70, 75, 80))
  #head(dataset_long)
  
  # Merge columns - expanded dataset does not contain the risk factor (frailty) or other covariates
  to_merge = mydata %>% 
    select(csid, !!x, !!y, is_female, region_code, household_income, marital_status, occupation, highest_education, hypertension_diag, diabetes_diag, alcohol_category, smoking_group, poor_diet, fat_body_mass_kg)
  
  dataset_long = left_join(dataset_long, to_merge, by = "csid")
  
  # Cox proportional hazards model using categorical exposure
  fit1 = survival::coxph(formula1, data = dataset_long, ties = "breslow") # the expanded dataframe contains 'XAgeGrp' column which can be used to stratify the CoxPH model, the time columns specify the start and end time for intervals
  #summary(fit)
  
  # Floating absolute risk
  float = Epi::float(fit1) # calculate the floating variances (Plummer method)
  #float
  
  # numbers
  tab = table(dataset[[exposure_cat]], dataset[["endpoint"]])
  
  # Extract data
  hrs1 = data.frame(
    est = float$coef,
    se = sqrt(float$var),
    rf = names(float$coef),
    n = tab[1:dim(tab)[1], 2] 
  )
  
  # Cox proportional hazards model using continuous exposure
  fit2 = survival::coxph(formula2, data = dataset_long, ties = "breslow") # the expanded dataframe contains 'XAgeGrp' column which can be used to stratify the CoxPH model, the time columns specify the start and end time for intervals
  #summary(fit)
  
  # Compute onfidence intervals
  hrs2 = fit2 %>% 
    tidy(conf.int = TRUE, exponentiate = TRUE) %>% 
    select(term, estimate, starts_with("conf"))
  
  hrs2 = hrs2[1, ] # save results for frailty
  
  output = list(hrs1, hrs2)
  
  return(output)
  
}  


# Run function on each outcome
## For now, just run analyses for total stroke and total IHD
mylist =  mylist[c("event_IHD_total_", "event_Stroke_total_")]

hrlist = lapply(mylist, run_age_at_risk_cox_model_exposure, exposure_cat = "fi5", exposure_cont = "fi_transformed")
hrlist = lapply(mylist, run_age_at_risk_cox_model_exposure, exposure_cat = "self_rated_health", exposure_cont = "srh_transformed")

## Save results

saveRDS(hrlist, file = "J:/R projects/PhD-by-chapter/Chapter6-prospective-association/rds objects/output data/HRs baseline FI (modified) and stroke and IHD.rds")
saveRDS(hrlist, file = "J:/R projects/PhD-by-chapter/Chapter6-prospective-association/rds objects/output data/HRs baseline SRH and stroke and IHD.rds")