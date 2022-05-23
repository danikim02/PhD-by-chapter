expand_age_at_risk <- function(df, ages) {
  df %>% 
    
    # keep only needed columns, to reduce memory requirements
    select(csid, dob_anon, study_date, endpoint, endpoint_date) %>% 
    
    # remove incomplete
    na.omit() %>% 
    
    # create row for each participant and each age group
    crossing(tibble(XAgeGrp_start = ages[-length(ages)],
                    XAgeGrp_end = ages[-1])) %>% 
    mutate(XAgeGrp = (XAgeGrp_start + XAgeGrp_end)/2) %>% 
    
    # start date of each interval is birthday (i.e. calendar years after dob)
    mutate(start_int = add_with_rollback(as.Date(dob_anon),
                                         years(XAgeGrp_start),
                                         roll_to_first = T)) %>%
    
    # remove intervals that start after censoring date
    filter(start_int <= as.Date(endpoint_date)) %>% 
    
    # end date of each interval is day before next interval
    mutate(end_int = add_with_rollback(as.Date(dob_anon),
                                       years(XAgeGrp_end),
                                       roll_to_first = T) - 1) %>% 
    
    # remove intervals that end before entering study
    filter(end_int >= as.Date(study_date)) %>%
    
    # correct start and end date for intervals partially during study
    mutate(start_int = pmax(as.Date(study_date), start_int),
           end_int   = pmin(as.Date(endpoint_date), end_int)) %>%
    
    # endpoint can only be 1 for the last interval
    mutate(endpoint = as.numeric(end_int == as.Date(endpoint_date) & endpoint),
           
           # calculate days / years from start of study
           ## end intervals at + 0.95 to match 'SAS Cox system'
           t_start_days   = interval(as.Date(study_date), start_int) / days(1),
           t_end_days     = interval(as.Date(study_date), end_int) / days(1) + 0.95,
           time_in        = round(interval(as.Date(study_date), start_int) / years(1), 4),
           time_out       = round(interval(as.Date(study_date), end_int) / years(1) + .95/365.25, 4))
}
