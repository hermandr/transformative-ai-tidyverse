<!-- 15b79d57-c962-4d23-8529-6b2a9e9f2281 3f8e6cea-dbd4-473e-b7d2-b18d51fd9cd0 -->
# Replication of "Do Markets Believe in Transformative AI?" in R

## Overview

Replicate NBER Working Paper 34243 by Andrews and Farboodi examining how major AI model releases (2023-2024) influenced U.S. bond yields using event study methodology with permutation inference.

## Project Structure

```
/workspaces/python-project/
├── data/
│   ├── raw/              # Raw FRED data
│   ├── processed/        # Cleaned datasets
│   ├── ai_events.csv     # Table 1 from paper
│   └── AGENTS.md
├── scripts/
│   ├── 01_data_retrieval.R
│   ├── 02_data_processing.R
│   ├── 03_event_study.R
│   ├── 04_permutation_inference.R
│   ├── 05_visualization.R
│   └── AGENTS.md
├── output/
│   ├── figures/          # Replicate Figures 2-5
│   ├── tables/           # Replicate Tables 2-4
│   └── AGENTS.md
├── reports/
│   ├── replication_report.qmd
│   ├── _quarto.yml
│   └── AGENTS.md
├── _common.R
└── README.md
```

## Data Sources (Section 3.2)

### Bond Yields from FRED via tidyquant

**Nominal Treasury** (DGS series):

- 1-year: DGS1
- 5-year: DGS5
- 10-year: DGS10
- 20-year: DGS20
- 30-year: DGS30

**TIPS** (DFII series):

- 5-year: DFII5
- 10-year: DFII10
- 20-year: DFII20
- 30-year: DFII30

**Corporate Bonds** (ICE BofA indices):

- Use ICE BofA corporate bond effective yield indices by maturity
- Maturity buckets: 1-3yr, 3-5yr, 5-7yr, 7-10yr, 10-15yr, 15+yr
- **Note**: May need alternative source or manual download for ICE data

### AI Events (Table 1)

From paper, 17 unique release dates in 2023-2024:

**2023 (7 events)**:

- 02/06/2023: Google Bard
- 03/14/2023: OpenAI ChatGPT-4 + Anthropic Claude 1 (same day!)
- 07/11/2023: Anthropic Claude 2
- 11/03/2023: xAI Grok 1
- 11/21/2023: Anthropic Claude 2.1
- 12/06/2023: Google Gemini Pro 1.0

**2024 (11 events)**:

- 02/15/2024: Google Gemini Pro 1.5
- 03/04/2024: Anthropic Claude 3
- 03/28/2024: xAI Grok 1.5
- 05/06/2024: DeepSeek V2
- 05/13/2024: OpenAI ChatGPT-4o
- 06/20/2024: Anthropic Claude 3.5 Sonnet
- 08/13/2024: xAI Grok 2
- 09/05/2024: DeepSeek 2.5
- 12/05/2024: OpenAI o1
- 12/11/2024: Google Gemini 2.0
- 12/26/2024: DeepSeek V3

## Methodology Details

### Event Study (Section 3.3)

**Formula** (Equation 3):

```
Δy_{t,s} = y_{t+s} - y_{t-b}
```

Where:

- t = AI event date
- b = baseline days before event
- s = relative day (can be negative for pre-event)
- y = yield level

**Event Windows**: Two specifications

- Short: ±5 days (b=5, s ranges from -5 to +15)
- Long: ±15 days (b=15, s ranges from -14 to +15)

**Aggregation Statistics**:

- **Median Change**: Median(Δy_{t,s}) across all events t
- **Median Absolute Change**: Median(|Δy_{t,s}|) across all events t

**Why medians?** Robust to outliers given small sample size (17 events)

### Permutation Inference (Section 3.4) - CRITICAL

**Purpose**: Test if yield movements around AI releases are larger than chance

**Procedure**:

1. **Define placebo dates**: All trading days in sample where full event window fits
2. **For each of 5,000 iterations**:

   - Randomly sample K dates (without replacement)
   - K = number of actual AI events with full window in sample
   - Sample uniformly from all eligible placebo dates

