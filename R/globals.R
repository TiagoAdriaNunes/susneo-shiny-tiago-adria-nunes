#' Global variable declarations
#'
#' @description Declarations for global variables used in dplyr operations
#' to avoid R CMD check warnings about "no visible binding for global variable"
#'
#' @noRd
#'
#' @importFrom utils globalVariables
globalVariables(c(
  "carbon_emission_in_kgco2e",
  "date",
  "site",
  "total_consumption",
  "total_value",
  "type",
  "value"
))
