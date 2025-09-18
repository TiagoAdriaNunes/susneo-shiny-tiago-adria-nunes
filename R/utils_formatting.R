#' Number and Text Formatting Utilities
#'
#' @description Utility functions for consistent number and text formatting

#' Format number with thousands separators
#'
#' @param number Numeric value to format
#' @param suffix Optional suffix to append (e.g., "units", "kg CO2e")
#'
#' @return Formatted string with thousands separators
#'
#' @examples
#' format_number_with_commas(1234.5, "units")
#' format_number_with_commas(0)
#' @noRd
format_number_with_commas <- function(number, suffix = "") {
  if (is.na(number) || is.null(number)) {
    return("--")
  }
  formatted <- format(round(number, 0), big.mark = ",")
  if (suffix != "") formatted <- paste(formatted, suffix)
  return(formatted)
}

#' Format energy consumption values
#'
#' @param value Numeric energy value
#'
#' @return Formatted string with "units" suffix
#' @noRd
format_energy_units <- function(value) {
  format_number_with_commas(value, "units")
}

#' Format carbon emissions values
#'
#' @param value Numeric emissions value
#'
#' @return Formatted string with "kg CO2e" suffix
#' @noRd
format_emissions_units <- function(value) {
  format_number_with_commas(value, "kg CO2e")
}

#' Format daily usage values
#'
#' @param value Numeric daily usage value
#'
#' @return Formatted string with "units/day" suffix
#' @noRd
format_daily_usage_units <- function(value) {
  format_number_with_commas(value, "units/day")
}

#' Format percentage values
#'
#' @param value Numeric percentage value (0-100)
#' @param digits Number of decimal places
#'
#' @return Formatted percentage string
#' @noRd
format_percentage <- function(value, digits = 1) {
  if (is.na(value) || is.null(value)) {
    return("--")
  }
  paste0(round(value, digits), "%")
}
