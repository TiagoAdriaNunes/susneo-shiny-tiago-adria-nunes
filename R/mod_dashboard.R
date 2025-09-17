#' dashboard UI Function
#'
#' @description A shiny Module.
#'
#' @param id,input,output,session Internal parameters for {shiny}.
#'
#' @noRd
#'
#' @importFrom shiny NS tagList fluidRow column h3 dateRangeInput selectizeInput verbatimTextOutput
#' @importFrom DT dataTableOutput
#' @importFrom plotly plotlyOutput
mod_dashboard_ui <- function(id) {
  ns <- NS(id)
  tagList(
    fluidRow(
      column(
        6,
        h3("Date Range"),
        dateRangeInput(ns("date_range"),
          label = NULL,
          start = Sys.Date() - 30,
          end = Sys.Date()
        )
      ),
      column(
        6,
        h3("Facilities"),
        selectizeInput(ns("facilities"),
          label = NULL,
          choices = NULL,
          multiple = TRUE,
          options = list(placeholder = "Select facilities...")
        )
      )
    ),
    fluidRow(
      column(
        4,
        h3("Total Energy Consumption"),
        verbatimTextOutput(ns("total_consumption"))
      ),
      column(
        4,
        h3("Total Carbon Emissions"),
        verbatimTextOutput(ns("total_emissions"))
      ),
      column(
        4,
        h3("Average Daily Usage"),
        verbatimTextOutput(ns("avg_daily_usage"))
      )
    ),
    fluidRow(
      column(
        6,
        h3("Energy Consumption Over Time"),
        plotly::plotlyOutput(ns("time_series_plot"))
      ),
      column(
        6,
        h3("Energy Usage by Facility"),
        plotly::plotlyOutput(ns("facility_comparison"))
      )
    ),
    fluidRow(
      column(
        12,
        h3("Data Summary"),
        DT::dataTableOutput(ns("data_table"))
      )
    )
  )
}

#' dashboard Server Functions
#'
#' @param data_reactive Reactive data from data upload module
#' @noRd
#' @importFrom shiny moduleServer reactive observe updateSelectizeInput renderText
#' @importFrom DT renderDataTable datatable
#' @importFrom plotly renderPlotly plot_ly add_trace layout
#' @importFrom dplyr filter group_by summarise mutate arrange
#' @importFrom lubridate as_date
mod_dashboard_server <- function(id, data_reactive) {
  moduleServer(id, function(input, output, session) {
    ns <- session$ns

    observe({
      req(data_reactive())
      data <- data_reactive()

      if (nrow(data) > 0 && "site" %in% names(data)) {
        facilities <- unique(data$site)
        updateSelectizeInput(session, "facilities",
          choices = facilities,
          selected = facilities
        )
      }
    })

    filtered_data <- reactive({
      req(data_reactive())
      data <- data_reactive()

      if (nrow(data) == 0) {
        return(data.frame())
      }

      data$date <- lubridate::as_date(data$date, format = "%d-%m-%Y")

      if (!is.null(input$date_range)) {
        data <- data[data$date >= input$date_range[1] & data$date <= input$date_range[2], ]
      }

      if (!is.null(input$facilities) && length(input$facilities) > 0) {
        data <- data[data$site %in% input$facilities, ]
      }

      data
    })

    output$total_consumption <- renderText({
      data <- filtered_data()
      if (nrow(data) == 0) {
        return("No data")
      }

      total <- sum(data$value, na.rm = TRUE)
      paste(format(total, big.mark = ","), "units")
    })

    output$total_emissions <- renderText({
      data <- filtered_data()
      if (nrow(data) == 0) {
        return("No data")
      }

      total <- sum(data$carbon_emission_in_kgco2e, na.rm = TRUE)
      paste(format(total, big.mark = ","), "kg CO2e")
    })

    output$avg_daily_usage <- renderText({
      data <- filtered_data()
      if (nrow(data) == 0) {
        return("No data")
      }

      daily_totals <- data |>
        dplyr::group_by(date) |>
        dplyr::summarise(daily_total = sum(value, na.rm = TRUE), .groups = "drop")

      avg_daily <- mean(daily_totals$daily_total, na.rm = TRUE)
      paste(format(round(avg_daily, 0), big.mark = ","), "units/day")
    })

    output$time_series_plot <- plotly::renderPlotly({
      data <- filtered_data()
      if (nrow(data) == 0) {
        return(plotly::plot_ly() |> plotly::layout(title = "No data available"))
      }

      daily_data <- data |>
        dplyr::group_by(date) |>
        dplyr::summarise(total_value = sum(value, na.rm = TRUE), .groups = "drop") |>
        dplyr::arrange(date)

      p <- plotly::plot_ly(daily_data, x = ~date, y = ~total_value, type = "scatter", mode = "lines+markers") |>
        plotly::layout(
          title = "Daily Energy Consumption",
          xaxis = list(title = "Date"),
          yaxis = list(title = "Energy Consumption (units)")
        )

      p
    })

    output$facility_comparison <- plotly::renderPlotly({
      data <- filtered_data()
      if (nrow(data) == 0) {
        return(plotly::plot_ly() |> plotly::layout(title = "No data available"))
      }

      facility_data <- data |>
        dplyr::group_by(site) |>
        dplyr::summarise(total_value = sum(value, na.rm = TRUE), .groups = "drop") |>
        dplyr::arrange(dplyr::desc(total_value))

      p <- plotly::plot_ly(facility_data, x = ~site, y = ~total_value, type = "bar") |>
        plotly::layout(
          title = "Total Energy Consumption by Facility",
          xaxis = list(title = "Facility"),
          yaxis = list(title = "Total Energy Consumption (units)")
        )

      p
    })

    output$data_table <- DT::renderDataTable({
      data <- filtered_data()
      if (nrow(data) == 0) {
        return(data.frame())
      }

      summary_data <- data |>
        dplyr::group_by(site, type) |>
        dplyr::summarise(
          total_consumption = sum(value, na.rm = TRUE),
          total_emissions = sum(carbon_emission_in_kgco2e, na.rm = TRUE),
          avg_consumption = round(mean(value, na.rm = TRUE), 2),
          records = dplyr::n(),
          .groups = "drop"
        ) |>
        dplyr::arrange(dplyr::desc(total_consumption))

      DT::datatable(summary_data,
        options = list(pageLength = 10, scrollX = TRUE),
        colnames = c(
          "Site", "Energy Type", "Total Consumption",
          "Total Emissions (kg CO2e)", "Avg Consumption", "Records"
        )
      )
    })
  })
}
