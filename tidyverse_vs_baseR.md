# Tidyverse vs. Base R: A Comparison

This document summarizes the key differences in programming philosophy and practice between the Tidyverse and conventional base R, as described in 'R for Data Science'.

## 1. Core Philosophy: Data-Frame-Centric vs. Vector-Centric

-   **Tidyverse**: The core principle is being data-frame-centric. Tidyverse functions, particularly in `dplyr`, are designed to always accept a data frame (or tibble) as the first argument and always return a data frame. This consistency is what enables the use of the pipe (`|>`).
-   **Base R**: Operations are often vector-centric. Many base R functions are designed to work on individual vectors. When working with data frames, you often need to first extract the vectors (columns) using `$` or `[[`, perform the operation, and then re-assemble the results.

## 2. Syntax and Readability: Pipes vs. Nesting/Intermediate Variables

The most visible difference is how multiple operations are chained together.

-   **Tidyverse**: The tidyverse heavily promotes the use of the pipe (`|>`), which allows you to write code as a sequence of readable, imperative steps. 

    ```r
    # Tidyverse approach
    flights |>
      filter(dest == "IAH") |>
      mutate(speed = distance / air_time * 60) |>
      select(year:day, dep_time, carrier, flight, speed) |>
      arrange(desc(speed))
    ```

-   **Base R**: Without the pipe, you have two main options, both of which can be harder to read for complex operations.
    1.  **Nested function calls**: The operations are read from the inside-out.
        ```r
        # Base R - Nested approach
        arrange(
          select(
            mutate(
              filter(
                flights,
                dest == "IAH"
              ),
              speed = distance / air_time * 60
            ),
            year:day, dep_time, carrier, flight, speed
          ),
          desc(speed)
        )
        ```
    2.  **Intermediate variables**: This avoids deep nesting but clutters the workspace.
        ```r
        # Base R - Intermediate variables approach
        flights1 <- filter(flights, dest == "IAH")
        flights2 <- mutate(flights1, speed = distance / air_time * 60)
        flights3 <- select(flights2, year:day, dep_time, carrier, flight, speed)
        arrange(flights3, desc(speed))
        ```

## 3. Iteration: Functionals vs. Loops

-   **Tidyverse**: Encourages a "functional programming" style that avoids explicit `for` loops.
    -   **For columns**: `dplyr::across()` applies operations across multiple columns within other `dplyr` verbs.
    -   **For vector/list elements**: `purrr::map()` applies a function to each element of a list or vector.

        ```r
        # Tidyverse iteration over files
        paths |>
          map(readxl::read_excel) |>
          list_rbind()
        ```

-   **Base R**:
    -   **`for` loops**: The fundamental building block for iteration. Requires manual pre-allocation of output structures to be efficient.
        ```r
        # Base R for loop equivalent
        files <- vector("list", length(paths))
        for (i in seq_along(paths)) {
          files[[i]] <- readxl::read_excel(paths[[i]])
        }
        do.call(rbind, files)
        ```
    -   **Apply family**: Base R has its own family of functional-style functions (`lapply`, `sapply`, `tapply`) that are equivalents to `purrr::map()`.

## 4. Subsetting and Data Manipulation

-   **Tidyverse**: Uses descriptive verbs for data manipulation tasks.
    -   `filter()`: Selects rows.
    -   `arrange()`: Reorders rows.
    -   `select()`: Selects columns, with powerful helpers (`starts_with`, `where`, etc.).
    -   `mutate()`: Creates new columns.
    -   `group_by()` + `summarize()`: Performs grouped summaries, always returning a tidy data frame.

-   **Base R**: Primarily uses subsetting operators, which are powerful but can be less readable.
    -   **`[`**: A concise tool for selecting sub-components.
        -   `df[df$x > 1, ]` is like `filter()`.
        -   `df[order(df$x), ]` is like `arrange()`.
        -   `df[, c("x", "y")]` is like `select()`.
    -   **`$` and `[[`**: Used to extract single columns as vectors.
    -   **`tapply()`**: A base equivalent for grouped summaries, but often returns vectors or arrays, which can be less convenient than the data frames returned by `summarize()`.

## 5. Evaluation: Tidy Evaluation vs. Standard Evaluation

-   **Tidyverse**: Functions like `filter` and `mutate` use "tidy evaluation" (data-masking), allowing you to refer to column names directly (e.g., `filter(month == 1)`). This is convenient for interactive analysis but requires the `{{ }}` (embrace) operator to work correctly inside functions.
-   **Base R**: Uses standard evaluation. You must be explicit about where variables live (e.g., `df[df$month == 1, ]`). This makes programming more straightforward but can be more verbose for interactive use.