3. **Compute test statistics** for each placebo sample:

   - Median Change across K placebo dates
   - Median Absolute Change across K placebo dates

4. **P-value calculation**:

   - Two-sided test
   - P-value = proportion of placebo samples with statistic as extreme as observed
   - Handle ties (yields measured to basis points) by rounding away from significance

5. **Significance levels**: 10% (*) and 5% (**)

**Null hypothesis**: AI releases have no effect on yields AND release dates are random

**Key R implementation notes**:

```r
# Pseudocode for permutation test
n_permutations <- 5000
n_events <- nrow(ai_events)  # K in paper

placebo_stats <- map_dfr(1:n_permutations, ~{
  # Sample K random dates uniformly
  placebo_dates <- sample(eligible_dates, size = n_events, replace = FALSE)
  
  # Compute test statistics for this placebo sample
  compute_event_study_stats(placebo_dates, bond_yields)
})

# Compare actual to placebo distribution
p_value <- mean(abs(placebo_stats$median_change) >= abs(actual_median_change))
```

### Trading Days (Critical Detail)

**MUST use trading days, not calendar days**

- Bond markets closed weekends + federal holidays
- Event windows defined in trading days
- Use bizdays package OR filter to rows with non-NA yields

## Implementation Scripts

### 01_data_retrieval.R

```r
library(tidyverse)
library(tidyquant)

# Treasury and TIPS from FRED
treasury_symbols <- c("DGS1", "DGS5", "DGS10", "DGS20", "DGS30")
tips_symbols <- c("DFII5", "DFII10", "DFII20", "DFII30")

# Retrieve all data
bond_data <- tq_get(
  c(treasury_symbols, tips_symbols),
  get = "economic.data",
  from = "2023-01-01",
  to = "2024-12-31"
)

# Save raw
write_csv(bond_data, "data/raw/bond_yields_raw.csv")
```

**Note**: Corporate bond data may need manual download or alternative API

### 02_data_processing.R

```r
library(tidyverse)
library(lubridate)

# Load data
bond_yields <- read_csv("data/raw/bond_yields_raw.csv")
ai_events <- read_csv("data/ai_events.csv")

# Convert to wide format
yields_wide <- bond_yields %>%
  pivot_wider(names_from = symbol, values_from = price)

# Filter to trading days only (non-NA values)
yields_clean <- yields_wide %>%
  filter(!is.na(DGS10)) %>%  # If DGS10 exists, it's a trading day
  arrange(date)

# Create trading day index for easier window calculations
yields_with_index <- yields_clean %>%
  mutate(trading_day_index = row_number())

write_csv(yields_with_index, "data/processed/bond_yields_processed.csv")
```

### 03_event_study.R

Calculate Δy_{t,s} for actual AI events

```r
library(tidyverse)

# For each event and each relative day s
compute_event_study <- function(event_dates, yields, b_days, s_range) {
  map_dfr(event_dates, function(event_date) {
    # Find baseline date (b trading days before)
    event_idx <- which(yields$date == event_date)
    baseline_idx <- event_idx - b_days
    baseline_yield <- yields[baseline_idx, ]
    
    # Calculate changes for each s in range
    map_dfr(s_range, function(s) {
      target_idx <- event_idx + s
      if (target_idx >= 1 && target_idx <= nrow(yields)) {
        target_yield <- yields[target_idx, ]
        yield_changes <- target_yield[yield_cols] - baseline_yield[yield_cols]
        tibble(
          event_date = event_date,
          relative_day = s,
          bind_cols(yield_changes)
        )
      }
    })
  })
}

# Run for ±5 and ±15 day windows
results_5day <- compute_event_study(ai_events$date, yields, b_days = 5, s_range = -5:15)
results_15day <- compute_event_study(ai_events$date, yields, b_days = 15, s_range = -14:15)
```

### 04_permutation_inference.R

**Most critical script** - implements Section 3.4

