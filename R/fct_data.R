#' Energy Data Functions
#'
#' @description Pure functions to clean, filter and summarise energy
#' consumption data. None of them depend on Shiny, so they can be tested and
#' reused on their own.
#' @noRd
NULL

# Optional emissions column
emissions_column <- "carbon_emission_in_kgco2e"

# Date layouts accepted in the data. Ambiguous numeric dates such as
# 03-04-2025 are read day first because "dmy" comes before "mdy".
energy_date_orders <- c("dmy", "mdy", "ymd", "dby", "mby", "ybd")

#' Parse dates written in mixed formats
#'
#' @param x Character (or Date) vector
#'
#' @return Date vector, `NA` where a value cannot be parsed
#'
#' @noRd
#'
#' @importFrom dplyr arrange desc group_by n summarise
#' @importFrom lubridate as_date parse_date_time
parse_energy_dates <- function(x) {
  parse_date_time(x, orders = energy_date_orders, quiet = TRUE) |>
    as_date()
}

#' Clean raw energy data
#'
#' Parses dates, converts values to numbers and drops rows that cannot be
#' used. Missing emissions are treated as zero.
#'
#' @param data Raw data frame with the columns `site`, `date`, `type` and
#'   `value`, and optionally the emissions column
#'
#' @return The cleaned data frame
#' @noRd
process_energy_data <- function(data) {
  if (nrow(data) == 0) {
    return(data.frame())
  }

  data$date <- parse_energy_dates(data$date)
  data$value <- suppressWarnings(as.numeric(data$value))
  data <- data[!is.na(data$date) & !is.na(data$value), , drop = FALSE]

  if (emissions_column %in% names(data)) {
    emissions <- suppressWarnings(as.numeric(data[[emissions_column]]))
    emissions[is.na(emissions)] <- 0
    data[[emissions_column]] <- emissions
  }

  rownames(data) <- NULL
  data
}

#' Load the packaged energy data
#'
#' Reads the `sample_data` dataset that ships in the package's `data/` folder
#' and cleans it. This is the only data source of the app.
#'
#' @return The cleaned data frame
#' @noRd
load_sample_data <- function() {
  process_energy_data(susneoEnergyDashboard::sample_data)
}

#' List the facilities in the data
#'
#' @param data Processed energy data
#'
#' @return Character vector of unique sites
#' @noRd
get_facilities <- function(data) {
  if (nrow(data) == 0 || !"site" %in% names(data)) {
    character(0)
  } else {
    unique(data$site)
  }
}

#' List the energy types in the data
#'
#' @param data Processed energy data
#'
#' @return Character vector of unique energy types
#' @noRd
get_energy_types <- function(data) {
  if (nrow(data) == 0 || !"type" %in% names(data)) {
    character(0)
  } else {
    unique(data$type)
  }
}

#' Get the first and last date in the data
#'
#' @param data Processed energy data
#'
#' @return Date vector of length 2. Today twice when there is no data.
#' @noRd
get_date_range <- function(data) {
  if (nrow(data) == 0 || !"date" %in% names(data)) {
    c(Sys.Date(), Sys.Date())
  } else {
    c(min(data$date, na.rm = TRUE), max(data$date, na.rm = TRUE))
  }
}

#' Filter energy data
#'
#' @param data Processed energy data
#' @param date_range Optional Date vector of length 2 (inclusive)
#' @param facilities Optional character vector of sites to keep
#' @param energy_types Optional character vector of energy types to keep
#'
#' @return Filtered data frame
#' @noRd
filter_energy_data <- function(
  data,
  date_range = NULL,
  facilities = NULL,
  energy_types = NULL
) {
  if (nrow(data) == 0) {
    return(data)
  }

  if (!is.null(date_range) && length(date_range) == 2) {
    data <- data[data$date >= date_range[1] & data$date <= date_range[2], , drop = FALSE]
  }

  if (!is.null(facilities) && length(facilities) > 0) {
    data <- data[data$site %in% facilities, , drop = FALSE]
  }

  if (!is.null(energy_types) && length(energy_types) > 0) {
    data <- data[data$type %in% energy_types, , drop = FALSE]
  }

  data
}

