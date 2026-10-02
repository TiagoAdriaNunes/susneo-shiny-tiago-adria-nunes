#' dashboard UI Function
#'
#' @description A shiny Module.
#'
#' @param id,input,output,session Internal parameters for {shiny}.
#'
#' @noRd
#'
#' @importFrom bsicons bs_icon
#' @importFrom bslib card card_body card_header layout_column_wrap page_sidebar sidebar
#' @importFrom DT datatable dataTableOutput formatRound renderDataTable
#' @importFrom highcharter highchartOutput renderHighchart
#' @importFrom shiny actionButton br dateRangeInput debounce div h3 moduleServer NS observe observeEvent reactive
#' @importFrom shiny renderUI req selectizeInput showNotification tagList tags uiOutput updateDateRangeInput
#' @importFrom shiny updateSelectizeInput
mod_dashboard_ui <- function(id) {
  ns <- NS(id)

  page_sidebar(
    title = "SUSNEO Energy Dashboard",
    sidebar = sidebar(
      width = 300,
      h3("Filters"),
      dateRangeInput(
        ns("date_range"),
        label = "Date Range",
        start = Sys.Date() - 30,
        end = Sys.Date(),
        format = "mm/dd/yyyy",
        language = "en",
        separator = " to "
      ),
      selectizeInput(
        ns("facilities"),
        label = "Facilities",
        choices = NULL,
        multiple = TRUE,
        options = list(placeholder = "Select facilities...")
      ),
      selectizeInput(
        ns("energy_types"),
        label = "Energy Types",
        choices = NULL,
        multiple = TRUE,
        options = list(placeholder = "Select energy types...")
      ),
      br(),
      div(
        style = "text-align: right;",
        actionButton(
          ns("reset_filters"),
          label = "Reset Filters",
          class = "btn-outline-secondary btn-sm"
        )
      )
    ),
    uiOutput(ns("mixed_units_note")),
    mod_kpi_cards_ui(ns("kpi_cards")),
    layout_column_wrap(
      width = "500px",
      fill = FALSE,
      card(
        full_screen = TRUE,
        card_header("Energy Consumption Over Time"),
        card_body(
          highchartOutput(ns("time_series_plot"))
        )
      ),
      card(
        full_screen = TRUE,
        card_header("Energy Usage by Facility"),
        card_body(
          highchartOutput(ns("facility_comparison"))
        )
      )
    ),
    card(
      min_height = 400,
      full_screen = TRUE,
      card_header("Data Summary"),
      card_body(
        dataTableOutput(ns("data_table"))
      )
    ),
    mod_linear_model_ui(ns("linear_model"))
  )
}

#' dashboard Server Functions
#'
#' @param id Module ID
#' @param data_manager Reactive returning an `EnergyDataManager`
#'
#' @return The debounced reactive with the filtered data
#'
#' @noRd
mod_dashboard_server <- function(id, data_manager) {
  moduleServer(id, function(input, output, session) {
    # Refresh the filter choices whenever new data is loaded
    observe({
      dm <- data_manager()
      req(dm$has_data())

      date_range <- dm$date_range()

      updateSelectizeInput(
        session,
        "facilities",
        choices = dm$facilities(),
        selected = NULL
      )

      updateSelectizeInput(
        session,
        "energy_types",
        choices = dm$energy_types(),
        selected = NULL
      )

      updateDateRangeInput(
        session,
        "date_range",
        start = date_range[1],
        end = date_range[2],
        min = date_range[1],
        max = date_range[2]
      )
    })

    observeEvent(input$reset_filters, {
      dm <- data_manager()

      if (dm$has_data()) {
        date_range <- dm$date_range()

        updateDateRangeInput(
          session,
          "date_range",
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
      dm <- data_manager()
      req(dm$has_data())
      req(length(input$date_range) == 2)

      dm$filter(
        date_range = input$date_range,
        facilities = input$facilities,
        energy_types = input$energy_types
      )
    }) |>
      debounce(500) # 500ms delay to prevent rapid re-rendering

    # KPI Cards submodule
    mod_kpi_cards_server("kpi_cards", filtered_data)

    # Linear Model submodule
    mod_linear_model_server("linear_model", filtered_data)

    output$mixed_units_note <- renderUI({
      message <- mixed_units_message(filtered_data())
      req(message)

      div(
        class = "alert alert-warning py-2 mb-0",
        role = "alert",
        bs_icon("exclamation-triangle"),
        " ",
        message
      )
    })

    # Charts using extracted functions with validation
    output$time_series_plot <- renderHighchart({
      data <- filtered_data()
      req(nrow(data) > 0)

      create_time_series_chart(data)
    })

    output$facility_comparison <- renderHighchart({
      data <- filtered_data()
      req(nrow(data) > 0)

      create_facility_chart(data)
    })

    output$data_table <- renderDataTable({
      data <- filtered_data()

      if (nrow(data) == 0) {
        return(datatable(
          data.frame("No data available" = character(0)),
          rownames = FALSE,
          options = list(dom = "t")
        ))
      }

      datatable(
        prepare_summary_data(data),
        rownames = FALSE,
        options = list(
          pageLength = 10,
          scrollX = TRUE,
          columnDefs = list(
            list(targets = c(2, 3, 4), className = "dt-right")
          )
        ),
        colnames = c(
          "Site",
          "Energy Type",
          "Total Consumption",
          "Total Emissions (kg CO2e)",
          "Avg. Consumption",
          "Records"
        )
      ) |>
        formatRound(
          columns = c(
            "total_consumption",
            "total_emissions",
            "avg_consumption"
          ),
          digits = 0,
          mark = ","
        )
    })

    filtered_data
  })
}
