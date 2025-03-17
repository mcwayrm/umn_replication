# Description: Re-analysis of Table 3 with changes to sample composition 
# Table of Contents: 
# 1. Balance on excluded observations 
# 2. Sensitivity to including vignettes less than 4
# 3. Sensitivity to excluding observations that did not 'finish' survey 
# 4. Salience of treatment? Sample selection on time spent on vignettes or including it as control.


#########################
# Preamble
#########################
# Clear environment and set encoding
rm(list=ls())
# Necessary Dependencies
library(rio) # Import any data type
library(stargazer) # Output tables
library(plm) # Fixed effects
library(sandwich) # Standard errors


#########################
# Directories 
#########################
path_data = "D:/umn_replication/original-data/data/main_study_cleaned.dta" # original data 
path_out = "D:/umn_replication/outputs/" # output folder

# Load data 
df <- import(path_data)

#########################
# 1. Balance on excluded observations
#########################


#########################
# 2. Sensitivity to including vignettes less than 4
#########################


#########################
# 3. Sensitivity to excluding observations that did not 'finish' survey
#########################


#########################
# 4. Salience of treatment? Sample selection on time spent on vignettes or including it as control.
#########################

