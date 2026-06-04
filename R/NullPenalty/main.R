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

plot(data$id, data$publish.1)



hist(cleanedData$pagetime[cleanedData$pagetime<600])



# one of the five papers you should not find an effect




ks.test(data$publish.1, data$publish.2)

ks.test(cleanedData$publish[cleanedData$low==1], cleanedData$publish[cleanedData$low==0])
ks.test(cleanedData$publish[cleanedData$low==1], (100-cleanedData$publish[cleanedData$low==0]))
qqplot(cleanedData$publish[cleanedData$low==1], (100-cleanedData$publish[cleanedData$low==0]))


elk <- read.csv("~/GitHub/umn_replication/R/NullPenalty/emilySampleData.csv")
hist(elk$pctworkers_1, breaks=100)




colMeans(data, na.rm=T)



anes <- read.csv("~/GitHub/umn_replication/R/NullPenalty/anes2020Race.csv")



hist(anes$V202147[anes$V202147 %in% 0:100], breaks=100)
hist(anes$V202173[anes$V202173 %in% 0:100], breaks=100)


















model1 <- lm(publish ~ low +
                  pval + field + unilow + professor + exlow + exhigh
                , data=cleanedData[cleanedData$vignette==1,])
summary(model1)


model2 <- lm(publish ~ low +
               pval + field + unilow + professor + exlow + exhigh
             , data=cleanedData[cleanedData$vignette==2,])
summary(model2)


model3 <- lm(publish ~ low +
               pval + field + unilow + professor + exlow + exhigh
             , data=cleanedData[cleanedData$vignette==3,])
summary(model3)


model4 <- lm(publish ~ low +
               pval + field + unilow + professor + exlow + exhigh
             , data=cleanedData[cleanedData$vignette==4,])
summary(model4)


model5 <- lm(publish ~ low +
               pval + field + unilow + professor + exlow + exhigh
             , data=cleanedData[cleanedData$vignette==5,])
summary(model5)







