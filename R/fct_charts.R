#' Chart Creation Functions
#'
#' @description Business logic functions for creating dashboard charts
#'
#' @noRd

#' Create time series line chart
#'
#' @param data Filtered data from data_manager
#' @param data_manager Data manager instance for data preparation
#'
#' @return Highcharts time series chart
#'
#' @importFrom highcharter hchart hcaes hc_title hc_xAxis hc_yAxis hc_tooltip hc_colors
#'
#' @noRd
create_time_series_chart <- function(data, data_manager) {
  if (nrow(data) == 0) {
    return(create_empty_chart())
  }

  daily_data <- data_manager$prepare_time_series_data(data)
  config <- get_standard_chart_config(
    title = "Daily Energy Consumption",
    x_axis_title = "Date",
    y_axis_title = "Energy Consumption (units)",
    tooltip_format = "Energy: {point.y:,.0f} units"
  )

  highcharter::hchart(
    daily_data, "line",
    highcharter::hcaes(x = date, y = total_value)
  ) |>
    highcharter::hc_title(text = config$title) |>
    highcharter::hc_xAxis(title = list(text = config$x_axis$title$text)) |>
    highcharter::hc_yAxis(
      title = list(text = config$y_axis$title$text),
      labels = config$y_axis$labels
    ) |>
    highcharter::hc_tooltip(
      pointFormat = config$tooltip$pointFormat
    ) |>
    highcharter::hc_colors(c(config$color))
}

#' Create facility comparison column chart
#'
#' @param data Filtered data from data_manager
#' @param data_manager Data manager instance for data preparation
#'
#' @return Highcharts column chart
#'
#' @importFrom highcharter hchart hcaes hc_title hc_xAxis hc_yAxis hc_tooltip hc_colors
#'
#' @noRd
create_facility_chart <- function(data, data_manager) {
  if (nrow(data) == 0) {
    return(create_empty_chart())
  }

  facility_data <- data_manager$prepare_facility_data(data)
  config <- get_standard_chart_config(
    title = "Total Energy Consumption by Facility",
    x_axis_title = "Facility",
    y_axis_title = "Total Energy Consumption (units)",
    tooltip_format = "Total: {point.y:,.0f} units"
  )

  highcharter::hchart(
    facility_data, "column",
    highcharter::hcaes(x = site, y = total_value)
  ) |>
    highcharter::hc_title(text = config$title) |>
    highcharter::hc_xAxis(title = list(text = config$x_axis$title$text)) |>
    highcharter::hc_yAxis(
      title = list(text = config$y_axis$title$text),
      labels = config$y_axis$labels
    ) |>
    highcharter::hc_tooltip(
      pointFormat = config$tooltip$pointFormat
    ) |>
    highcharter::hc_colors(c(config$color))
}

#' Create energy type distribution pie chart
#'
#' @param data Filtered data from data_manager
#' @param data_manager Data manager instance for data preparation
#'
#' @return Highcharts pie chart
#'
#' @importFrom highcharter hchart hc_title hc_tooltip hc_colors
#' @importFrom dplyr group_by summarise arrange desc
#'
#' @noRd
create_energy_type_chart <- function(data, data_manager) {
  if (nrow(data) == 0) {
    return(create_empty_chart())
  }

  type_data <- data |>
    dplyr::group_by(type) |>
    dplyr::summarise(total_value = sum(value, na.rm = TRUE), .groups = "drop") |>
    dplyr::arrange(dplyr::desc(total_value))

  highcharter::hchart(
    type_data, "pie",
    highcharter::hcaes(x = type, y = total_value)
  ) |>
    highcharter::hc_title(text = "Energy Consumption by Type") |>
    highcharter::hc_tooltip(
      pointFormat = "Total: {point.y:,.0f} units<br>Percentage: {point.percentage:.1f}%"
    ) |>
    highcharter::hc_colors(c("#2E86AB", "#A23B72", "#F18F01", "#C73E1D", "#593E2C"))
}

#' Create trend analysis chart
#'
#' @param data Filtered data from data_manager
#' @param data_manager Data manager instance for data preparation
#'
#' @return Highcharts trend chart with moving average
#'
#' @importFrom highcharter hchart hcaes hc_title hc_xAxis hc_yAxis hc_tooltip hc_colors
#' @importFrom dplyr group_by summarise arrange mutate lag
#'
#' @noRd
create_trend_chart <- function(data, data_manager) {
  if (nrow(data) == 0) {
    return(create_empty_chart())
  }

  daily_data <- data_manager$prepare_time_series_data(data)

  # Add 7-day moving average
  daily_data <- daily_data |>
    dplyr::arrange(date) |>
    dplyr::mutate(
      ma_7 = zoo::rollmean(total_value, k = 7, fill = NA, align = "right")
    )

  highcharter::hchart(
    daily_data, "line",
    highcharter::hcaes(x = date, y = total_value)
  ) |>
    highcharter::hc_title(text = "Energy Consumption Trend Analysis") |>
    highcharter::hc_xAxis(title = list(text = "Date")) |>
    highcharter::hc_yAxis(
      title = list(text = "Energy Consumption (units)"),
      labels = list(formatter = get_chart_formatter_js())
    ) |>
    highcharter::hc_tooltip(
      pointFormat = "Daily: {point.y:,.0f} units"
    ) |>
    highcharter::hc_colors(c(get_primary_color()))
}
