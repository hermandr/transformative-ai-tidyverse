# Tidyverse Coding Style Guide

This document summarizes the main principles of the tidyverse style guide, designed to make your R code easier to read, share, and maintain.

## Naming Conventions

Consistent and clear naming is crucial for readable code.

-   **Variables**: Use `snake_case`, where you separate lowercase words with an underscore (`_`).
    ```r
    # Strive for:
    short_flights <- flights |> filter(air_time < 60)

    # Avoid:
    SHORTFLIGHTS <- flights |> filter(air_time < 60)
    ```

-   **Functions**: Function names should generally be verbs. Prefer clarity over brevity.
    ```r
    # Strive for:
    impute_missing()
    collapse_years()

    # Avoid:
    f()
    my_awesome_function()
    ```

-   **Arguments**: Function arguments should be nouns.

## Spacing

Proper spacing improves the legibility of your code.

-   Place spaces around all infix operators (`=`, `+`, `-`, `<-`, etc.).
-   Always put a space after a comma, never before.
-   Do not put spaces inside or outside parentheses for regular function calls.

    ```r
    # Strive for:
    z <- (a + b)^2 / d
    mean(x, na.rm = TRUE)

    # Avoid:
    z<-( a + b ) ^ 2/d
    mean (x ,na.rm=TRUE)
    ```
-   It's acceptable to add extra spaces to align `=` signs in `mutate()` calls for readability.
    ```r
    flights |>
      mutate(
        speed      = distance / air_time,
        dep_hour   = dep_time %/% 100,
        dep_minute = dep_time %%  100
      )
    ```

## Pipes

The pipe (`|>`) is a cornerstone of the tidyverse. Style it as follows:

-   The pipe should always have a space before it and should be the last thing on a line.
-   Indent the code after a pipe by two spaces.
-   For functions with multiple arguments, place each argument on a new, indented line.

    ```r
    # Strive for
    flights |>
      group_by(tailnum) |>
      summarize(
        delay = mean(arr_delay, na.rm = TRUE),
        n = n()
      )
    ```
-   Break up long pipelines (more than 10-15 lines) into intermediate, descriptively-named variables.

## ggplot2

Styling `ggplot2` code is similar to styling pipes:

-   Treat the `+` operator like the pipe (`|>`). Place it at the end of the line with a space before it.
-   Indent the next layer by two spaces.

    ```r
    flights |>
      group_by(month) |>
      summarize(
        delay = mean(arr_delay, na.rm = TRUE)
      ) |>
      ggplot(aes(x = month, y = delay)) +
      geom_point() +
      geom_line()
    ```

## Organization

-   **Sectioning**: Use sectioning comments to break up long scripts into manageable chunks. RStudio provides a shortcut (Cmd/Ctrl + Shift + R) and a navigation menu for these sections.
    ```r
    # Load data --------------------------------------

    # Plot data --------------------------------------
    ```
-   **Functions**: When defining a function, place the opening `{` on the same line as `function()` and indent the body of the function by two spaces.
    ```r
    # Strive for:
    rescale01 <- function(x) {
      rng <- range(x, na.rm = TRUE)
      (x - rng[1]) / (rng[2] - rng[1])
    }
    ```
