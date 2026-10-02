#' Linear Model UI Function
#'
#' @description A shiny Module for linear model analysis.
#'
#' @param id,input,output,session Internal parameters for {shiny}.
#'
#' @noRd
#'
#' @importFrom bslib card card_body card_header
#' @importFrom DT datatable dataTableOutput renderDataTable
#' @importFrom highcharter hc_add_series hc_title hc_tooltip hc_xAxis hc_yAxis hcaes hchart highchartOutput
#' @importFrom highcharter renderHighchart
#' @importFrom shiny br column fluidRow h5 htmlOutput moduleServer NS p reactive renderUI req
#' @importFrom stats predict
mod_linear_model_ui <- function(id) {
  ns <- NS(id)

  card(
    min_height = 350,
    full_screen = TRUE,
    card_header("Linear Model: CO2 Emissions vs Energy Consumption"),
    card_body(
      fluidRow(
        column(
          width = 6,
          h5("Results"),
          dataTableOutput(ns("model_summary_table"))
        ),
        column(
          width = 6,
          htmlOutput(ns("model_interpretation"))
        )
      ),
      br(),
      fluidRow(
        column(
          width = 12,
          highchartOutput(ns("scatter_plot"))
        )
      )
    )
  )
}

#' Linear Model Server Functions
#'
#' @param id Module ID
#' @param filtered_data Reactive filtered data
#'
#' @noRd
mod_linear_model_server <- function(id, filtered_data) {
  moduleServer(id, function(input, output, session) {
    # Fit once and share the model between the three outputs. The outputs
    # explain missing models themselves, so the fit warnings are not needed.
    model <- reactive({
      data <- filtered_data()
      req(nrow(data) > 0)
      suppressWarnings(fit_linear_model(data))
    })

    model_stats <- reactive({
      fit <- model()
      if (!is.null(fit)) summarise_linear_model(fit)
    })

    output$scatter_plot <- renderHighchart({
      data <- filtered_data()
      req(nrow(data) > 0)
      req(all(c(emissions_column, "value") %in% names(data)))

      plot_data <- data[!is.na(data[[emissions_column]]) & !is.na(data$value), ]

      if (nrow(plot_data) == 0) {
        return(create_empty_chart("No data available"))
      }

      hc <- hchart(
        plot_data,
        "scatter",
        hcaes(x = "carbon_emission_in_kgco2e", y = "value"),
        color = get_primary_color()
      ) |>
        hc_title(text = "CO2 Emissions vs Energy Consumption") |>
        hc_xAxis(title = list(text = "CO2 Emissions (kg CO2e)")) |>
        hc_yAxis(title = list(text = "Energy Consumption")) |>
        hc_tooltip(
          pointFormat = "<b>CO2:</b> {point.x:.1f} kg<br><b>Energy:</b> {point.y:.0f}"
        )

      fit <- model()

      if (is.null(fit)) {
        hc
      } else {
        x_range <- range(plot_data[[emissions_column]], na.rm = TRUE)
        x_seq <- seq(x_range[1], x_range[2], length.out = 100)
        y_pred <- predict(fit, newdata = data.frame(carbon_emission_in_kgco2e = x_seq))

        hc |>
          hc_add_series(
            data = data.frame(x = x_seq, y = y_pred),
            type = "line",
            name = "Regression Line",
            color = "#ff6b6b",
            marker = list(enabled = FALSE),
            enableMouseTracking = FALSE
          )
      }
    })

    output$model_summary_table <- renderDataTable({
      model_stats <- model_stats()

      summary_df <- if (is.null(model_stats)) {
        data.frame(
          Metric = "No Model Available",
          Value = "Insufficient data"
        )
      } else {
        build_model_summary_table(model_stats)
      }

      datatable(
        summary_df,
        rownames = FALSE,
        options = list(
          dom = "t",
          pageLength = 15,
          scrollX = TRUE
        )
      )
    })

    output$model_interpretation <- renderUI({
      model_stats <- model_stats()

      if (is.null(model_stats)) {
        p("No model available for interpretation.")
      } else {
        create_model_interpretation(model_stats)
      }
    })
  })
}
