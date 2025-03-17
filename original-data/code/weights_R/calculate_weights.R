# Description: 
# Generate weights that render the sample comparable to the
# population of economists in the top 200 institutions.
# Weights are used in subsequent analysis in Stata.

############################################################
### USER INPUT: SET THE PATH HERE TO MATCH YOUR MACHINE ####
############################################################
base_path = "D:/umn_replication/original-data"


##################################################
################ PREPARATION #####################
##################################################
# Clear environment and set encoding
rm(list=ls())
# Load packages required for this script

install.packages("weights", dependencies=TRUE)
install.packages("anesrake", dependencies=TRUE)

packages = c("haven", "tibble", "plyr", "dplyr", "Hmisc", "tidyr", "anesrake", "weights")
# install packages if necessary, then load them.
for (p in packages) {
    if (p %in% rownames(installed.packages())) {
        library(p, character.only=TRUE)
    } else {
        install.packages(p)
        library(p, character.only = TRUE)
    }
}

##################################################
################ LOAD DATA       #################
##################################################

# Load population-level statistics
af = read_dta(paste(base_path, "data", "composition.dta", sep="/"))

# Load expert demographics data
df = read_dta(paste(base_path, "data", "expert_demographics.dta", sep="/"))

# Define new variables
df$female = as.numeric(mapvalues(df$male, from=c(1, 0), to=c(0, 1)))
df$repeated_top5_referee = as.numeric(df$number_top5_referee >=2)


# Define raking variables
vars = c(
    "raking_female",
    "raking_region_asia",
    "raking_region_australia",
    "raking_region_europe",
    "raking_region_northamerica",
    "raking_repeated_top5_referee",
    "raking_current_editor"
)

df$raking_female = paste0("raking_female", df$female)
df$raking_region_asia = paste0("raking_region_asia", df$region_asia)
df$raking_region_australia = paste0("raking_region_australia", df$region_australia)
df$raking_region_europe = paste0("raking_region_europe", df$region_europe)
df$raking_region_northamerica = paste0("raking_region_northamerica", df$region_northamerica)
df$raking_repeated_top5_referee = paste0("raking_repeated_top5_referee", df$repeated_top5_referee)
df$raking_current_editor = paste0("raking_current_editor", df$current_editor)

# Replace NAs with random other level
for (v in vars) {
    nas = grepl("NA$", df[, v, drop=T])
    df[, v][nas,] = ifelse(
        all(nas),
        "allNA",
        sample(df[, v, drop=T][!nas], sum(nas))
    )
}

# Factorize variables
df = as.data.frame(df)
for (v in vars) {df[,v] <- as.factor(df[,v])}

# Rename variables to match naming in main data
af <- af %>% 
  rename(
    raking_female = af_female_mean,
    raking_region_asia = af_cont_asia_mean,
    raking_region_australia = af_cont_aus_nz_mean,
    raking_region_europe = af_cont_europe_mean,
    raking_region_northamerica = af_cont_northernamerica_mean,
    raking_repeated_top5_referee = af_referee_con_mean,
    raking_current_editor = af_editor_real_top100_mean,
)

# Derive targets
target_female <- c(1.0 - af$raking_female[1], af$raking_female[1])
names(target_female) <- c("raking_female0", "raking_female1")

target_region_asia <- c(1.0 - af$raking_region_asia[1], af$raking_region_asia[1])
names(target_region_asia) <- c("raking_region_asia0", "raking_region_asia1")

target_region_australia <- c(1.0 - af$raking_region_australia[1], af$raking_region_australia[1])
names(target_region_australia) <- c("raking_region_australia0", "raking_region_australia1")

target_region_europe <- c(1.0 - af$raking_region_europe[1], af$raking_region_europe[1])
names(target_region_europe) <- c("raking_region_europe0", "raking_region_europe1")

target_region_northamerica <- c(1.0 - af$raking_region_northamerica[1], af$raking_region_northamerica[1])
names(target_region_northamerica) <- c("raking_region_northamerica0", "raking_region_northamerica1")

target_repeated_top5_referee <- c(1.0 - af$raking_repeated_top5_referee[1], af$raking_repeated_top5_referee[1])
names(target_repeated_top5_referee) <- c("raking_repeated_top5_referee0", "raking_repeated_top5_referee1")

target_current_editor <- c(1.0 - af$raking_current_editor[1], af$raking_current_editor[1])
names(target_current_editor) <- c("raking_current_editor0", "raking_current_editor1")

target <- list(
    target_female, target_region_asia,
    target_region_australia, target_region_europe,
    target_region_northamerica, target_repeated_top5_referee,
    target_current_editor)
names(target) <- vars

# Prepare for raking
rake = list()

# Raking algorithm
rake = suppressWarnings(anesrake(
    inputter = target,
    dataframe = df[, vars],
    caseid = df$id,
    # weightvec = df$wgt,
    cap = 5,
    verbose = T,
    type = "nolim"
))

# Retrieve weights
weights <- data.frame(rake$caseid, rake$weightvec)
weights <- weights %>%
    rename(
        id = rake.caseid,
        weights = rake.weightvec
    )

# Export to Stata
write_dta(
  weights,
  paste(base_path, "out", "data", "weights.dta", sep="/"),
  version = 14
)
