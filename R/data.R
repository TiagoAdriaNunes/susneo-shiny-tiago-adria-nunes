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
#'   \item{type}{Type of energy consumption: Water, Electricity, Waste, or Gas (character)}
#'   \item{value}{Energy consumption value (numeric)}
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
