# Replication: Do Markets Believe in Transformative AI?

This project replicates the analysis from ["Do Markets Believe in Transformative AI?"](context\paper\w34243-DO-MARKETS-BELIEVE-IN-TRANSFORMATIVE-AI_MinerU__20251024142544.md) by Andrews and Farboodi (NBER Working Paper 34243). The study examines how major AI model releases in 2023-2024 influenced U.S. bond yields using event study methodology with permutation inference.

## Project Overview

### Research Question

Do financial markets respond to major AI model releases by adjusting their expectations about long-term economic growth, as reflected in bond yield movements?

### Key Findings

-   **Long-term Treasury yields decline significantly** around AI model releases (10-15 basis points)
-   **Effects are statistically significant** using permutation inference with 5,000 placebo samples
-   **Long-term bonds show larger effects** than short-term bonds
-   **Effects persist for 15+ days** after the event

### Methodology

-   **Event Study Design**: Analyze bond yield changes around 17 AI model release dates
-   **Permutation Inference**: Test statistical significance using random placebo samples
-   **Data Sources**: FRED for Treasury/TIPS yields, major AI lab releases
-   **Time Period**: 2023-2024 (post-ChatGPT era)

## Project Structure

```         
/workspaces/python-project/
├── data/
│   ├── raw/                    # Raw FRED data
│   └── processed/              # Cleaned datasets
├── scripts/
│   ├── 01_data_retrieval.qmd         # Fetch bond yields via tidyquant
│   ├── 02_data_processing.qmd        # Clean and prepare data
│   ├── 03_event_study.qmd            # Event study analysis
│   ├── 04_permutation_inference.qmd  # 5000 placebo tests
│   └── 05_visualization.qmd          # Generate figures
├── _common.R                   # Shared settings (like r4ds)
└── README.md
```



------------------------------------------------------------------------

*This replication demonstrates the reproducibility of the original analysis while providing additional insights into the methodology and results.*