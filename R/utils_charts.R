#' Chart Configuration Utilities
#'
#' @description Utility functions for consistent chart styling and configuration

#' Set global Highcharts number formatting
#'
#' @return JS configuration for global Highcharts options
#'
#' @noRd
#'
#' @importFrom highcharter hc_size hc_title highchart
#' @importFrom htmlwidgets JS
set_global_chart_options <- function() {
  JS(
    "
    Highcharts.setOptions({
      lang: {
        thousandsSep: ','
      }
    });
  "
  )
}

#' Get primary chart color
#'
#' @return Primary blue color hex code
#' @noRd
get_primary_color <- function() {
  "#007bc2"
}

#' Get JavaScript formatter for number formatting in charts
#'
#' @return htmlwidgets::JS object for Highcharts number formatting
#'
#' @noRd
get_chart_formatter_js <- function() {
  JS(
    "function() { return Highcharts.numberFormat(this.value, 0, '.', ','); }"
  )
}

#' Create empty chart with no data message
#'
#' @param title Chart title for no data state
#'
#' @return Highcharts object with no data message
#'
#' @noRd
create_empty_chart <- function(title = "No data available") {
  highchart() |>
    hc_title(text = title) |>
    hc_size(height = 400)
}
