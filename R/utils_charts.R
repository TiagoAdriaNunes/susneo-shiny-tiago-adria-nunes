#' Chart Configuration Utilities
#'
#' @description Utility functions for consistent chart styling and configuration

#' Get standard chart colors
#'
#' @return Vector of hex color codes for charts
#' @noRd
get_chart_colors <- function() {
  c("#2E86AB")
}

#' Get primary chart color
#'
#' @return Primary blue color hex code
#' @noRd
get_primary_color <- function() {
  "#2E86AB"
}

#' Get JavaScript formatter for number formatting in charts
#'
#' @return htmlwidgets::JS object for Highcharts number formatting
#'
#' @importFrom htmlwidgets JS
#' @noRd
get_chart_formatter_js <- function() {
  htmlwidgets::JS("function() { return Highcharts.numberFormat(this.value, 0, '', ','); }")
}

#' Create empty chart with no data message
#'
#' @param title Chart title for no data state
#'
#' @return Highcharts object with no data message
#'
#' @importFrom highcharter highchart hc_title
#' @noRd
create_empty_chart <- function(title = "No data available") {
  highcharter::highchart() |>
    highcharter::hc_title(text = title)
}

#' Get standard chart tooltip configuration
#'
#' @param point_format Format string for tooltip (e.g., "Energy: {point.y:,.0f} units")
#'
#' @return List with tooltip configuration
#' @noRd
get_chart_tooltip_config <- function(point_format) {
  list(pointFormat = point_format)
}

#' Get standard chart axis configuration
#'
#' @param title Axis title
#' @param formatter_js Optional JavaScript formatter function
#'
#' @return List with axis configuration
#' @noRd
get_chart_axis_config <- function(title, formatter_js = NULL) {
  config <- list(title = list(text = title))

  if (!is.null(formatter_js)) {
    config$labels <- list(formatter = formatter_js)
  }

  return(config)
}

#' Get standard chart configuration
#'
#' @param title Chart title
#' @param x_axis_title X-axis title
#' @param y_axis_title Y-axis title
#' @param tooltip_format Tooltip format string
#' @param color Chart color (optional, uses default if NULL)
#'
#' @return List with complete chart configuration
#' @noRd
get_standard_chart_config <- function(title, x_axis_title, y_axis_title, tooltip_format, color = NULL) {
  list(
    title = title,
    x_axis = get_chart_axis_config(x_axis_title),
    y_axis = get_chart_axis_config(y_axis_title, get_chart_formatter_js()),
    tooltip = get_chart_tooltip_config(tooltip_format),
    color = if (is.null(color)) get_primary_color() else color
  )
}
