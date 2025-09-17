#' data_manager
#'
#' @description A class generator function for managing energy dashboard data
#'
#' @importFrom R6 R6Class
#' @importFrom shiny reactiveVal
#' @importFrom lubridate parse_date_time as_date
#' @importFrom dplyr filter group_by summarise arrange desc
#' @importFrom utils read.csv
#'
#' @noRd
data_manager <- R6::R6Class(
  classname = "data_manager",
  public = list(
    # Reactive values
    raw_data = NULL,
    processed_data = NULL,

    # Initialize the data manager
    initialize = function() {
      self$raw_data <- shiny::reactiveVal(data.frame())
      self$processed_data <- shiny::reactiveVal(data.frame())
    },

    # Data loading methods
    load_sample_data = function() {
      tryCatch(
        {
          # Load sample_data from package data
          data("sample_data", package = "susneo", envir = environment())
          self$raw_data(sample_data)
          self$process_data()
          return(TRUE)
        },
        error = function(e) {
          warning("Could not load sample_data: ", e$message)
          self$raw_data(data.frame())
          self$processed_data(data.frame())
          return(FALSE)
        }
      )
    },
    load_uploaded_data = function(file_path) {
      tryCatch(
        {
          data <- utils::read.csv(file_path, stringsAsFactors = FALSE)
          if (self$validate_data(data)) {
            self$raw_data(data)
            self$process_data()
            return(TRUE)
          } else {
            warning("Invalid data format")
            return(FALSE)
          }
        },
        error = function(e) {
          warning("Could not load uploaded file: ", e$message)
          return(FALSE)
        }
      )
    },

    # Data processing methods
    process_data = function() {
      data <- self$raw_data()
      if (nrow(data) == 0) {
        self$processed_data(data.frame())
        return()
      }

      # Parse dates with mixed formats
      data$date <- lubridate::parse_date_time(data$date,
        orders = c("dmy", "mdy", "ymd", "dby", "mby", "ybd"),
        quiet = TRUE
      ) |>
        lubridate::as_date()

      # Remove rows with invalid dates
      data <- data[!is.na(data$date), ]

      # Clean and validate numeric columns
      if ("value" %in% names(data)) {
        data$value <- as.numeric(data$value)
        data <- data[!is.na(data$value), ]
      }

      if ("carbon_emission_in_kgco2e" %in% names(data)) {
        data$carbon_emission_in_kgco2e <- as.numeric(data$carbon_emission_in_kgco2e)
        data$carbon_emission_in_kgco2e[is.na(data$carbon_emission_in_kgco2e)] <- 0
      }

      self$processed_data(data)
    },
    validate_data = function(data) {
      required_cols <- c("site", "date", "type", "value")
      return(all(required_cols %in% names(data)) && nrow(data) > 0)
    },

    # Data access methods
    get_raw_data = function() {
      return(self$raw_data)
    },
    get_processed_data = function() {
      return(self$processed_data)
    },
    get_facilities = function() {
      data <- self$processed_data()
      if (nrow(data) == 0) {
        return(character(0))
      }
      return(unique(data$site))
    },
    get_energy_types = function() {
      data <- self$processed_data()
      if (nrow(data) == 0) {
        return(character(0))
      }
      return(unique(data$type))
    },
    get_date_range = function() {
      data <- self$processed_data()
      if (nrow(data) == 0) {
        return(c(Sys.Date(), Sys.Date()))
      }
      return(c(min(data$date, na.rm = TRUE), max(data$date, na.rm = TRUE)))
    },

    # Filtering methods
    apply_filters = function(date_range = NULL, facilities = NULL, energy_types = NULL) {
      data <- self$processed_data()

      if (nrow(data) == 0) {
        return(data.frame())
      }

      # Apply date filter
      if (!is.null(date_range) && length(date_range) == 2) {
        data <- data[data$date >= date_range[1] & data$date <= date_range[2], ]
      }

      # Apply facility filter
      if (!is.null(facilities) && length(facilities) > 0) {
        data <- data[data$site %in% facilities, ]
      }

      # Apply energy type filter
      if (!is.null(energy_types) && length(energy_types) > 0) {
        data <- data[data$type %in% energy_types, ]
      }

      return(data)
    },

    # Calculation methods
    calculate_total_consumption = function(filtered_data) {
      if (nrow(filtered_data) == 0) {
        return(0)
      }
      return(sum(filtered_data$value, na.rm = TRUE))
    },
    calculate_total_emissions = function(filtered_data) {
      if (nrow(filtered_data) == 0) {
        return(0)
      }
      if (!"carbon_emission_in_kgco2e" %in% names(filtered_data)) {
        return(0)
      }
      return(sum(filtered_data$carbon_emission_in_kgco2e, na.rm = TRUE))
    },
    calculate_average_daily_usage = function(filtered_data) {
      if (nrow(filtered_data) == 0) {
        return(0)
      }

      daily_totals <- filtered_data |>
        dplyr::group_by(date) |>
        dplyr::summarise(daily_total = sum(value, na.rm = TRUE), .groups = "drop")

      return(mean(daily_totals$daily_total, na.rm = TRUE))
    },

    # Data preparation for charts
    prepare_time_series_data = function(filtered_data) {
      if (nrow(filtered_data) == 0) {
        return(data.frame())
      }

      return(filtered_data |>
        dplyr::group_by(date) |>
        dplyr::summarise(total_value = sum(value, na.rm = TRUE), .groups = "drop") |>
        dplyr::arrange(date))
    },
    prepare_facility_data = function(filtered_data) {
      if (nrow(filtered_data) == 0) {
        return(data.frame())
      }

      return(filtered_data |>
        dplyr::group_by(site) |>
        dplyr::summarise(total_value = sum(value, na.rm = TRUE), .groups = "drop") |>
        dplyr::arrange(dplyr::desc(total_value)))
    },
    prepare_summary_data = function(filtered_data) {
      if (nrow(filtered_data) == 0) {
        return(data.frame())
      }

      return(filtered_data |>
        dplyr::group_by(site, type) |>
        dplyr::summarise(
          total_consumption = sum(value, na.rm = TRUE),
          total_emissions = sum(carbon_emission_in_kgco2e, na.rm = TRUE),
          avg_consumption = round(mean(value, na.rm = TRUE), 2),
          records = dplyr::n(),
          .groups = "drop"
        ) |>
        dplyr::arrange(dplyr::desc(total_consumption)))
    },

    # Utility methods
    format_number = function(number, suffix = "") {
      if (is.na(number) || is.null(number)) {
        return("--")
      }
      formatted <- format(round(number, 0), big.mark = ",")
      if (suffix != "") formatted <- paste(formatted, suffix)
      return(formatted)
    },
    is_data_loaded = function() {
      return(nrow(self$processed_data()) > 0)
    }
  )
)
