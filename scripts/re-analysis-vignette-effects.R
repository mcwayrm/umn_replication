# Description: Re-analysis of Table 3 with vingette order effects
# Table of Contents: 
# 1. 


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
# 1. 
#########################

df_control <- subset(df, df$low == 0)
col1_mean <- round(mean(df_control$publish), 3) # Subset for control

# Column 1
col1 <- plm(publish ~ low + exlow + exhigh + field + phd + unilow + pval, 
            data = df,
            index = c("id", "vignette"), 
            model = "within")
col1_se <- sqrt(diag(vcovHC(col1, type = "HC1", cluser = "id")))

# Column 1 - Order Effect
new <- plm(publish ~ low + exlow + exhigh + field + phd + unilow + pval + as.factor(order), 
            data = df,
            index = c("id", "vignette"), 
            model = "within")
new_se <- sqrt(diag(vcovHC(col1, type = "HC1", cluser = "id")))

# Column 1 - Interaction Effect
int <- plm(publish ~ low + exlow + exhigh + field + phd + unilow + pval + as.factor(order) + low*as.factor(order), 
           data = df,
           index = c("id", "vignette"), 
           model = "within")
int_se <- sqrt(diag(vcovHC(col1, type = "HC1", cluser = "id")))


# Check
stargazer(col1, new, int,
          type = "text", 
          keep = c(1, 7, 8, 9, 10, 11, 12),
          covariate.labels = c("Null result treatment", "Order Effect"),
          column.labels = c("OG", "Order Effects"),
          se = list(col1_se, new_se, int_se), 
          keep.stat = c("n", "adj.rsq"),
          model.numbers = TRUE,
          digits = 3, 
          add.lines = list(c("Mean Dep. Var.", col1_mean, col1_mean, col1_mean)
          )) 

# No order effects at all? So there is no fatigue? 
# Average length is 1,307 seconds (20 minutes). Seems a little odd. 
vtable::sumtable(df, vars = "duration")
