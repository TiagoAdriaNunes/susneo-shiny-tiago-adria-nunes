make_filtered_data <- function(n = 6) {
  data.frame(
    date = as.Date("2024-01-01") + seq_len(n) - 1,
    site = rep(c("Site A", "Site B"), length.out = n),
    type = rep(c("Electricity", "Gas", "Water"), length.out = n),
    value = c(8156, 96086, 12805, 46952, 75316, 40284)[seq_len(n)],
    carbon_emission_in_kgco2e = c(28, 79, 62, 75, 1, 53)[seq_len(n)]
  )
}

# UI --------------------------------------------------------------------------

test_that("mod_linear_model_ui creates the expected outputs", {
  ui_result <- mod_linear_model_ui("test_linear")
  ui_html <- as.character(ui_result)

  expect_true(inherits(ui_result, "shiny.tag"))
  expect_match(ui_html, "Linear Model")
  expect_match(ui_html, "Results")
  expect_match(ui_html, 'id="test_linear-model_summary_table"', fixed = TRUE)
  expect_match(ui_html, 'id="test_linear-model_interpretation"', fixed = TRUE)
  expect_match(ui_html, 'id="test_linear-scatter_plot"', fixed = TRUE)
})

# Server ----------------------------------------------------------------------

test_that("mod_linear_model_server fits the model once and renders every output", {
  data <- make_filtered_data()

  testServer(mod_linear_model_server, args = list(filtered_data = reactive(data)), {
    expect_s3_class(model(), "lm")

    expect_match(output$scatter_plot, "Regression Line")
    expect_match(output$scatter_plot, "CO2 Emissions vs Energy Consumption")
    expect_match(output$model_summary_table, "Interpretation")
    expect_match(output$model_interpretation$html, "What do these numbers mean?", fixed = TRUE)
    expect_match(output$model_interpretation$html, "relationship")
  })
})

test_that("mod_linear_model_server explains when there is too little data", {
  # A single point cannot be modelled
  one_row <- make_filtered_data(1)

  testServer(mod_linear_model_server, args = list(filtered_data = reactive(one_row)), {
    expect_null(model())
    expect_no_error(output$model_summary_table)
    expect_match(output$model_interpretation$html, "No model available")
    # The points are still plotted, just without a line
    expect_false(grepl("Regression Line", output$scatter_plot))
  })
})

test_that("mod_linear_model_server survives constant emissions", {
  # Regression: a constant predictor used to crash the summary table
  constant <- make_filtered_data()
  constant$carbon_emission_in_kgco2e <- 5

  testServer(mod_linear_model_server, args = list(filtered_data = reactive(constant)), {
    expect_null(model())
    expect_no_error(output$model_summary_table)
    expect_match(output$model_interpretation$html, "No model available")
    expect_false(grepl("Regression Line", output$scatter_plot))
  })
})

test_that("mod_linear_model_server does not warn when it cannot fit a model", {
  constant <- make_filtered_data()
  constant$carbon_emission_in_kgco2e <- 5

  testServer(mod_linear_model_server, args = list(filtered_data = reactive(constant)), {
    expect_no_warning(model())
  })
})

test_that("mod_linear_model_server ignores rows with missing values", {
  with_na <- make_filtered_data()
  with_na$value[2] <- NA
  with_na$carbon_emission_in_kgco2e[3] <- NA

  testServer(mod_linear_model_server, args = list(filtered_data = reactive(with_na)), {
    expect_equal(nobs(model()), 4)
    expect_match(output$scatter_plot, "Regression Line")
  })
})

test_that("mod_linear_model_server handles data without the emissions column", {
  no_emissions <- make_filtered_data()[, c("date", "site", "type", "value")]

  testServer(mod_linear_model_server, args = list(filtered_data = reactive(no_emissions)), {
    expect_null(model())
    expect_no_error(output$model_summary_table)
    expect_match(output$model_interpretation$html, "No model available")
    expect_error(output$scatter_plot, class = "shiny.silent.error")
  })
})

test_that("mod_linear_model_server stays silent for empty data", {
  testServer(mod_linear_model_server, args = list(filtered_data = reactive(data.frame())), {
    expect_error(model(), class = "shiny.silent.error")
    expect_error(output$model_summary_table, class = "shiny.silent.error")
    expect_error(output$model_interpretation, class = "shiny.silent.error")
    expect_error(output$scatter_plot, class = "shiny.silent.error")
  })
})

test_that("mod_linear_model_server follows changes in the data", {
  filtered_data <- reactiveVal(make_filtered_data(2))

  testServer(mod_linear_model_server, args = list(filtered_data = filtered_data), {
    expect_null(model())

    filtered_data(make_filtered_data(6))
    expect_s3_class(model(), "lm")
  })
})
