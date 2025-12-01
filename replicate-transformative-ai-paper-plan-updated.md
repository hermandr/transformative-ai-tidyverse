# Plan to Replicate Transformative AI Paper Analysis

## Project Overview

This project replicates the event study analysis from the paper examining the impact of transformative AI announcements on interest rates using tidyverse principles in R.

## Implementation Status

### Completed Components

#### 1. Data Retrieval (01_data_retrieval.qmd)
- **Status**: Complete
- **Data Sources**:
  - FRED API for US Treasury yields (9 bond series)
  - Manual AI event dates from paper
- **Output Files**:
  - data/raw/bond_yields.csv - Raw yield data
  - data/raw/ai_events.csv - AI announcement dates
  - data/raw/bond_metadata.csv - Bond series metadata

#### 2. Data Processing (02_data_processing.qmd)
- **Status**: Complete with both sequential and parallel implementations
- **Key Features**:
  - Event window analysis (configurable window length)
  - Price change calculations
  - Placebo test generation (500 permutations)
  - Parallel processing using furrr package
  - Progress tracking with progressr
- **Processing Approach**:
  - Separated placebo date generation from plot data calculation
  - Sequential approach for plot data (parallel showed minimal improvement)
  - Symbol-specific date filtering (first/last 15 dates excluded)
- **Output Files**:
  - data/processed/actual_event_long_window.csv
  - data/processed/plot_data_long_window.csv
  - data/processed/placebo_long_window.rds
  - data/processed/placebo_long_window_plot_data.rds

#### 3. Visualization (03_plot_actual_vs_placebo_results.qmd)
- **Status**: Complete
- **Visualizations**:
  - Event window plots comparing actual vs placebo distributions
  - Faceted by bond maturity
  - Mean price changes with 95% quantile bands

#### 4. Helper Functions
- **process_one_events_set.r**: Core function for event study analysis
  - Handles event window calculation
  - Computes price changes and cumulative returns
  - Returns both detailed and plot-ready data
- **_common.R**: Shared configuration and settings
  - Window parameters (EVENT_WINDOWS)
  - Date ranges and filtering indices
  - Number of permutations (N_PERMUTATIONS = 500)

### Data Structures

#### Bond Metadata
- 9 bond series: DGS1, DGS5, DGS10, DGS20, DGS30, DFII5, DFII10, DFII20, DFII30
- Includes maturity years and inflation protection status

#### AI Events
- 18 AI announcement events from the paper
- Date range: 2011-2023
- Includes event descriptions and categories

#### Processed Data Structure
- Placebo replicates: rep_id, symbol, placebo_event_dates, dt, plot_data
- Plot data: symbol, window_index, mean_price_change, se_price_change
- 500 permutations per symbol
- 31 window positions per event (-15 to +15 days)

### Technical Decisions

1. **Parallel Processing**: 
   - Used for placebo date generation (significantly faster)
   - Not used for plot data calculation (minimal benefit)
   - Uses availableCores() - 1 to leave one core free

2. **Data Storage**:
   - CSV for actual events (human-readable)
   - RDS for placebo data (preserves list columns, smaller files)

3. **Event Window**:
   - Configurable via EVENT_WINDOWS in _common.R
   - Current: 15-day window
   - Excludes first/last 15 dates per symbol from placebo candidates

4. **Placebo Testing**:
   - 500 permutations per symbol
   - Symbol-specific sampling
   - Random sampling without replacement

## Next Steps

### In Progress
- Analysis and interpretation of results
- Statistical testing framework
- Additional visualizations

### To Do
1. **Statistical Analysis**
   - Formal hypothesis tests
   - P-value calculations from placebo distribution
   - Effect size measurements

2. **Additional Visualizations**
   - Individual event analysis
   - Time trends in AI impact
   - Comparison across bond maturities

3. **Documentation**
   - Method description
   - Results interpretation
   - Comparison with original paper

4. **Validation**
   - Cross-check results with paper
   - Sensitivity analysis on window length
   - Robustness checks

## Key Parameters (from _common.R)

- PROJECT_START_DATE: "2000-01-03"
- PROJECT_END_DATE: "2024-06-30"
- N_PERMUTATIONS: 500
- WINDOW_LENGTH: 15 (days)

## Dependencies

Core packages:
- tidyverse - Data manipulation and visualization
- fredr - FRED API access
- here - Path management
- furrr - Parallel processing
- progressr - Progress tracking
- lubridate - Date handling