#' Warn when a selection mixes energy types
#'
#' The data has no unit column and each energy type is measured in its own
#' unit, so totals across types are only indicative.
#'
#' @param data Filtered energy data
#'
#' @return A message, or NULL when at most one energy type is present
#' @noRd
mixed_units_message <- function(data) {
  n_types <- length(get_energy_types(data))

  if (n_types < 2) {
    return(NULL)
  }

  paste0(
    "This selection combines ", n_types, " energy types. ",
    "They can use different units, so totals, charts and the model add them together as-is. ",
    "Select a single energy type for a like-for-like comparison."
  )
}

#' Total energy consumption
#'
#' @param data Filtered energy data
#'
#' @return Sum of `value`, 0 for empty data
#' @noRd
calculate_total_consumption <- function(data) {
  if (nrow(data) == 0 || !"value" %in% names(data)) {
    0
  } else {
    sum(data$value, na.rm = TRUE)
  }
}

#' Total carbon emissions
#'
#' @param data Filtered energy data
#'
#' @return Sum of emissions, 0 for empty data or when the column is absent
#' @noRd
calculate_total_emissions <- function(data) {
  if (nrow(data) == 0 || !emissions_column %in% names(data)) {
    0
  } else {
    sum(data[[emissions_column]], na.rm = TRUE)
  }
}

#' Average daily energy usage
#'
#' @param data Filtered energy data
#'
#' @return Mean of the daily totals, 0 for empty data
#'
#' @noRd
calculate_average_daily_usage <- function(data) {
  if (nrow(data) == 0 || !all(c("date", "value") %in% names(data))) {
    0
  } else {
    daily_totals <- data |>
      group_by(date) |>
      summarise(
        daily_total = sum(value, na.rm = TRUE),
        .groups = "drop"
      )

    mean(daily_totals$daily_total, na.rm = TRUE)
  }
}

#' Daily totals for the time series chart
#'
#' @param data Filtered energy data
#'
#' @return Data frame with `date` and `total_value`, ordered by date
#'
#' @noRd
prepare_time_series_data <- function(data) {
  if (nrow(data) == 0) {
    data.frame(date = as.Date(character(0)), total_value = numeric(0))
  } else {
    data |>
      group_by(date) |>
      summarise(
        total_value = sum(value, na.rm = TRUE),
        .groups = "drop"
      ) |>
      arrange(date)
  }
}

#' Totals per facility for the comparison chart
#'
#' @param data Filtered energy data
#'
#' @return Data frame with `site` and `total_value`, largest first
#'
#' @noRd
prepare_facility_data <- function(data) {
  if (nrow(data) == 0) {
    data.frame(site = character(0), total_value = numeric(0))
  } else {
    data |>
      group_by(site) |>
      summarise(
        total_value = sum(value, na.rm = TRUE),
        .groups = "drop"
      ) |>
      arrange(desc(total_value))
  }
}

#' Summary per site and energy type for the data table
#'
#' @param data Filtered energy data
#'
#' @return Data frame, largest total consumption first. Emissions are 0 when
#'   the data has no emissions column.
#'
#' @noRd
prepare_summary_data <- function(data) {
  if (nrow(data) == 0) {
    return(data.frame())
  }

  if (!emissions_column %in% names(data)) {
    data[[emissions_column]] <- 0
  }

  data |>
    group_by(site, type) |>
    summarise(
      total_consumption = sum(value, na.rm = TRUE),
      total_emissions = sum(carbon_emission_in_kgco2e, na.rm = TRUE),
      avg_consumption = round(mean(value, na.rm = TRUE), 2),
      records = n(),
      .groups = "drop"
    ) |>
    arrange(desc(total_consumption))
}
