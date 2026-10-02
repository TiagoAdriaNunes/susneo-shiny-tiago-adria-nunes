#' Energy Data Manager
#'
#' @description R6 class that owns the cleaned energy data of the app and
#' answers the questions the dashboard asks about it: which facilities,
#' energy types and dates exist, and which rows match the current filters.
#'
#' The data is cleaned once when the object is created and is read-only
#' afterwards. The calculations themselves live in the pure functions of
#' `fct_data.R`, so they stay testable without the class or Shiny.
#'
#' @noRd
#'
#' @importFrom R6 R6Class
EnergyDataManager <- R6Class(
  "EnergyDataManager",
  public = list(
    #' @description Create a manager
    #' @param data Raw energy data. Defaults to the dataset shipped in the
    #'   package's `data/` folder.
    initialize = function(data = susneoEnergyDashboard::sample_data) {
      stopifnot(is.data.frame(data))
      private$.data <- process_energy_data(data)
    },

    #' @description Whether there are any usable rows
    has_data = function() {
      nrow(private$.data) > 0
    },

    #' @description Unique facilities in the data
    facilities = function() {
      get_facilities(private$.data)
    },

    #' @description Unique energy types in the data
    energy_types = function() {
      get_energy_types(private$.data)
    },

    #' @description First and last date in the data
    date_range = function() {
      get_date_range(private$.data)
    },

    #' @description Rows matching the filters. `NULL` or empty filters keep
    #'   everything.
    #' @param date_range Optional Date vector of length 2 (inclusive)
    #' @param facilities Optional character vector of sites
    #' @param energy_types Optional character vector of energy types
    filter = function(date_range = NULL, facilities = NULL, energy_types = NULL) {
      filter_energy_data(
        private$.data,
        date_range = date_range,
        facilities = facilities,
        energy_types = energy_types
      )
    }
  ),
  active = list(
    #' @field data The cleaned data (read-only)
    data = function(value) {
      if (!missing(value)) {
        stop("`data` is read-only; create a new EnergyDataManager instead", call. = FALSE)
      }
      private$.data
    }
  ),
  private = list(
    .data = NULL
  )
)
