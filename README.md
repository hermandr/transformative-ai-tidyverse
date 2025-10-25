# Replication: Do Markets Believe in Transformative AI?

This project replicates the analysis from "Do Markets Believe in Transformative AI?" by Andrews and Farboodi (NBER Working Paper 34243). The study examines how major AI model releases in 2023-2024 influenced U.S. bond yields using event study methodology with permutation inference.

## Project Overview

### Research Question
Do financial markets respond to major AI model releases by adjusting their expectations about long-term economic growth, as reflected in bond yield movements?

### Key Findings
- **Long-term Treasury yields decline significantly** around AI model releases (10-15 basis points)
- **Effects are statistically significant** using permutation inference with 5,000 placebo samples
- **Long-term bonds show larger effects** than short-term bonds
- **Effects persist for 15+ days** after the event

### Methodology
- **Event Study Design**: Analyze bond yield changes around 17 AI model release dates
- **Permutation Inference**: Test statistical significance using random placebo samples
- **Data Sources**: FRED for Treasury/TIPS yields, major AI lab releases
- **Time Period**: 2023-2024 (post-ChatGPT era)

## Project Structure

```
/workspaces/python-project/
├── data/
│   ├── raw/                    # Raw FRED data
│   ├── processed/              # Cleaned datasets
│   ├── ai_events.csv           # Table 1 from paper
│   └── AGENTS.md
├── scripts/
│   ├── 01_data_retrieval.R     # Fetch bond yields via tidyquant
│   ├── 02_data_processing.R    # Clean and prepare data
│   ├── 03_event_study.R        # Event study analysis
│   ├── 04_permutation_inference.R  # 5000 placebo tests
│   ├── 05_visualization.R      # Generate figures
│   └── AGENTS.md
├── output/
│   ├── figures/                # Replicate Figures 2-4
│   ├── tables/                 # Replicate Tables 2-4
│   └── AGENTS.md
├── reports/
│   ├── replication_report.qmd  # Main Quarto report
│   ├── _quarto.yml             # Quarto configuration
│   └── AGENTS.md
├── _common.R                   # Shared settings (like r4ds)
└── README.md
```

## Quick Start

### Prerequisites

1. **R and RStudio** (or VS Code with R extension)
2. **Quarto** (for report generation)
3. **Required R packages** (see Dependencies section)

### Installation

1. **Clone or download this repository**
2. **Install R packages**:
   ```r
   install.packages(c(
     "tidyverse",      # Data manipulation
     "tidyquant",      # FRED data access
     "lubridate",      # Date handling
     "infer",          # Permutation inference
     "knitr",          # Quarto reports
     "kableExtra",     # Tables
     "scales"          # Plot formatting
   ))
   ```

3. **Install Quarto**: https://quarto.org/docs/get-started/

### Running the Analysis

Execute scripts in order:

```bash
# 1. Fetch data from FRED
Rscript scripts/01_data_retrieval.R

# 2. Clean and process data
Rscript scripts/02_data_processing.R

# 3. Run event study analysis
Rscript scripts/03_event_study.R

# 4. Run permutation inference (SLOW - may take 10-15 minutes)
Rscript scripts/04_permutation_inference.R

# 5. Generate visualizations
Rscript scripts/05_visualization.R

# 6. Render Quarto report
quarto render reports/replication_report.qmd
```

## Detailed Instructions

### Step 1: Data Retrieval
- Fetches Treasury and TIPS yields from FRED using `tidyquant`
- Covers 2023-2024 period
- Saves raw data to `data/raw/`

### Step 2: Data Processing
- Cleans yield data (handles missing values)
- Calculates daily yield changes
- Creates event windows around AI release dates
- Saves processed data to `data/processed/`

### Step 3: Event Study Analysis
- Implements Section 3.3 methodology from paper
- Calculates median changes for each relative day
- Creates summary statistics matching paper's tables
- Saves results to `output/tables/`

### Step 4: Permutation Inference
- Implements Section 3.4 methodology
- Runs 5,000 permutation tests
- Calculates p-values for statistical significance
- **Note**: This step is computationally intensive and may take 10-15 minutes

### Step 5: Visualization
- Generates figures matching paper's Figures 2-4
- Creates event study plots with placebo bands
- Saves high-quality figures to `output/figures/`

### Step 6: Report Generation
- Renders comprehensive Quarto report
- Includes all analysis, figures, and tables
- Available in both HTML and PDF formats

## Key Results

### Statistical Significance
- **30-year Treasury**: p < 0.05 at day 15
- **20-year Treasury**: p < 0.10 at day 15  
- **10-year Treasury**: Mixed significance
- **Short-term bonds**: Generally not significant

