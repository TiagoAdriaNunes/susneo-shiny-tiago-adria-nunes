#' Global variable declarations
#'
#' @description Declarations for global variables used in dplyr operations
#' to avoid R CMD check warnings about "no visible binding for global variable"
#'
#' @noRd
utils::globalVariables(c(
  "site",
  "total_value",
  "type",
  "value",
  "date"
))