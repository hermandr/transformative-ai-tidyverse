# Comprehensive Quarto Style Guide

This document outlines the styling and conventions for authoring Quarto (`.qmd`) documents, combining best practices for consistency, professionalism, and reproducibility.

## File Structure

*   **Extension:** Use the `.qmd` extension for Quarto files.
*   **YAML Header:** All documents must start with a YAML header, enclosed in `---`.
*   **Code Chunks:** R code is placed in code chunks, which start with ` ```{r} ` and end with ` ``` `.
*   **Text:** Narrative and prose are written in Markdown.

## YAML Header

The YAML header is used to set document-level options.

### Basic Structure

A minimal YAML header should include:

```yaml
---
title: "Clear, descriptive title"
author: "Author Name"
date: "`r Sys.Date()`"
format:
  html:
    toc: true
    number-sections: true
    theme: default
---
```

### Extended Metadata

For academic or more detailed documents, include extended metadata:

```yaml
---
title: "Your Document Title"
subtitle: "Additional context if needed"
author: 
  - name: "Author Name"
    orcid: "0000-0000-0000-0000"
    affiliation: "Institution"
date: "`r Sys.Date()`"
format:
  html:
    toc: true
    toc-depth: 2
    number-sections: true
    theme: cosmo
    highlight-style: github
    code-fold: show
    df-print: paged
    fig-width: 8
    fig-height: 6
abstract: "Brief summary of the document content and findings."
keywords: 
  - R
  - tidyverse
  - data-analysis
bibliography: references.bib
csl: apa.csl
embed-resources: true
---
```

### Output Format Options

#### HTML Documents
```yaml
format:
  html:
    theme: cosmo
    highlight-style: github
    toc: true
    toc-location: left
    toc-depth: 3
    number-sections: true
    number-depth: 2
    code-fold: show
    code-summary: "Show code"
    code-overflow: wrap
    fig-width: 8
    fig-height: 6
    fig-dpi: 300
    df-print: paged
    smooth-scroll: true
    embed-resources: true
```

#### PDF Documents
```yaml
format:
  pdf:
    documentclass: article
    geometry: 
      - top=1in
      - bottom=1in
      - left=1in
      - right=1in
    number-sections: true
    toc: true
    toc-depth: 2
    fig-pos: "H"
    fig-cap-location: bottom
    colorlinks: true
```

#### Multiple Formats
```yaml
format:
  html:
    toc: true
    theme: cosmo
  pdf:
    documentclass: article
    geometry: margin=1in
  docx:
    reference-doc: template.docx
```

## Code Chunk Configuration

### Global Setup Chunk

Always include a `setup` chunk at the beginning of the document after the YAML header. This chunk will be run automatically before any other code.

````r
#| label: setup
#| include: false

# knitr settings
knitr::opts_chunk$set(
  # Code output:
  warning = FALSE,
  message = FALSE,
  echo = TRUE,
  # Figure:
  out.width = "100%",
  fig.width = 8,
  fig.height = 6,
  fig.align = "center",
  # Etc:
  collapse = TRUE,
  comment = "#>"
)

# Load required packages
library(tidyverse)
library(moderndive)
library(knitr)
library(gt)

# Set random seed for reproducibility
set.seed(42)
````

### Code Chunk Options

Quarto uses execution options with the `#|` syntax. All code chunks should have a descriptive, hyphenated label.

| Option | Purpose | Example |
|---|---|---|
| `label` | Unique identifier for the chunk | `label: data-import` |
| `echo: true` | Show code (default) | `echo: true` |
| `echo: false` | Hide the code but show the results | `echo: false` |
| `eval: false` | Don't run code (for examples) | `eval: false` |
| `include: false` | Run code but don't show code or output | `include: false` |
| `warning: false` | Suppress warnings | `warning: false` |
| `message: false` | Suppress messages | `message: false` |
| `results: hide` | Hides the output of the code | `results: hide` |
| `fig-show: hide` | Hides plots | `fig-show: hide` |
| `error: true` | Continue rendering even if code errors | `error: true` |
| `fig-cap` | Figure caption | `fig-cap: "Scatterplot showing..."` |
| `tbl-cap` | Table caption | `tbl-cap: "Summary statistics"` |
| `out-width` | Control output width | `out-width: "80%"` |

### Caching

Use caching to save time on computationally expensive chunks.

*   **Enable Caching:** Use `cache: true` to cache the results of a chunk.
*   **Dependencies:** Use the `dependson` option to specify dependencies between cached chunks. If `chunk-A` depends on `chunk-B`, `chunk-A` will be re-run if `chunk-B` changes.

## Code Style

### Loading Libraries

Group all library calls in a dedicated chunk at the beginning of the document, after the `setup` chunk.

````r
#| label: libraries
#| message: false

# Core tidyverse packages
library(dplyr)
library(ggplot2)
library(readr)

# Other packages
library(moderndive)
library(gt)
````

### Data Processing

Use clear, descriptive variable names and the modern pipe operator `|>`.

````r
#| label: data-processing

evals_sample <- evals |>
  select(ID, score, age, bty_avg, gender) |>
  sample_n(100) |>
  mutate(
    score_category = case_when(
      score >= 4.5 ~ "Excellent",
      score >= 3.5 ~ "Good", 
      .default = "Poor"
    )
  )
