
process_one_events_set <- function(events, window_length, dt) {

    # Guard: ensure window_length is at least 1
    if (window_length < 1) {
        stop("window_length must be >= 1")
    }  

    # Guard: ensure events has required columns
    required_cols <- c("event_id", "event_date")
    missing_cols <- setdiff(required_cols, names(events))

    if (length(missing_cols) > 0) {
        stop("events dataframe is missing required columns: ", 
             paste(missing_cols, collapse = ", "))
    }
    events = events |> select(event_id, event_date)

    # Guard: ensure dt has required columns
    required_cols <- c("symbol", "date", "price", "trading_day_index")
    missing_cols <- setdiff(required_cols, names(dt))

    if (length(missing_cols) > 0) {
        stop("dt dataframe is missing required columns: ", 
             paste(missing_cols, collapse = ", "))
    }
    dt = dt |> select(symbol, date, price, trading_day_index)
    # -----------------------------------------------------

    events_symbol = events |> 
        inner_join(dt, by = join_by(event_date == date)) |> 
        rename(event_date_index = trading_day_index) |> 
        select(event_id, event_date, symbol, event_date_index)

    initial_price_window = events_symbol |> 
        mutate(initial_index = event_date_index - window_length) |> 
        inner_join(dt, by=join_by(symbol, initial_index == trading_day_index)) |> 
        select(event_id, event_date, symbol, initial_price=price)

    dt_window_index = events_symbol |> 
        mutate(
            window_start = event_date_index - window_length,
            window_end = event_date_index + window_length
        ) |> 
        inner_join(dt, by=join_by(symbol, between(y$trading_day_index,x$window_start,x$window_end))) |> 
        mutate(
            period = case_when(
                trading_day_index == event_date_index ~ "event",
                between(trading_day_index, event_date_index - window_length, event_date_index -1) ~ "before", 
                between(trading_day_index, event_date_index +1, event_date_index + window_length) ~ "after"
            ),
            window_index = trading_day_index - event_date_index
        ) |> 
        select(-window_start, -window_end)

    dt_price_change = dt_window_index |> 
        inner_join(initial_price_window) |> 
        mutate( price_change = price - initial_price)

    window_plot_data = dt_price_change |> 
        group_by(symbol, window_index) |> 
        summarize(
            median_price_change = median(price_change),
            median_abs_price_change = median(abs(price_change))
        )
    return(list(dt_price_change,window_plot_data))
}
