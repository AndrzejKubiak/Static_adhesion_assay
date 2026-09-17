library(tidyverse)
library(rstatix)

# =========================
# 1. Load summary files
# =========================

aCD31 <- read_csv("aCD31_summary.csv")
aGFP  <- read_csv("aGFP_summary.csv")
tCD31 <- read_csv("tCD31_summary.csv")
tGFP  <- read_csv("tGFP_summary.csv")


# =========================
# 2. Add group labels
# =========================

aCD31$Condition <- "aCD31"
aGFP$Condition  <- "aGFP"
tCD31$Condition <- "tCD31"
tGFP$Condition  <- "tGFP"


# =========================
# 3. Combine data
# =========================

all_df <- bind_rows(
  aCD31,
  aGFP,
  tCD31,
  tGFP
)

# Set group order
all_df$Condition <- factor(
  all_df$Condition,
  levels = c("aCD31", "aGFP", "tCD31", "tGFP")
)


# =========================
# 4. Kruskal-Wallis test
# =========================

kw_test <- kruskal.test(
  Particles ~ Condition,
  data = all_df
)

print(kw_test)


# =========================
# 5. Dunn's post-hoc test
#    Holm correction
# =========================

posthoc <- all_df %>%
  dunn_test(
    Particles ~ Condition,
    p.adjust.method = "holm"
  )

print(posthoc)

# Show the most important columns
posthoc %>%
  select(group1, group2, p, p.adj, p.adj.signif)


# =========================
# 6. Violin + boxplot
# =========================

p <- ggplot(
  all_df,
  aes(
    x = Condition,
    y = Particles,
    fill = Condition
  )
) +
  
  geom_violin(
    trim = FALSE,
    width = 0.7,
    alpha = 0.25,
    color = NA
  ) +
  
  geom_boxplot(
    width = 0.10,
    linewidth = 0.35,
    outlier.shape = NA,
    fill = "white",
    color = "black"
  ) +
  
  geom_jitter(
    aes(color = Condition),
    width = 0.015,
    size = 2.5,
    alpha = 0.9
  ) +
  
  stat_summary(
    fun = mean,
    geom = "point",
    shape = 18,
    size = 4,
    color = "red"
  ) +
  
  scale_fill_manual(values = c(
    "aCD31" = "#4C72B0",
    "aGFP"  = "#55A868",
    "tCD31" = "#8172B2",
    "tGFP"  = "#C44E52"
  )) +
  
  scale_color_manual(values = c(
    "aCD31" = "#4C72B0",
    "aGFP"  = "#55A868",
    "tCD31" = "#8172B2",
    "tGFP"  = "#C44E52"
  )) +
  
  scale_y_log10() +
  
  scale_x_discrete(
    expand = c(0.05, 0.05)
  ) +
  
  labs(
    x = "",
    y = "Adherent cell count"
  ) +
  
  theme_classic(base_size = 16) +
  
  theme(
    legend.position = "none",
    
    axis.title = element_text(
      face = "bold",
      color = "black"
    ),
    
    axis.text = element_text(
      color = "black"
    )
  )


# Display plot
p


# =========================
# 7. Save figure
# =========================

ggsave(
  "Adherent_cell_count_4_groups.pdf",
  plot = p,
  width = 6,
  height = 4
)

ggsave(
  "Adherent_cell_count_4_groups.png",
  plot = p,
  width = 6,
  height = 4,
  dpi = 600
)


# =========================
# 8. Save statistics
# =========================

write_csv(
  posthoc,
  "Adherent_cell_count_Dunn_posthoc.csv"
)