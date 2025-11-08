
suppressPackageStartupMessages({
  library(tidyverse)
  library(here)
})

bond_yields <- read_csv(here::here("data/raw/bond_yields_raw.csv"), show_col_types = FALSE)
ai_events <- read_csv(here::here("data/raw/ai_events_raw.csv"), show_col_types = FALSE) %>% 
  mutate(date = as.Date(date))

trading_dates = bond_yields |>  
    filter(symbol=="DGS10") |>  
    filter(!is.na(price)) |>  
    select(date)

trading_dates = trading_dates |>   
    arrange(date) |>  
    rowid_to_column(var="trading_day_index")

events = ai_events |>  
    mutate(
        year = as.integer(year)
    ) |>  
    arrange(date, company) |>  
    rowid_to_column(var="event_id") |>  
    inner_join(trading_dates)

print(paste("Number of events used:", nrow(events)))
