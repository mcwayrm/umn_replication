# Description: Re-analysis Table 3 with quantile regression
# Table of Contents: 
# 1. 


#########################
# Preamble
#########################
# Clear environment and set encoding
rm(list=ls())
# Necessary Dependencies
library(rio) # Import any data type
library(ggplot2) # plots
library(data.table) # Processing data frames


#########################
# Directories 
#########################
path_data = "D:/umn_replication/original-data/data/main_study_cleaned.dta" # original data 
path_out = "D:/umn_replication/outputs/" # output folder

# Load data 
df <- setDT(import(path_data))


#########################
# 1. Quantile Regressios
#########################


# - Quantile effects by every 5/10 percents. 
# - If the effects are the same at each level, then we uniform effects