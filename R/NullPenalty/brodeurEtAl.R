library(haven)
data <- as.data.frame(read_dta("MM Data.dta"))
head(data)
summary(data$t)
sort(data$t, decreasing=TRUE)
summary(as.factor(data$method))
subdata <- data[data$method=="RCT"&data$t>7,]
# cases are not just papers but hypotheses - going to randomly sample papers
uniquePapers <- unique(subdata$title)
write.csv(uniquePapers, "EconPapersWithLargeZ.csv")
set.seed(21740)
sample(uniquePapers, 10)
# or I can use the papers with JEL codes B4X or D8X - get from abstract here: https://papers.ssrn.com/sol3/DisplayAbstractSearch.cfm
# or click browse by jel code


library(ggplot2)

ggplot(
  data[data$t <= 10 & data$method == "RCT", ],
  aes(x = t)
) +
  geom_histogram(
    binwidth = 0.1,
    boundary = 0,
    fill = "grey70",
    color = "grey70"
  ) +
  geom_density(
    adjust = 0.1 / bw.nrd0(data$t[data$t <= 10 & data$method == "RCT"]),
    color = "black"
  ) +
  geom_vline(
    xintercept = c(1.65, 1.96, 2.58),
    linewidth = 0.3
  ) +
  scale_x_continuous(
    limits = c(0, 10),
    breaks = seq(0, 10, by = 1)
  ) +
  labs(
    title = "RCT",
    x = "z-statistic",
    y = NULL
  ) +
  theme_bw() +
  theme(
    legend.position = "none"
  )

ggsave("temp1.png", width = 7, height = 5)
