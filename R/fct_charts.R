#' Chart Creation Functions
#'
#' @description Business logic functions for creating dashboard charts

#' Create time series line chart
#'
#' @param data Filtered energy data
#'
#' @return Highcharts time series chart
#'
#' @noRd
#'
#' @importFrom highcharter hc_colors hc_size hc_title hc_tooltip hc_xAxis hc_yAxis hcaes hchart
#' @importFrom htmlwidgets JS
create_time_series_chart <- function(data) {
  if (nrow(data) == 0) {
    return(create_empty_chart())
  }

  daily_data <- prepare_time_series_data(data)

  hchart(
    daily_data,
    "line",
    hcaes(x = date, y = total_value),
    name = "Daily Consumption"
  ) |>
    hc_title(text = "Daily Energy Consumption") |>
    hc_xAxis(title = list(text = "Date")) |>
    hc_yAxis(
      title = list(text = "Energy Consumption (units)"),
      labels = list(formatter = get_chart_formatter_js())
    ) |>
    hc_tooltip(
      useHTML = TRUE,
      formatter = JS(
        "function() {
        return '<b>' + Highcharts.dateFormat('%A, %B %e, %Y', this.x) + '</b><br>' +
               'Energy: ' + Highcharts.numberFormat(this.y, 0, '.', ',') + ' units';
      }"
      )
    ) |>
    hc_colors(get_primary_color()) |>
    hc_size(height = 400)
}

#' Create facility comparison column chart
#'
#' @param data Filtered energy data
#'
#' @return Highcharts column chart
#'
#' @noRd
create_facility_chart <- function(data) {
  if (nrow(data) == 0) {
    return(create_empty_chart())
  }

  facility_data <- prepare_facility_data(data)

  hchart(
    facility_data,
    "column",
    hcaes(x = site, y = total_value)
  ) |>
    hc_title(text = "Total Energy Consumption by Facility") |>
    hc_xAxis(title = list(text = "Facility")) |>
    hc_yAxis(
      title = list(text = "Total Energy Consumption (units)"),
      labels = list(formatter = get_chart_formatter_js())
    ) |>
    hc_tooltip(
      useHTML = TRUE,
      formatter = JS(
        "function() {
        return '<b>' + this.point.name + '</b><br>' +
               'Total: ' + Highcharts.numberFormat(this.y, 0, '.', ',') + ' units';
      }"
      )
    ) |>
    hc_colors(get_primary_color()) |>
    hc_size(height = 400)
}
