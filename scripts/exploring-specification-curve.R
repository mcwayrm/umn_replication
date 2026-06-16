# Description: Create Specification Curve of Results

#########################
# Preamble
#########################
# Clear environment and set encoding
rm(list=ls())
# Necessary Dependencies
library(rio) # Import any data type
library(ggplot2) # plots
library(data.table) # Processing data frames
library(dplyr)
library(tidyr)
library(patchwork)

#########################
# Directories 
#########################
path_data = "E:/umn_replication/df-spec-curve.xlsx" # specification curve data 
path_out = "E:/umn_replication/outputs/" # output folder

#########################
# 1. Construct Specificaiton Curve Data
#########################

# Data: Results by Analytical Choice
df <- setDT(import(path_data))

# 1. Calculate confidence intervals and order specifications
plot_data <- df %>%
    mutate(
        ci_lower = point - 1.96 * se,
        ci_upper = point + 1.96 * se,
        preferred_flag = tolower(as.character(preferred_spec)) %in% c("1", "true", "t", "yes", "y")
    ) %>%
    arrange(point) %>% # Sort estimates for the curve
    mutate(rank = row_number()) # Assign new rank to map bottom panel

# 2. Reshape analytical choices for the bottom panel (make long format)
choice_cols <- intersect(
    c( "Source", "Software", "Sample", "Fixed_Effects", "Vignette_Feature", "Controls", "Weights", "Multiple_Hypothesis_Testing"),
    names(plot_data)
)

specs_long <- plot_data %>%
    select(rank, point, ci_lower, ci_upper, all_of(choice_cols)) %>%
    pivot_longer(cols = all_of(choice_cols), names_to = "choice", values_to = "applied")

#########################
# 2. Produce Graphic
#########################

# Top Panel: Specification Curve
p_curve <- ggplot(plot_data, aes(x = rank, y = point)) +
    geom_point(size = 1, color = "gray50") +
    geom_errorbar(aes(ymin = ci_lower, ymax = ci_upper), width = 0, color = "gray50") +
    geom_errorbar(
        data = plot_data %>% filter(preferred_flag),
        aes(ymin = ci_lower, ymax = ci_upper),
        width = 0,
        color = "red3",
        linewidth = 0.6
    ) +
    geom_point(
        data = plot_data %>% filter(preferred_flag),
        size = 1.6,
        color = "red3"
    ) +
    geom_hline(yintercept = 0, linetype = "dashed") +
    theme_minimal() +
    theme(axis.title.x=element_blank(),
        axis.text.x=element_blank(),
        axis.ticks.x=element_blank()) +
    scale_x_continuous(limits = c(1, max(plot_data$rank)), expand = c(0.01, 0)) +
    labs(y = "Estimated Effect", x = "")
p_curve

# Build grouped y-axis rows: bold header for each choice + one row per observed option
specs_rows <- specs_long %>%
    mutate(
        choice = factor(choice, levels = choice_cols),
        applied_label = if_else(is.na(applied), "Missing", as.character(applied)),
        y_level = paste(choice, applied_label, sep = "::")
    )

option_levels <- specs_rows %>%
    distinct(choice, applied_label, y_level) %>%
    arrange(choice, applied_label) %>%
    group_by(choice) %>%
    mutate(order_in_choice = row_number()) %>%
    ungroup() %>%
    mutate(y_label = applied_label)

header_levels <- tibble(
    choice = factor(choice_cols, levels = choice_cols),
    y_level = paste(choice_cols, "__header", sep = "::"),
    y_label = gsub("_", " ", as.character(choice_cols)),
    order_in_choice = 0L
)

axis_layout <- bind_rows(header_levels, option_levels %>% select(choice, y_level, y_label, order_in_choice)) %>%
    arrange(choice, order_in_choice) %>%
    mutate(y_pos = rev(seq_len(n())) * 1.8)

label_exprs <- lapply(seq_len(nrow(axis_layout)), function(i) {
    if (axis_layout$order_in_choice[i] == 0L) {
        bquote(bold(underline(.(axis_layout$y_label[i]))))
    } else {
        bquote(.(paste0("  ", axis_layout$y_label[i])))
    }
})
names(label_exprs) <- axis_layout$y_level
label_exprs <- as.expression(label_exprs)

y_levels <- rev(axis_layout$y_level)

specs_rows <- specs_rows %>%
    left_join(axis_layout %>% select(y_level, y_pos), by = "y_level")

# Bottom Panel: Analytical Choices
p_specs <- ggplot(specs_rows, aes(x = rank, y = y_pos)) +
    geom_point(shape = 15, size = 2, color = "gray25") + 
    scale_x_continuous(limits = c(1, max(plot_data$rank)), expand = c(0.01, 0)) +
    scale_y_continuous(
        limits = range(axis_layout$y_pos) + c(-0.9, 0.9),
        breaks = axis_layout$y_pos,
        labels = as.expression(unname(label_exprs[axis_layout$y_level])),
        expand = expansion(mult = c(0.02, 0.02))
    ) +
    theme_minimal() +
    theme(
        axis.text.y = element_text(hjust = 1, size = 9, lineheight = 1.15),
        legend.position = "none",
        panel.grid.minor = element_blank(),
        plot.margin = margin(5.5, 5.5, 5.5, 20)
    ) +
    labs(y = "Analytical Choice", x = "Specificastion Rank")
p_specs

# Combine the plots
combined_plot <- patchwork::wrap_plots(
    p_curve,
    p_specs,
    ncol = 1,
    heights = c(2, 5)
)

combined_plot
# Save the plot
ggsave(filename = paste0(path_out, "spec-curve.png"), plot = last_plot(), width = 8, height = 6)