````

## Documentation and Comments

### Section Headers

Use a clear hierarchical structure for sections (`#`, `##`, `###`).

### Inline Comments

Provide context for complex operations or logical steps within a code chunk.

````r
#| label: complex-transformation

# Transform data for visualization:
# 1. Group by relevant categories
# 2. Calculate summary statistics  
summary_stats <- evals |>
  group_by(ethnicity, gender) |>
  summarise(
    mean_score = mean(score, na.rm = TRUE),
    n_observations = n(),
    .groups = "drop"
  ) |>
  # Only include groups with sufficient data
  filter(n_observations >= 10)
````

### Code Explanations

Include explanatory text in Markdown between code chunks to narrate your analysis.

## Figures

### Figure Standards

Use a consistent `ggplot2` structure. Use a chunk label with a `fig-` prefix (e.g., `label: fig-my-plot`) to allow for cross-referencing.

*   **Sizing:** Use `fig-width` and `fig-asp` to control the aspect ratio and `out-width` (e.g., `"70%"`) to control the final display size.
*   **Alignment:** Use `fig-align: center` to center figures.
*   **Captions:** Use `fig-cap` to add a descriptive caption.

````r
#| label: fig-scatter-plot
#| fig-cap: "Relationship between age and teaching score by ethnicity."
#| fig-width: 10
#| fig-height: 6
#| out-width: "90%"

ggplot(evals, aes(x = age, y = score, color = ethnicity)) +
  geom_point(alpha = 0.7) +
  geom_smooth(method = "lm", se = FALSE) +
  labs(
    title = "Teaching Score vs. Age by Ethnicity",
    x = "Professor Age (years)",
    y = "Teaching Score (1-5 scale)",
    color = "Ethnicity"
  ) +
  theme_minimal()
````

### Multiple Figures

Use `layout-ncol` to arrange multiple plots from a single chunk.

````r
#| label: fig-multiple-plots
#| fig-cap: "Multiple visualizations of the dataset"
#| fig-subcap: 
#|   - "Distribution of teaching scores"
#|   - "Age distribution by gender"
#| layout-ncol: 2

# Plot 1
ggplot(evals, aes(x = score)) + geom_histogram()

# Plot 2  
ggplot(evals, aes(x = age, fill = gender)) + geom_density(alpha = 0.7)
````

## Tables

### Table Standards

Use a chunk label with a `tbl-` prefix (e.g., `label: tbl-my-table`) for cross-referencing. Use `tbl-cap` for the caption.

*   **Basic Tables:** Use `knitr::kable()` for simple, clean tables.
*   **Advanced Tables:** Use the `gt` or `gtsummary` packages for publication-quality, highly customized tables.

### `gt` Example

````r
#| label: tbl-summary-stats
#| tbl-cap: "Teaching score summary statistics by ethnicity and gender"

summary_stats |>
  gt() |>
  tab_header(
    title = "Teaching Score Summary Statistics",
    subtitle = "By ethnicity and gender"
  ) |>
  fmt_number(columns = mean_score, decimals = 2) |>
  cols_label(
    ethnicity = "Ethnicity",
    gender = "Gender",
    mean_score = "Mean Score",
    n_observations = "N"
  )
````

## Citations and Bibliography

*   **Bibliography File:** Specify the bibliography file in the YAML header (e.g., `bibliography: references.bib`).
*   **Style File:** Specify the citation style using a CSL file (e.g., `csl: apa.csl`).
*   **Citation Syntax:** Use the `[@citekey]` syntax for in-text citations.

Reference as: "As shown in @fig-scatter-plot and @tbl-summary-stats..."

## Text Formatting

### Inline Code
Use backticks for function names (`lm()`), variable names (`score`), and package names (`moderndive`).

### Mathematical Notation
Use LaTeX notation for math:
- Inline: $R^2 = 0.045$
- Display: $$\hat{y} = b_0 + b_1x_1$$

### Callout Blocks
Use callout blocks to highlight information.

::: {.callout-note}
This is important information that readers should pay attention to.
:::

::: {.callout-warning}
This analysis has important limitations to consider.
:::

::: {.callout-tip}
Here's a helpful suggestion for implementation.
:::

## Workflow and Best Practices

### Reproducibility

*   **Project Structure:** Organize your project with distinct folders for data, scripts, and outputs.
*   **Package Management:** Use `renv` to manage package dependencies and ensure others can reproduce your environment.
*   **Random Seeds:** Always use `set.seed()` before any random sampling or simulation to ensure results are reproducible.
*   **Paths:** Use the `here` package to create robust, relative file paths (e.g., `here("data", "raw", "dataset.csv")`).
*   **Session Info:** Consider including `sessionInfo()` in a collapsed chunk at the end of your document to record package versions.

### Parameterized Documents

Use YAML `params` for creating flexible reports that can be re-run with different inputs.

```yaml
---
title: "Analysis Report"
params:
  region: "North America"
  min_date: "2023-01-01"
---
```

### Troubleshooting

*   When encountering errors, first try to reproduce them in an interactive R session.
*   Use `error: true` in a chunk to force rendering even if the code fails, which can help with debugging.
*   If you suspect caching issues, clear the cache with `knitr::clean_cache()`.
