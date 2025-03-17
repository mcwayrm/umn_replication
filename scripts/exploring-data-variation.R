# Description: Data sluething the data for errors
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


#########################
# Directories 
#########################
path_data = "D:/umn_replication/original-data/data/main_study_cleaned.dta" # original data 
path_out = "D:/umn_replication/outputs/" # output folder

# Load data 
df <- import(path_data)


#########################
# 1. Treatment Varation
#########################


# Assuming df is your data frame
# Create a density plot
ggplot(df, aes(x = publish, fill = factor(low))) +
    geom_density(alpha = 0.5) +
    labs(title = "Density Plot of Publishability by Treatment",
         x = "Likilihood to Publish",
         y = "Density",
         fill = "Low") +
    theme_minimal()



#########################
# 2. Outcome Variation
#########################


#########################
# 3. Potential Data Issues
#########################
# Explore any data variables where cleaning or raw data may have errors 


# An initial thought is do some observations have strong statistical leverage. 
# I could identify they by finding folks that are quite different from everyone else. 

df |> 
    select(publish, low, qualityfob, qualitysob, importancefob, importancesob, 
           duration, pagetime, finished) |> 
    View()

# Frequency of people in the long tail of time spent (are these people not paying attention)
time <- 10000
num_above_threshold <- sum(df$pagetime > time) # n above threshold
total_observations <- nrow(df) # n
percent_above_threshold <- (num_above_threshold / total_observations) * 100 # percent
percent_above_threshold # 5%

# How many vignettes recieved less than 1 minute of attention?
time <- 60
num_above_threshold <- sum(df$pagetime < time) # n above threshold
total_observations <- nrow(df) # n
percent_above_threshold <- (num_above_threshold / total_observations) * 100 # percent
percent_above_threshold # 20%

time <- 30
num_above_threshold <- sum(df$pagetime < time) # n above threshold
total_observations <- nrow(df) # n
percent_above_threshold <- (num_above_threshold / total_observations) * 100 # percent
percent_above_threshold # 2.5%

# TODO: Make indicators for observations when time spent is too short or too long...

# Intervals of time spent on vignettes
breaks <- seq(0, max(df$pagetime, na.rm = TRUE), by = 600) # 10 minute intervals
# Create intervals using the cut function
df$intervals <- cut(df$pagetime, breaks = breaks, right = FALSE)
# Calculate the frequency of observations in each interval
frequency_table <- table(df$intervals)
# Print the frequency table
print(frequency_table)
hist(frequency_table, breaks = 50)

# Tim# Tim# Time spent on vigenttees by treatment 
ggplot(subset(df, df$pagetime < 25000), aes(x = pagetime, fill = factor(low))) +
    geom_density(alpha = 0.5) +
    labs(title = "Density Plot of Time Spent on Vignettes by Treatment",
         x = "Time Spent on Vignettes (Sec.)",
         y = "Density",
         fill = "Low") +
    theme_minimal()



# 28 people did not finish the survey but are in the sample. If we remove them do the results change? 
table(df$finished)
