# R script containing a loop that iteratively calls an Rmarkdown file

#########################################################
###### File paths require editing on lines: 18, 20 ###### 
#########################################################

# load packages
library(rmarkdown)

# create a report for each type of sensitivity analysis
# 1. exclude participants who die within first 3 years of follow-up
# 2. exclude participants who develop outcomes within first 3 years of follow-up
# 3. exclude participants with poor self-rated health at baseline
# these reports are saved in output_dir with the name specified by output_file

mylist = list("main", "no_death_3y", "no_cvd_3y", "no_poor_srh") 

for (analysis in mylist){
  
  rmarkdown::render('J:/R projects/PhD-by-chapter/Chapter6-prospective-association/code/cox models between frailty and outcomes.Rmd', # location of markdown to be run
                    output_file =  paste("hazard_ratios_", analysis, '_', Sys.Date(), ".html", sep=''), 
                    output_dir = 'J:/R projects/PhD-by-chapter/Chapter6-prospective-association/outputs') # same location as above, this is where reports will be saved
  
}