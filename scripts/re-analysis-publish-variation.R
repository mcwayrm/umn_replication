# Description: Re-analysis exploring DV variation
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
# 1. Dependent Variable Variation
#########################

# Publish by treatment
ggplot(df, aes(x = publish, fill = factor(low))) +
    geom_density(alpha = 0.5) +
    labs(title = "Density Plot of Publishability by Treatment",
         x = "Likilihood to Publish",
         y = "Density",
         fill = "Low") +
    theme_minimal()

# What are the common responses:
sort(table(df$publish))

# New data recoding +-2 of 5 or 10. Re-plot 

# Suspiciously uniform
hist(df$publish, breaks = 10)
# Bunching around specific values
hist(df$publish, breaks = 100) # Lots of grouping on individual values 

# Histogram overlaying control onto treatment
df2 <- data.table::copy(df)
df2[, publish := ifelse(low == 1, publish, 100 - publish)]

# Regular historgram by treatment
ggplot(df, aes(publish, fill = as.factor(low))) + 
    geom_histogram(alpha = 0.5, position = 'dodge')
# Histogram after flip the scale (e.g., are the symettric about the average (50))
ggplot(df2, aes(publish, fill = as.factor(low))) + 
    geom_histogram(alpha = 0.5, position = 'dodge')
    
    # This looks awfully symettric...


# TODO: Do this again, but recode values 1 or 2 away from divisors of 5.