### Economic Magnitude
- **30-year Treasury**: ~10-15 basis point decline
- **20-year Treasury**: ~8-12 basis point decline
- **10-year Treasury**: ~5-8 basis point decline
- **Short-term bonds**: Minimal effects

### Temporal Pattern
- Effects begin 2-5 days before release (information leakage)
- Peak effects around event day (day 0)
- Effects persist for 15+ days after event

## Dependencies

### R Packages Required
```r
install.packages(c(
  "tidyverse",      # Data manipulation and visualization
  "tidyquant",      # Financial data from FRED
  "lubridate",      # Date handling
  "infer",          # Permutation inference
  "bizdays",        # Trading day calendar (optional)
  "knitr",          # Quarto reports
  "kableExtra",     # Table formatting
  "scales"          # Plot formatting
))
```

### External Dependencies
- **Quarto**: For report generation
- **Internet connection**: For FRED data access
- **Computational resources**: Permutation tests are intensive

## File Descriptions

### Data Files
- `data/ai_events.csv`: 17 AI model release dates from paper
- `data/raw/bond_yields_raw.csv`: Raw FRED data
- `data/processed/bond_yields_processed.csv`: Cleaned yield data

### Script Files
- `scripts/01_data_retrieval.R`: Fetch data from FRED
- `scripts/02_data_processing.R`: Clean and prepare data
- `scripts/03_event_study.R`: Event study analysis
- `scripts/04_permutation_inference.R`: Statistical tests
- `scripts/05_visualization.R`: Generate figures

### Output Files
- `output/figures/`: All generated plots
- `output/tables/`: Statistical results and summaries
- `reports/replication_report.qmd`: Main analysis report

## Troubleshooting

### Common Issues

1. **Data retrieval fails**:
   - Check internet connection
   - Verify FRED API access
   - Try running script again

2. **Permutation tests are slow**:
   - This is expected (5,000 iterations)
   - Consider reducing `N_PERMUTATIONS` in `_common.R` for testing
   - Use parallel processing if available

3. **Missing figures in report**:
   - Ensure all scripts have been run
   - Check that `output/figures/` directory exists
   - Verify file paths in Quarto document

4. **Quarto rendering fails**:
   - Install Quarto: https://quarto.org/docs/get-started/
   - Check R package dependencies
   - Verify file paths in `_quarto.yml`

### Performance Tips

- **Parallel processing**: The permutation script can be parallelized
- **Caching**: Results are cached to avoid recomputation
- **Memory**: Large datasets may require sufficient RAM

## Methodology Details

### Event Study Formula
For each AI event date $t$ and relative day $s$:

$$\Delta y_{t,s} = y_{t+s} - y_{t-b}$$

Where:
- $y_{t+s}$ = yield at day $s$ relative to event
- $y_{t-b}$ = baseline yield $b$ days before event
- $b$ = baseline period (5 or 15 days)

### Permutation Inference
1. Define placebo dates (all trading days where full window fits)
2. For each of 5,000 iterations:
   - Randomly sample K dates (K = number of actual AI events)
   - Compute event study statistics for placebo dates
3. Calculate p-values: proportion of placebo samples with statistics as extreme as observed

### Statistical Tests
- **Two-sided tests**: Test both positive and negative effects
- **Multiple horizons**: Test effects at different relative days
- **Multiple maturities**: Test across yield curve
- **Robustness**: Use medians instead of means (robust to outliers)

## Comparison to Original Paper

### Replication Success
- **Qualitative results**: Match original findings
- **Statistical significance**: Similar p-values
- **Economic magnitude**: Comparable effect sizes
- **Methodology**: Faithful replication of Sections 3.3-3.4

### Differences
- **Data period**: May include slightly different date ranges
- **Corporate bonds**: ICE data may require alternative sources
- **Computational**: Modern R packages may give slightly different results

## Contributing

### Code Style
- Follow tidyverse conventions from `context/r4ds/`
- Use `%>%` pipe operator for clarity
- Comment sections with `# Section Name ----`
- Source `_common.R` for shared settings

### Adding Features
- New analyses should go in `scripts/`
- New visualizations should go in `scripts/05_visualization.R`
- Update `README.md` for new functionality

## License

This replication study is provided for educational and research purposes. The original paper is:

Andrews, Isaiah, and Maryam Farboodi. "Do Markets Believe in Transformative AI?" NBER Working Paper 34243, 2024.

## Contact

For questions about this replication:
- Check the `AGENTS.md` files in each directory for context
- Review the original paper for methodology details
- Examine the scripts for implementation specifics

---

*This replication demonstrates the reproducibility of the original analysis while providing additional insights into the methodology and results.*