```r
library(tidyverse)
library(furrr)  # For parallel processing

# Setup
n_permutations <- 5000
n_events <- nrow(ai_events)

# Eligible placebo dates: all trading days where full window fits
min_window <- 15  # For ±15 day specification
eligible_dates <- yields %>%
  mutate(idx = row_number()) %>%
  filter(
    idx > min_window,  # Need b days before
    idx <= (n() - min_window)  # Need s days after
  ) %>%
  pull(date)

# Run permutation test
plan(multisession, workers = parallel::detectCores() - 1)

placebo_results <- future_map_dfr(1:n_permutations, function(iter) {
  # Sample K random dates
  placebo_dates <- sample(eligible_dates, size = n_events, replace = FALSE)
  
  # Compute event study for placebo
  placebo_changes <- compute_event_study(placebo_dates, yields, b_days = 15, s_range = 15)
  
  # Aggregate: median and median absolute
  tibble(
    iteration = iter,
    median_change_DGS30 = median(placebo_changes$DGS30, na.rm = TRUE),
    median_abs_change_DGS30 = median(abs(placebo_changes$DGS30), na.rm = TRUE)
    # ... repeat for all yield series
  )
}, .options = furrr_options(seed = TRUE))

# Calculate p-values
actual_median <- median(results_15day %>% filter(relative_day == 15) %>% pull(DGS30))
p_value_median <- mean(abs(placebo_results$median_change_DGS30) >= abs(actual_median))

# Save results matching Tables 2-4
write_csv(p_values_table, "output/tables/table2_pvalues_treasury.csv")
```

### 05_visualization.R

Replicate Figures 2-4 with placebo bands

```r
library(ggplot2)

# Example: Figure 2a - Median change for Treasuries
plot_event_study_with_placebo <- function(actual_data, placebo_data, maturity) {
  # Calculate placebo percentiles at each horizon
  placebo_bands <- placebo_data %>%
    group_by(relative_day) %>%
    summarise(
      p50 = quantile(median_change, 0.50),
      p05 = quantile(median_change, 0.05),
      p95 = quantile(median_change, 0.95),
      p025 = quantile(median_change, 0.025),
      p975 = quantile(median_change, 0.975),
      p005 = quantile(median_change, 0.005),
      p995 = quantile(median_change, 0.995)
    )
  
  # Plot
  ggplot() +
    # Placebo bands (90%, 95%, 99%)
    geom_ribbon(data = placebo_bands, aes(x = relative_day, ymin = p005, ymax = p995),
                fill = "gray90", alpha = 0.5) +
    geom_ribbon(data = placebo_bands, aes(x = relative_day, ymin = p025, ymax = p975),
                fill = "gray70", alpha = 0.5) +
    geom_ribbon(data = placebo_bands, aes(x = relative_day, ymin = p05, ymax = p95),
                fill = "gray50", alpha = 0.5) +
    # Actual observed median
    geom_line(data = actual_data, aes(x = relative_day, y = median_change),
              color = "black", linewidth = 1) +
    geom_vline(xintercept = 0, linetype = "dashed", color = "red") +
    labs(
      title = str_glue("Median Change: {maturity}"),
      x = "Days from Event",
      y = "Yield Change (bps)"
    ) +
    theme_minimal()
}
```

## Target Outputs

### Tables (matching paper)

- **Table 1**: AI event dates (from data/ai_events.csv)
- **Table 2**: P-values for Treasury yields (median change & median absolute change, ±5 and ±15 days)
- **Table 3**: P-values for TIPS yields
- **Table 4**: P-values for Corporate bond indices

### Figures (matching paper)

- **Figure 2**: Treasury yields - median & median absolute change with placebo bands
- **Figure 3**: TIPS yields - median & median absolute change with placebo bands
- **Figure 4**: Corporate yields - median & median absolute change with placebo bands
- **Figure 5**: Corporate spreads (optional/extension)

## Key Implementation Challenges

1. **ICE Corporate Bond Data**: May need Bloomberg terminal or manual download
2. **Trading Day Calculations**: Ensure proper handling of weekends/holidays
3. **Computational Time**: 5000 permutations × multiple securities = intensive

   - Use parallel processing (furrr package)
   - Cache intermediate results

4. **Exact Date Matching**: Some events on same day (03/14/2023) - handle carefully

## AGENTS.md Files Content

### data/AGENTS.md

