# Common settings for Transformative AI Replication Project
# Following r4ds conventions

# Set seed for reproducibility
set.seed(1014)

# Knitr options for code chunks
knitr::opts_chunk$set(
  comment = "#>",
  collapse = TRUE,
  cache = TRUE,
  fig.retina = 2,
  fig.width = 6,
  fig.asp = 2 / 3,
  fig.show = "hold"
)

# General options
options(
  dplyr.print_min = 6,
  dplyr.print_max = 6,
  pillar.max_footer_lines = 2,
  pillar.min_chars = 15,
  stringr.view_n = 6,
  # Temporarily deactivate cli output for quarto
  cli.num_colors = 0,
  cli.hyperlink = FALSE,
  pillar.bold = TRUE,
  width = 77 # 80 - 3 for #> comment
)

# Set ggplot2 theme
ggplot2::theme_set(ggplot2::theme_gray(12))

# Load common packages
library(tidyverse)
library(lubridate)
library(scales)
library(knitr)
library(kableExtra)
library(here)

# Project-specific settings
PROJECT_START_DATE <- as.Date("2023-01-01")
PROJECT_END_DATE <- as.Date("2024-12-31")
N_PERMUTATIONS <- 5000
EVENT_WINDOWS <- list(
  short = list(b = 5, s_range = -5:5),
  long = list(b = 15, s_range = -15:15)
)

# FRED symbols for bond yields
TREASURY_SYMBOLS <- c("DGS1", "DGS5", "DGS10", "DGS20", "DGS30")
TIPS_SYMBOLS <- c("DFII5", "DFII10", "DFII20", "DFII30")
METADATA <- tibble(
  data_name=c(TREASURY_SYMBOLS, TIPS_SYMBOLS),
  description=c(
    "Market Yield on U.S. Treasury Securities at 1-Year Constant Maturity, Quoted on an Investment Basis (Nominal)",
    "Market Yield on U.S. Treasury Securities at 5-Year Constant Maturity, Quoted on an Investment Basis (Nominal)",
    "Market Yield on U.S. Treasury Securities at 10-Year Constant Maturity, Quoted on an Investment Basis (Nominal)",
    "Market Yield on U.S. Treasury Securities at 20-Year Constant Maturity, Quoted on an Investment Basis (Nominal)",
    "Market Yield on U.S. Treasury Securities at 30-Year Constant Maturity, Quoted on an Investment Basis (Nominal)",
    "Market Yield on U.S. Treasury Securities at 5-Year Constant Maturity, Quoted on an Investment Basis, Inflation-Indexed (TIPS yield)",
    "Market Yield on U.S. Treasury Securities at 10-Year Constant Maturity, Quoted on an Investment Basis, Inflation-Indexed (TIPS yield)",
    "Market Yield on U.S. Treasury Securities at 20-Year Constant Maturity, Quoted on an Investment Basis, Inflation-Indexed (TIPS yield)",
    "Market Yield on U.S. Treasury Securities at 30-Year Constant Maturity, Quoted on an Investment Basis, Inflation-Indexed (TIPS yield)"
  ),
  data_group = c(rep("Treasury Yield",5), rep("TIPS Yield",4))
)

# Print project info
cat("Transformative AI Replication Project\n")
cat("=====================================\n")
cat("Start Date:", as.character(PROJECT_START_DATE), "\n")
cat("End Date:", as.character(PROJECT_END_DATE), "\n")
cat("Permutations:", N_PERMUTATIONS, "\n")
cat("Symbols:")
kable(METADATA)