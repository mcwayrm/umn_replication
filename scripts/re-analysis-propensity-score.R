# Description: Re-analysis of Table 3 Propensity Score Matching 
# Table of Contents: 
# 1. Creating PSM
# 2. Estimating effect using PSM
# 3. Regression with PSM


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
# 1. Create Propensity Score
#########################


#########################
# 2. PSM without Regression
#########################


#########################
# 3. Regression PSM
#########################



