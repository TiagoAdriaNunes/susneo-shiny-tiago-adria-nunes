#' KPI Cards UI Function
#'
#' @description A shiny Module for displaying KPI value boxes.
#'
#' @param id,input,output,session Internal parameters for {shiny}.
#'
#' @noRd
#'
#' @importFrom shiny NS uiOutput
#' @importFrom bslib layout_column_wrap
mod_kpi_cards_ui <- function(id) {
  ns <- NS(id)

  bslib::layout_column_wrap(
    min_width = "280px",
    fill = FALSE,
    shiny::uiOutput(ns("total_consumption_box")),
    shiny::uiOutput(ns("total_emissions_box")),
    shiny::uiOutput(ns("avg_daily_usage_box"))
  )
}

#' KPI Cards Server Functions
#'
#' @param id Module ID
#' @param data_manager Data manager instance
#' @param filtered_data Reactive filtered data
#'
#' @noRd
#' @importFrom shiny moduleServer renderUI
mod_kpi_cards_server <- function(id, data_manager, filtered_data) {
  moduleServer(id, function(input, output, session) {
    ns <- session$ns

    output$total_consumption_box <- renderUI({
      data <- filtered_data()
      create_consumption_value_box(data, data_manager)
    })

    output$total_emissions_box <- renderUI({
      data <- filtered_data()
      create_emissions_value_box(data, data_manager)
    })

    output$avg_daily_usage_box <- renderUI({
      data <- filtered_data()
      create_usage_value_box(data, data_manager)
    })
  })
}

#' Extended KPI Cards UI Function
#'
#' @description Extended version with 6 KPI cards
#'
#' @param id Module ID
#'
#' @noRd
#'
#' @importFrom shiny NS uiOutput tagList
#' @importFrom bslib layout_column_wrap
mod_kpi_cards_extended_ui <- function(id) {
  ns <- NS(id)

  tagList(
    # Primary KPIs
    bslib::layout_column_wrap(
      min_width = "280px",
      fill = FALSE,
      shiny::uiOutput(ns("total_consumption_box")),
      shiny::uiOutput(ns("total_emissions_box")),
      shiny::uiOutput(ns("avg_daily_usage_box"))
    ),
    # Secondary KPIs
    bslib::layout_column_wrap(
      min_width = "280px",
      fill = FALSE,
      shiny::uiOutput(ns("peak_usage_box")),
      shiny::uiOutput(ns("efficiency_box")),
      shiny::uiOutput(ns("facilities_count_box"))
    )
  )
}

#' Extended KPI Cards Server Functions
#'
#' @param id Module ID
#' @param data_manager Data manager instance
#' @param filtered_data Reactive filtered data
#'
#' @noRd
#' @importFrom shiny moduleServer renderUI tagList
mod_kpi_cards_extended_server <- function(id, data_manager, filtered_data) {
  moduleServer(id, function(input, output, session) {
    ns <- session$ns

    # Primary KPIs
    output$total_consumption_box <- renderUI({
      data <- filtered_data()
      create_consumption_value_box(data, data_manager)
    })

    output$total_emissions_box <- renderUI({
      data <- filtered_data()
      create_emissions_value_box(data, data_manager)
    })

    output$avg_daily_usage_box <- renderUI({
      data <- filtered_data()
      create_usage_value_box(data, data_manager)
    })

    # Secondary KPIs
    output$peak_usage_box <- renderUI({
      data <- filtered_data()
      create_peak_usage_value_box(data, data_manager)
    })

    output$efficiency_box <- renderUI({
      data <- filtered_data()
      create_efficiency_value_box(data, data_manager)
    })

    output$facilities_count_box <- renderUI({
      data <- filtered_data()
      create_facilities_value_box(data)
    })
  })
}
