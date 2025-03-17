# Emily Kurtz
# with Pabitra Chowdhury, Jovin Lasway, and Ryan McWay
# The Null Result Penalty: A Replication Study of Chopra et. al.

# R replication of main results in the study and exploration of associated variables

##### Replicate the main findings - table 3

library(haven) #package needed to read in dta files
setwd("~/GitHub/umn_replication/original-data/data")
cleanedData <- data.frame(read_dta("main_study_cleaned.dta"))
head(cleanedData)




mainModel <- lm(publish ~ low +
                pval + field + unilow + professor + exlow + exhigh
                + vignette
                + as.factor(id)
                , data=cleanedData)
summary(mainModel)


table(cleanedData$publish)
hist(cleanedData$publish, breaks=100)
hist(cleanedData$publish[cleanedData$low==0], breaks=100)
hist(cleanedData$publish[cleanedData$low==1], breaks=100)

hist(cleanedData$publish[cleanedData$professor==0],breaks=100)
hist(cleanedData$publish[cleanedData$professor==1],breaks=100)
t.test(cleanedData$publish~cleanedData$professor)



# table where respondent is the row, vignette is the column, and the publishability is the cell
data <- subset(cleanedData, select=c(publish, vignette, id))
data <- reshape(data, idvar="id", timevar="vignette", direction="wide")
head(data)
cor(data$publish.5, data$publish.3, use="complete.obs")



hist(cleanedData$pagetime[cleanedData$pagetime<600])









ks.test(data$publish.1, data$publish.2)



elk <- read.csv("~/GitHub/umn_replication/R/NullPenalty/emilySampleData.csv")
hist(elk$pctworkers_1, breaks=100)



