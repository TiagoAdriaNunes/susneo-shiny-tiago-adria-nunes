#' Linear Model UI Function
#'
#' @description A shiny Module for linear model analysis.
#'
#' @param id,input,output,session Internal parameters for {shiny}.
#'
#' @noRd
#'
#' @importFrom shiny NS h5 htmlOutput br fluidRow column
#' @importFrom bslib card card_header card_body
#' @importFrom DT dataTableOutput
#' @importFrom highcharter highchartOutput
mod_linear_model_ui <- function(id) {
  ns <- NS(id)

  bslib::card(
    min_height = 350,
    full_screen = TRUE,
    bslib::card_header("Linear Model: CO2 Emissions vs Energy Consumption"),
    bslib::card_body(
      shiny::fluidRow(
        shiny::column(
          width = 6,
          shiny::h5("Results"),
          DT::dataTableOutput(ns("model_summary_table"))
        ),
        shiny::column(
          width = 6,
          shiny::htmlOutput(ns("model_interpretation"))
        )
      ),
      shiny::br(),
      shiny::fluidRow(
        shiny::column(
          width = 12,
          highcharter::highchartOutput(ns("scatter_plot"))
        )
      )
    )
  )
}

#' Linear Model Server Functions
#'
#' @param id Module ID
#' @param data_manager Data manager instance
#' @param filtered_data Reactive filtered data
#'
#' @noRd
#' @importFrom shiny moduleServer renderUI req
#' @importFrom DT renderDataTable datatable
#' @importFrom highcharter renderHighchart hchart hcaes hc_title hc_xAxis hc_yAxis hc_tooltip hc_add_series
#' @importFrom glue glue
#' @importFrom stats pf predict
mod_linear_model_server <- function(id, data_manager, filtered_data) {
  moduleServer(id, function(input, output, session) {
    ns <- session$ns

    output$scatter_plot <- highcharter::renderHighchart({
      data <- filtered_data()
      req(data)
      req(nrow(data) > 0)
      req("carbon_emission_in_kgco2e" %in% names(data))
      req("value" %in% names(data))

      # Remove rows with missing values
      plot_data <- data[!is.na(data$carbon_emission_in_kgco2e) & !is.na(data$value), ]

      if (nrow(plot_data) == 0) {
        empty_data <- data.frame(x = 0, y = 0)
        return(highcharter::hchart(empty_data, "scatter",
                                   highcharter::hcaes(x = "x", y = "y")) |>
                 highcharter::hc_title(text = "No data available"))
      }

      # Fit model for regression line
      model <- data_manager$fit_linear_model(plot_data)

      hc <- highcharter::hchart(plot_data, "scatter",
                                highcharter::hcaes(x = "carbon_emission_in_kgco2e",
                                                   y = "value"),
                                color = "#007bc2") |>
        highcharter::hc_title(text = "CO2 Emissions vs Energy Consumption") |>
        highcharter::hc_xAxis(title = list(text = "CO2 Emissions (kg CO2e)")) |>
        highcharter::hc_yAxis(title = list(text = "Energy Consumption")) |>
        highcharter::hc_tooltip(
          pointFormat = "<b>CO2:</b> {point.x:.1f} kg<br><b>Energy:</b> {point.y:.0f}"
        )

      # Add regression line if model exists
      if (!is.null(model)) {
        x_range <- range(plot_data$carbon_emission_in_kgco2e, na.rm = TRUE)
        x_seq <- seq(x_range[1], x_range[2], length.out = 100)
        y_pred <- predict(model, newdata = data.frame(carbon_emission_in_kgco2e = x_seq))

        regression_data <- data.frame(x = x_seq, y = y_pred)

        hc <- hc |>
          highcharter::hc_add_series(
            data = regression_data,
            type = "line",
            name = "Regression Line",
            color = "#ff6b6b",
            marker = list(enabled = FALSE),
            enableMouseTracking = FALSE
          )
      }

      hc
    })

    output$model_summary_table <- DT::renderDataTable({
      data <- filtered_data()
      req(data)
      req(nrow(data) > 0)

      model <- data_manager$fit_linear_model(data)

      if (is.null(model)) {
        summary_df <- data.frame(
          Metric = "No Model Available",
          Value = "Insufficient data"
        )
      } else {
        model_summary <- summary(model)
        coeffs <- model_summary$coefficients

        summary_df <- data.frame(
          Metric = c(
            "Intercept",
            "CO2 Coefficient",
            "R-squared",
            "Adjusted R-squared",
            "F-statistic",
            "Model p-value",
            "Observations"
          ),
          Value = c(
            round(coeffs[1, 1], 3),
            round(coeffs[2, 1], 3),
            round(model_summary$r.squared, 4),
            round(model_summary$adj.r.squared, 4),
            round(model_summary$fstatistic[1], 2),
            format(pf(model_summary$fstatistic[1], model_summary$fstatistic[2],
                      model_summary$fstatistic[3], lower.tail = FALSE),
                   scientific = TRUE, digits = 3),
            nrow(data)
          ),
          Interpretation = c(
            "Energy consumption when CO2 = 0",
            "Energy change per 1 kg CO2 increase",
            "Proportion of variance explained",
            "Adjusted for model complexity",
            "Overall model significance test",
            "Probability model is due to chance",
            "Number of data points used"
          )
        )
      }

      DT::datatable(
        summary_df,
        rownames = FALSE,
        options = list(
          dom = "t",
          pageLength = 15,
          scrollX = TRUE
        )
      )
    })

    output$model_interpretation <- shiny::renderUI({
      data <- filtered_data()
      req(data)
      req(nrow(data) > 0)

      model <- data_manager$fit_linear_model(data)

      if (is.null(model)) {
        shiny::p("No model available for interpretation.")
      } else {
        model_summary <- summary(model)
        coeffs <- model_summary$coefficients
        r_squared <- model_summary$r.squared
        p_value <- pf(
          model_summary$fstatistic[1],
          model_summary$fstatistic[2],
          model_summary$fstatistic[3],
          lower.tail = FALSE
        )

        # Interpretation of coefficients
        intercept <- coeffs[1, 1]
        slope <- coeffs[2, 1]
        slope_pvalue <- coeffs[2, 4]

        # R-squared interpretation
        r_sq_percent <- round(r_squared * 100, 1)

        # Significance levels with detailed explanation
        slope_sig <- if (slope_pvalue < 0.001) {
          "highly significant (p < 0.001) - very strong evidence of a real relationship"
        } else if (slope_pvalue < 0.01) {
          "significant (p < 0.01) - strong evidence of a real relationship"
        } else if (slope_pvalue < 0.05) {
          "significant (p < 0.05) - evidence of a real relationship"
        } else {
          glue::glue("not significant (p = {round(slope_pvalue, 3)}) - insufficient evidence of a real relationship. ",
                     "This could be due to random chance, small sample size, or no actual relationship exists")
        }

        relationship <- if (slope > 0) "positive" else "negative"
        slope_rounded <- round(slope, 2)

        # Model fit interpretation
        fit_interpretation <- if (r_squared >= 0.7) {
          "The model explains the data very well."
        } else if (r_squared >= 0.5) {
          "The model explains the data reasonably well."
        } else if (r_squared >= 0.3) {
          "The model explains some of the variation in the data."
        } else {
          "The model explains little of the variation in the data."
        }

        shiny::div(
          shiny::h5("What do these numbers mean?"),
          shiny::tags$ul(
            shiny::tags$li(
              shiny::strong("Relationship: "),
              glue::glue(
                "There is a {relationship} relationship between CO2 emissions and energy consumption."
              )
            ),
            shiny::tags$li(
              shiny::strong(glue::glue("Slope ({slope_rounded}): ")),
              glue::glue(
                "For every 1 kg increase in CO2 emissions, ",
                "energy consumption changes by {slope_rounded} units on average."
              )
            ),
            shiny::tags$li(
              shiny::strong("Statistical Significance: "),
              glue::glue("This relationship is {slope_sig}.")
            ),
            shiny::tags$li(
              shiny::strong(glue::glue("Model Fit (R\u00b2={r_sq_percent}%): ")),
              fit_interpretation
            )
          )
        )
      }
    })
  })
}
