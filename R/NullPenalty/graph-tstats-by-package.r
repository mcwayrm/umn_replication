#########################
# Preamble
#########################
# Clear environment and set encoding
rm(list=ls())
# Necessary Dependencies
library(rio) # Import any data type
library(ggplot2) # plots
library(data.table) # data frames


#########################
# Directories 
#########################
path_data = "E:/umn_replication/R/NullPenalty/articlesWithMatches.csv" # article match data
path_data2 = "E:/umn_replication/R/NullPenalty/MM Data.dta" # pvalue data
path_out = "E:/umn_replication/outputs/" # output folder

#########################
# 1. Create Graphic
#########################

# Data
df <- setDT(import(path_data))
df_values <- setDT(import(path_data2))

# Merge
df2 <- left_join(df_values, df, by = "title")

# Match indicator: 1 if any replication match source is present, otherwise 0.
df2[, match := fifelse(!is.na(dvMatch) | !is.na(zenMatch) | !is.na(icpsrMatch), 1L, 0L)]
df2[, t_num := suppressWarnings(as.numeric(t))]
df2[, match_f := factor(match, levels = c(0, 1), labels = c("No", "Yes"))]

# Trim extreme tails to avoid pathological bin counts from outlier t values.
x_limits <- quantile(df2[is.finite(t_num), t_num], probs = c(0.005, 0.995), na.rm = TRUE, names = FALSE)
plot_dt <- df2[is.finite(t_num) & t_num >= x_limits[1] & t_num <= x_limits[2]]

mean_dt <- plot_dt[, .(mean_t = mean(t_num, na.rm = TRUE)), by = match_f]

ggplot(plot_dt, aes(x = t_num, color = match_f)) +
    geom_freqpoly(binwidth = 0.1, linewidth = 1, na.rm = TRUE) +
    geom_vline(
        data = mean_dt,
        aes(xintercept = mean_t, color = match_f),
        linetype = "dashed", linewidth = 0.8
    ) +
    scale_color_manual(values = c("No" = "#ff7a0e", "Yes" = "#1f77b4"), drop = FALSE) +
    labs(
        title = "Frequency of t-statistics by Replication Packet",
        x = "t-statistic",
        y = "Frequency",
        color = "Replication Packet Avaliable"
    ) +
    theme_minimal() +
    theme(
        legend.position = "bottom",
        legend.direction = "horizontal"
    )

# Save the plot
ggsave(filename = paste0(path_out, "graph-tstat-by-package.png"), plot = last_plot(), width = 8, height = 6)

