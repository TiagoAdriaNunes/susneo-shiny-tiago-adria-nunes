#' KPI Cards UI Function
#'
#' @description A shiny Module for displaying six KPI value boxes in two rows:
#' consumption, emissions and daily average, then peak usage, efficiency ratio
#' and number of active facilities.
#'
#' @param id Module ID
#'
#' @noRd
#'
#' @importFrom bslib layout_column_wrap
#' @importFrom shiny moduleServer NS renderUI tagList uiOutput
mod_kpi_cards_ui <- function(id) {
  ns <- NS(id)

  tagList(
    # Primary KPIs
    layout_column_wrap(
      min_width = "280px",
      fill = FALSE,
      uiOutput(ns("total_consumption_box")),
      uiOutput(ns("total_emissions_box")),
      uiOutput(ns("avg_daily_usage_box"))
    ),
    # Secondary KPIs
    layout_column_wrap(
      min_width = "280px",
      fill = FALSE,
      uiOutput(ns("peak_usage_box")),
      uiOutput(ns("efficiency_box")),
      uiOutput(ns("facilities_count_box"))
    )
  )
}

#' KPI Cards Server Functions
#'
#' @param id Module ID
#' @param filtered_data Reactive filtered data
#'
#' @noRd
mod_kpi_cards_server <- function(id, filtered_data) {
  moduleServer(id, function(input, output, session) {
    # Primary KPIs
    output$total_consumption_box <- renderUI({
      create_consumption_value_box(filtered_data())
    })

    output$total_emissions_box <- renderUI({
      create_emissions_value_box(filtered_data())
    })

    output$avg_daily_usage_box <- renderUI({
      create_usage_value_box(filtered_data())
    })

    # Secondary KPIs
    output$peak_usage_box <- renderUI({
      create_peak_usage_value_box(filtered_data())
    })

    output$efficiency_box <- renderUI({
      create_efficiency_value_box(filtered_data())
    })

    output$facilities_count_box <- renderUI({
      create_facilities_value_box(filtered_data())
    })
  })
}