```markdown
# Data Directory

## ai_events.csv
Table 1 from paper - 17 unique AI model release dates in 2023-2024
Columns: date, company, model, notes

## raw/
Bond yield data from FRED via tidyquant
Daily frequency, percentage points
May have missing values on non-trading days

## processed/
Cleaned yields with trading day index
Only trading days (non-NA values)
Ready for event study analysis
```

### scripts/AGENTS.md

```markdown
# Scripts Directory

## Execution Order
1. 01_data_retrieval.R - Fetch from FRED
2. 02_data_processing.R - Clean & prepare
3. 03_event_study.R - Calculate Δy_{t,s}
4. 04_permutation_inference.R - 5000 placebo tests (SLOW)
5. 05_visualization.R - Generate figures

## Style
Follow tidyverse conventions from context/r4ds/
Use %>% pipe, tidy data principles
Source _common.R for shared settings
```

### output/AGENTS.md

```markdown
# Output Directory

## tables/
- table2_pvalues_treasury.csv (replicate Table 2)
- table3_pvalues_tips.csv (replicate Table 3)
- table4_pvalues_corporate.csv (replicate Table 4)

## figures/
- figure2a_treasury_median.png
- figure2b_treasury_absmedian.png
- (etc for Figures 3-4)

All figures include placebo bands (90%, 95%, 99%)
```

## Dependencies

```r
install.packages(c(
  "tidyverse",      # Data manipulation
  "tidyquant",      # FRED data access
  "lubridate",      # Date handling
  "infer",          # Tidyverse-friendly permutation inference
  "bizdays",        # Trading day calendar (optional)
  "knitr",          # Quarto reports
  "kableExtra",     # Tables
  "scales"          # Plot formatting
))
```

### Using `infer` for Permutation Inference

The `infer` package provides tidyverse-friendly permutation testing. Example workflow matching paper's methodology:

```r
library(infer)

# Prepare data: combine actual AI events and all potential placebo dates
bond_data_with_labels <- bind_rows(
  actual_event_yields %>% mutate(event_type = "AI"),
  all_trading_days_yields %>% mutate(event_type = "placebo")
)

# Generate null distribution via permutation (5000 reps matching paper)
null_distribution <- bond_data_with_labels %>%
  specify(response = yield_change, explanatory = event_type) %>%
  hypothesize(null = "independence") %>%
  generate(reps = 5000, type = "permute") %>%
  calculate(stat = "median")

# Calculate observed statistic
observed_stat <- bond_data_with_labels %>%
  filter(event_type == "AI") %>%
  specify(response = yield_change) %>%
  calculate(stat = "median")

# Get p-value (two-sided, matching paper)
p_value <- null_distribution %>%
  get_p_value(obs_stat = observed_stat, direction = "two-sided")

# Visualize with placebo bands
null_distribution %>%
  visualize() +
  shade_p_value(obs_stat = observed_stat, direction = "two-sided")
```

**Why use `infer`?**

- Tidyverse-friendly syntax matching r4ds style
- Handles permutation testing elegantly
- Built-in visualization matching paper's figures
- Widely used in ModernDive textbook
- Cleaner than manual loop implementation

### To-dos

- [ ] Create project directory structure with data/, scripts/, output/, reports/ folders and AGENTS.md files
- [ ] Create _common.R with shared settings following r4ds conventions (knitr opts, ggplot2 theme, etc.)
- [ ] Create data/ai_events.csv with AI model release dates extracted from paper (ChatGPT, GPT-4, Claude, etc.)
- [ ] Write scripts/01_data_retrieval.R using tidyquant to fetch Treasury, TIPS, and corporate bond yields from FRED
- [ ] Write scripts/02_data_processing.R to clean data, handle missing values, calculate yield changes, and create event windows
- [ ] Write scripts/03_event_study.R implementing event study methodology with statistical tests matching paper
- [ ] Write scripts/04_visualization.R to generate key figures showing bond yield movements around AI releases
- [ ] Create reports/replication_report.qmd with full analysis following paper's structure (intro, methods, results, discussion)
- [ ] Create reports/_quarto.yml configuration for HTML and PDF output with appropriate themes
- [ ] Create comprehensive README.md with project overview, setup instructions, and execution steps