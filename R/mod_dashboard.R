#' dashboard UI Function
#'
#' @description A shiny Module.
#'
#' @param id,input,output,session Internal parameters for {shiny}.
#'
#' @noRd
#'
#' @importFrom shiny NS tagList h1 dateRangeInput selectizeInput actionButton div
#' @importFrom DT dataTableOutput
#' @importFrom highcharter highchartOutput
#' @importFrom bslib value_box card card_header card_body page_sidebar sidebar layout_columns
#' @importFrom bsicons bs_icon
mod_dashboard_ui <- function(id) {
  ns <- NS(id)

  bslib::page_sidebar(
    title = "SUSNEO Energy Dashboard",
    sidebar = bslib::sidebar(
      width = 300,
      h3("Filters"),
      dateRangeInput(ns("date_range"),
        label = "Date Range",
        start = Sys.Date() - 30,
        end = Sys.Date()
      ),
      selectizeInput(ns("facilities"),
        label = "Facilities",
        choices = NULL,
        multiple = TRUE,
        options = list(placeholder = "Select facilities...")
      ),
      selectizeInput(ns("energy_types"),
        label = "Energy Types",
        choices = NULL,
        multiple = TRUE,
        options = list(placeholder = "Select energy types...")
      ),
      br(),
      div(
        style = "text-align: right;",
        actionButton(ns("reset_filters"),
          label = "Reset Filters",
          class = "btn-outline-secondary btn-sm"
        )
      )
    ),
    bslib::card(
      bslib::card_header("Key Performance Indicators"),
      bslib::card_body(
        mod_kpi_cards_ui(ns("kpi_cards"))
      )
    ),
    bslib::layout_columns(
      col_widths = c(6, 6),
      bslib::card(
        bslib::card_header("Energy Consumption Over Time"),
        bslib::card_body(
          highcharter::highchartOutput(ns("time_series_plot"))
        )
      ),
      bslib::card(
        bslib::card_header("Energy Usage by Facility"),
        bslib::card_body(
          highcharter::highchartOutput(ns("facility_comparison"))
        )
      )
    ),
    bslib::card(
      bslib::card_header("Data Summary"),
      bslib::card_body(
        DT::dataTableOutput(ns("data_table"))
      )
    )
  )
}

#' dashboard Server Functions
#'
#' @param data_manager Data manager instance from data upload module
#' @noRd
#' @importFrom shiny moduleServer reactive observe updateSelectizeInput
#' @importFrom shiny updateDateRangeInput renderUI observeEvent showNotification isolate
#' @importFrom DT renderDataTable datatable
#' @importFrom highcharter renderHighchart hchart hc_add_series hc_title hc_xAxis hc_yAxis
mod_dashboard_server <- function(id, data_manager) {
  moduleServer(id, function(input, output, session) {
    ns <- session$ns

    observe({
      req(data_manager$is_data_loaded())

      isolate({
        facilities <- data_manager$get_facilities()
        energy_types <- data_manager$get_energy_types()
        date_range <- data_manager$get_date_range()

        updateSelectizeInput(session, "facilities",
          choices = facilities,
          selected = NULL
        )

        updateSelectizeInput(session, "energy_types",
          choices = energy_types,
          selected = NULL
        )

        updateDateRangeInput(session, "date_range",
          start = date_range[1],
          end = date_range[2],
          min = date_range[1],
          max = date_range[2]
        )
      })
    })

    observeEvent(input$reset_filters, {
      if (data_manager$is_data_loaded()) {
        date_range <- data_manager$get_date_range()

        updateDateRangeInput(session, "date_range",
          start = date_range[1],
          end = date_range[2]
        )

        updateSelectizeInput(session, "facilities", selected = character(0))
        updateSelectizeInput(session, "energy_types", selected = character(0))

        showNotification(
          "Filters have been cleared",
          type = "message",
          duration = 5
        )
      }
    })

    filtered_data <- reactive({
      req(data_manager$is_data_loaded())

      data_manager$apply_filters(
        date_range = input$date_range,
        facilities = input$facilities,
        energy_types = input$energy_types
      )
    })

    # KPI Cards submodule
    mod_kpi_cards_server("kpi_cards", data_manager, filtered_data)

    # Charts using extracted functions
    output$time_series_plot <- highcharter::renderHighchart({
      data <- filtered_data()
      create_time_series_chart(data, data_manager)
    })

    output$facility_comparison <- highcharter::renderHighchart({
      data <- filtered_data()
      create_facility_chart(data, data_manager)
    })

    output$data_table <- DT::renderDataTable({
      data <- filtered_data()
      if (nrow(data) == 0) {
        return(data.frame())
      }

      summary_data <- data_manager$prepare_summary_data(data)

      DT::datatable(summary_data,
        rownames = FALSE,
        options = list(
          pageLength = 10,
          scrollX = TRUE,
          columnDefs = list(
            list(targets = c(2, 3, 4), className = "dt-right")
          )
        ),
        colnames = c(
          "Site", "Energy Type", "Total Consumption",
          "Total Emissions (kg CO2e)", "Avg. Consumption", "Records"
        )
      ) |>
        DT::formatCurrency(
          columns = c("total_consumption", "total_emissions", "avg_consumption"),
          currency = "",
          digits = 0,
          mark = ","
        )
    })
  })
}
