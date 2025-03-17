# Description: Re-analysis of Table 3 testing the standard errors 
# Table of Contents: 
# 1. Original Table 3 - HC1
# 2. 


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
# 1. Original Table 3 - HC1
#########################

# ORIGINAL STATA CODE: 
# # Variables
# global treatments low exlow exhigh field phd unilow pval
# local outcomes publish z_qualityfob z_qualitysob z_importancefob z_importancesob
# 
# # FE
# foreach var of varlist `outcomes' { 
# 	eststo `var': reghdfe `var' i.($treatments),  absorb(id vignette) vce(cluster id)
# }
# # OLS
# foreach var of varlist `outcomes' { 
#     eststo `var': reghdfe `var' i.($treatments),  absorb(vignette) vce(cluster id)
# }

treatments <- c("low", "exlow", "exhigh", "field", "phd", "unilow", "pval")
outcomes <- c("publish", "z_qualityfob", "z_qualitysob", "z_importancefob", "z_importancesob")

# Column 1
col1 <- plm(publish ~ low + exlow + exhigh + field + phd + unilow + pval, 
                data = df,
                index = c("id", "vignette"), 
                model = "within")
col1_se <- sqrt(diag(vcovHC(col1, type = "HC1")))

# Check
stargazer(col1,
          type = "text", 
          keep = c(1),
          covariate.labels = c("Null result treatment"),
          se = list(col1_se), 
          keep.stat = c("n", "adj.rsq"),
          model.numbers = TRUE,
          digits = 3) 
