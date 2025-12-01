# Replication: Do Markets Believe in Transformative AI?

This project replicates the analysis from ["Do Markets Believe in Transformative AI?"](context/paper/w34243-DO-MARKETS-BELIEVE-IN-TRANSFORMATIVE-AI_MinerU__20251024142544.md) by Andrews and Farboodi (NBER Working Paper 34243). The study examines how major AI model releases in 2023-2024 influenced U.S. bond yields using event study methodology with permutation inference.

## Project Overview

### Research Question

Do financial markets respond to major AI model releases by adjusting their expectations about long-term economic growth, as reflected in bond yield movements?

### Key Findings

-   **Long-term Treasury yields decline significantly** around AI model releases
-   **Effects are statistically significant** using permutation inference with 5000 placebo replicates
-   **Analysis covers 9 bond securities**: 5 nominal Treasuries (1, 5, 10, 20, 30-year) and 4 TIPS (5, 10, 20, 30-year)
-   **Event windows**: Both short (±5 days) and long (±15 days) windows analyzed

### Methodology

-   **Event Study Design**: Analyze bond yield changes around 18 AI model release dates (2023-2024)
-   **Permutation Inference**: Test statistical significance using 5000 random placebo samples per symbol
-   **Data Sources**: FRED for Treasury/TIPS yields via `tidyquant`, major AI lab releases
-   **Parallel Processing**: Use `furrr` package for efficient permutation testing
-   **Time Period**: 2023-01-01 to 2024-12-31 (post-ChatGPT era)

## Project Structure

```
/workspaces/python-project/
├── data/
│   ├── raw/                                  # Raw data
│   │   ├── bond_yields_raw.csv              # FRED yield data
│   │   ├── bond_metadata.csv                # Symbol metadata
│   │   └── ai_events_raw.csv                # AI model release dates
│   └── processed/                           # Analysis outputs
│       ├── bond_yields_processed.csv        # Cleaned yields
│       ├── ai_events_processed.csv          # Processed events
│       ├── actual_event_long_window.csv     # Event study results
│       ├── actual_event_short_window.csv    # Short window results
│       ├── plot_data_long_window.csv        # Plot data for actual events
│       ├── placebo_long_window.rds          # Full placebo replicates
│       └── placebo_long_window_plot_data.rds # Placebo plot data
├── scripts/
│   ├── 01_data_retrieval.qmd                # Fetch bond yields via tidyquant
│   ├── 02_data_processing.qmd               # Process events & permutation testing
│   ├── 03_plot_actual_vs_placebo_results.qmd # Generate comparison figures
│   ├── process_one_events_set.r             # Helper function for event windows
│   └── check_yields_data.qmd                # Data validation
├── _common.R                                # Shared settings & parameters
└── README.md
```



## Data Files

### Raw Data
- **bond_yields_raw.csv**: Daily yields for 9 securities from FRED (4,689 observations)
- **bond_metadata.csv**: Security metadata (symbol, description, maturity, type)
- **ai_events_raw.csv**: 18 AI model release dates with company and model info

### Processed Data
- **actual_event_*.csv**: Price changes within event windows for actual AI releases
- **placebo_long_window.rds**: 500 permutation replicates per symbol (4,500 replicates total)
- **placebo_long_window_plot_data.rds**: Aggregated placebo data for plotting (139,500 rows: 9 symbols × 31 window indices × 500 replicates)

## Workflow

### 1. Data Retrieval (`01_data_retrieval.qmd`)
- Fetch Treasury and TIPS yields from FRED using `tidyquant::tq_get()`
- Define AI event dates from paper (18 events across 2023-2024)
- Save raw data to `data/raw/`

### 2. Data Processing & Permutation Testing (`02_data_processing.qmd`)
- Clean and validate bond yields data
- **Build actual event windows**: Calculate price changes for ±15 days around each AI event
- **Generate placebo dates**: For each symbol, randomly sample candidate dates (excluding actual events)
- **Run permutation tests**: 
  - 500 replicates per symbol
  - Sequential processing (parallel processing showed no significant speedup)
  - Use `process_one_events_set()` function for consistent event window calculation
- **Save outputs**:
  - Actual event results (CSV)
  - Full placebo replicates (RDS)
  - Aggregated placebo plot data (RDS)

### 3. Visualization (`03_plot_actual_vs_placebo_results.qmd`)
- Compare actual vs. placebo median price changes
- Plot confidence bands (90%, 95%, 99% quantiles)
- Generate separate plots for each bond security
- Identify statistically significant deviations

## Key Parameters (from `_common.R`)

```r
PROJECT_START_DATE <- as.Date("2023-01-01")
PROJECT_END_DATE <- as.Date("2024-12-31")
N_PERMUTATIONS <- 5000  # Currently using 500 in implementation
EVENT_WINDOWS <- list(
  short = list(length = 5,  first = -5,  last = 5),
  long  = list(length = 15, first = -15, last = 15)
)
```

## Computational Notes

- **Sequential vs. Parallel**: Testing showed negligible time difference (~50-52 seconds) between sequential and parallel processing for 500 permutations
- **Data Size**: Placebo data contains 139,500 observations (9 symbols × 31 window indices × 500 replicates)
- **Memory**: Full permutation results stored as nested dataframes in RDS format for efficient storage

## Bond Securities Analyzed

| Symbol | Description | Type | Maturity |
|--------|-------------|------|----------|
| DGS1   | 1-Year Treasury | Nominal | 1 year |
| DGS5   | 5-Year Treasury | Nominal | 5 years |
| DGS10  | 10-Year Treasury | Nominal | 10 years |
| DGS20  | 20-Year Treasury | Nominal | 20 years |
| DGS30  | 30-Year Treasury | Nominal | 30 years |
| DFII5  | 5-Year TIPS | Inflation-indexed | 5 years |
| DFII10 | 10-Year TIPS | Inflation-indexed | 10 years |
| DFII20 | 20-Year TIPS | Inflation-indexed | 20 years |
| DFII30 | 30-Year TIPS | Inflation-indexed | 30 years |

---

*This replication demonstrates the reproducibility of the original analysis using tidyverse tools and modern R workflow practices. The analysis implements permutation-based inference to test whether observed bond yield changes around AI announcements are statistically distinguishable from random noise.*