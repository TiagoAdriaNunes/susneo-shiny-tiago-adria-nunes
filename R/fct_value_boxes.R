#' Value Box Creation Functions
#'
#' @description Business logic functions for creating KPI value boxes

#' Create total energy consumption value box
#'
#' @param data Filtered energy data
#'
#' @return bslib value_box for total consumption
#'
#' @noRd
#'
#' @importFrom bsicons bs_icon
#' @importFrom bslib value_box
create_consumption_value_box <- function(data) {
  total <- calculate_total_consumption(data)
  total_formatted <- format_energy_units(total)

  value_box(
    title = "Total Energy Consumption",
    value = total_formatted,
    showcase = bs_icon("lightning-charge"),
    theme = "blue",
    height = "150px"
  )
}

#' Create total carbon emissions value box
#'
#' @param data Filtered energy data
#'
#' @return bslib value_box for total emissions
#'
#' @noRd
create_emissions_value_box <- function(data) {
  total <- calculate_total_emissions(data)
  total_formatted <- format_emissions_units(total)

  value_box(
    title = "Total Carbon Emissions",
    value = total_formatted,
    showcase = bs_icon("cloud"),
    theme = "blue",
    height = "150px"
  )
}

#' Create average daily usage value box
#'
#' @param data Filtered energy data
#'
#' @return bslib value_box for average daily usage
#'
#' @noRd
create_usage_value_box <- function(data) {
  avg <- calculate_average_daily_usage(data)
  avg_formatted <- format_daily_usage_units(avg)

  value_box(
    title = "Average Daily Usage",
    value = avg_formatted,
    showcase = bs_icon("calendar3"),
    theme = "blue",
    height = "150px"
  )
}

#' Create energy efficiency value box
#'
#' @param data Filtered energy data
#'
#' @return bslib value_box for energy efficiency ratio
#'
#' @noRd
create_efficiency_value_box <- function(data) {
  total_consumption <- calculate_total_consumption(data)
  total_emissions <- calculate_total_emissions(data)

  # Calculate efficiency ratio (consumption per unit of emissions)
  efficiency <- if (total_emissions > 0) {
    total_consumption / total_emissions
  } else {
    0
  }

  efficiency_formatted <- format_number_with_commas(efficiency, "units/kg CO2e")

  value_box(
    title = "Energy Efficiency Ratio",
    value = efficiency_formatted,
    showcase = bs_icon("speedometer2"),
    theme = "success",
    height = "150px"
  )
}

#' Create peak usage value box
#'
#' @param data Filtered energy data
#'
#' @return bslib value_box for peak daily usage
#'
#' @noRd
create_peak_usage_value_box <- function(data) {
  if (nrow(data) == 0) {
    peak_formatted <- "--"
  } else {
    daily_data <- prepare_time_series_data(data)
    peak_usage <- max(daily_data$total_value, na.rm = TRUE)
    peak_formatted <- format_energy_units(peak_usage)
  }

  value_box(
    title = "Peak Daily Usage",
    value = peak_formatted,
    showcase = bs_icon("graph-up"),
    theme = "warning",
    height = "150px"
  )
}

#' Create facilities value box
#'
#' @param data Filtered energy data
#'
#' @return bslib value_box for number of active facilities
#'
#' @noRd
create_facilities_value_box <- function(data) {
  if (nrow(data) == 0) {
    count_formatted <- "0"
  } else {
    facility_count <- length(unique(data$site))
    count_formatted <- format_number_with_commas(facility_count, "facilities")
  }

  value_box(
    title = "Active Facilities",
    value = count_formatted,
    showcase = bs_icon("building"),
    theme = "info",
    height = "150px"
  )
}
