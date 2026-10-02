#' Sample Energy Consumption Data
#'
#' @description A dataset containing sample energy consumption data for demonstration
#' purposes in the Susneo Shiny application.
#'
#' @format A data frame with 6 variables:
#' \describe{
#'   \item{id}{Unique identifier for each record}
#'   \item{site}{Facility/site identifier (character)}
#'   \item{date}{Date of measurement in DD-MM-YYYY format (character)}
#'   \item{type}{Type of energy consumption: Electricity, Fuel, Gas, Waste, or Water (character)}
#'   \item{value}{Consumption value (numeric). The data has no unit column and each type is
#'     measured in its own unit, so values of different types should not be added together.}
#'   \item{carbon_emission_in_kgco2e}{Carbon emissions in kg CO2 equivalent (numeric)}
#' }
#'
#' @source Synthetic data generated for demonstration purposes
#'
#' @examples
#' \dontrun{
#' data(sample_data)
#' head(sample_data)
#' }
"sample_data"
