# R script containing a loop that iteratively calls an Rmarkdown file

#############################################################################################
#### Script to run sensitivity analyses of cox regression models between FI and outcomes ####
#############################################################################################

# create a report for each type of sensitivity analysis
# 1. exclude participants who die within first 3 years of follow-up
# 2. exclude participants who develop outcomes within first 3 years of follow-up
# 3. exclude participants with poor self-rated health at baseline
# these reports are saved in output_dir with the name specified by output_file

library(rmarkdown)

mylist = list("main", "no_death_3y", "no_cvd_3y", "no_poor_srh") 

for (analysis in mylist){
  
  rmarkdown::render('J:/R projects/PhD-by-chapter/Chapter6-prospective-association/code/cox models between frailty and outcomes.Rmd', # location of markdown to be run
                    output_file =  paste("hazard_ratios_", analysis, '_', Sys.Date(), ".html", sep=''), 
                    output_dir = 'J:/R projects/PhD-by-chapter/Chapter6-prospective-association/outputs') # same location as above, this is where reports will be saved
  
}

###############################################################################################################
#### Script to run age-at-risk stratified cox regression models between frailty and outcomes by type of FI ####
###############################################################################################################

library(rmarkdown)

mylist = list("original", "mFI-1", "mFI-3") 

for (fi_type in mylist){
  
  rmarkdown::render('J:/R projects/PhD-by-chapter/Chapter6-prospective-association/code/age stratified cox models between frailty and outcomes.Rmd', # location of markdown to be run
                    output_file =  paste("hazard_ratios_FI", fi_type, '_outcomes_', Sys.Date(), ".html", sep=''), 
                    output_dir = 'J:/R projects/PhD-by-chapter/Chapter6-prospective-association/rds objects/output data/') # location of output
  
}

###################################################
#### Script to plot age-at-risk stratified HRs ####
###################################################

library(rmarkdown)

mylist = list("Original FI", "mFI-1", "mFI-3") 

for (fi_type in mylist){
  
  rmarkdown::render('J:/R projects/PhD-by-chapter/Chapter6-prospective-association/outputs/age-at-risk stratified HRs/Plot age-at-risk stratified HRs.Rmd', # location of markdown to be run
                    output_file =  paste("Plot-age-at-risk-stratified-HRs-FI", fi_type, '_', Sys.Date(), ".html", sep=''), 
                    output_dir = paste0("J:/R projects/PhD-by-chapter/Chapter6-prospective-association/outputs/age-at-risk stratified HRs/", fi_type, "/")) # location of output
  
}

library(rmarkdown)

mylist = list("Original FI", "mFI-1", "mFI-3") 

for (fi_type in mylist){
  
  rmarkdown::render('J:/R projects/PhD-by-chapter/Chapter6-prospective-association/outputs/age-at-risk stratified HRs/Associations-per0.1unitFI.R') # location of R file to be run
  
}

########################################################################
#### Script to run subgroup analysis for age-at-risk stratified HRs ####
########################################################################

library(rmarkdown)

mylist = list("mFI-1", "mFI-3") #
mylist2 = list("event_Stroke_total_", "event_IHD_total_", "event_Fatal_CVD_total_" , "event_All_cause_mortality_")

for (fi_type in mylist){
  
  for (outcome in mylist2){
    
    rmarkdown::render('J:/R projects/PhD-by-chapter/Chapter6-prospective-association/code/subgroup analysis for cox models between frailty and outcomes.Rmd', # location of markdown to be run
                    output_file =  paste("subgroup_analysis_", fi_type, "_", outcome, "_", Sys.Date(), ".html", sep=""), 
                    output_dir = paste0("J:/R projects/PhD-by-chapter/Chapter6-prospective-association/outputs/age-at-risk stratified HRs/", fi_type, "/")) # location of output
  
  }
  
}


########################################################################
#### Script to plot subgroup analysis for age-at-risk stratified HRs ####
########################################################################

library(rmarkdown)

mylist = list("mFI-3", "mFI-1")
mylist2 = list("CVD mortality" , "All-cause mortality", "IHD", "Stroke")

for (fi_type in mylist){
  
  for (outcome in mylist2){
    
    rmarkdown::render('J:/R projects/PhD-by-chapter/Chapter6-prospective-association/outputs/age-at-risk stratified HRs/Plot subgroup age-at-risk stratified HRs.Rmd', # location of markdown to be run
                      output_file =  paste("subgroup_analysis_", fi_type, "_", outcome, "_", Sys.Date(), ".html", sep=""), 
                      output_dir = paste0("J:/R projects/PhD-by-chapter/Chapter6-prospective-association/outputs/age-at-risk stratified HRs/subgroup/")) # location of output
    
  }
  
}