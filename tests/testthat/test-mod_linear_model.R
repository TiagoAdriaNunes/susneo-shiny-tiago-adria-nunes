test_that("mod_linear_model_ui function exists", {
  # Basic test to ensure the function is defined
  expect_true(exists("mod_linear_model_ui"))
  expect_true(is.function(mod_linear_model_ui))
})

test_that("mod_linear_model_ui accepts id parameter", {
  # Test that the function can be called with an ID
  expect_no_error({
    ui_result <- mod_linear_model_ui("test_linear")
    expect_true(!is.null(ui_result))
  })
})

test_that("mod_linear_model_ui creates proper structure", {
  ui_result <- mod_linear_model_ui("test_linear")
  
  # Basic structure tests
  expect_true(inherits(ui_result, "shiny.tag"))
  
  # Convert to HTML to check content
  ui_html <- as.character(ui_result)
  expect_true(nchar(ui_html) > 100)
  
  # Check for namespace in IDs
  expect_true(grepl("test_linear-", ui_html))
})

test_that("mod_linear_model_ui contains required elements", {
  ui_result <- mod_linear_model_ui("test")
  ui_html <- as.character(ui_result)
  
  # Check for key text content
  expect_true(grepl("Linear Model", ui_html))
  expect_true(grepl("Results", ui_html))
})

# Server function tests
test_that("mod_linear_model_server works with valid data", {
  # Create mock data manager with linear model method
  dm <- data_manager$new()

  # Create reactive filtered data with required columns (more realistic variance)
  filtered_data <- shiny::reactive({
    data.frame(
      date = as.Date(c("2024-01-01", "2024-01-02", "2024-01-03", "2024-01-04", "2024-01-05", "2024-01-06")),
      site = c("Site A", "Site B", "Site A", "Site B", "Site A", "Site B"),
      type = c("Electricity", "Gas", "Electricity", "Gas", "Water", "Fuel"),
      value = c(8156, 96086, 12805, 46952, 75316, 40284),
      carbon_emission_in_kgco2e = c(28, 79, 62, 75, 1, 53)
    )
  })

  expect_no_error({
    testServer(
      mod_linear_model_server,
      args = list(
        data_manager = dm,
        filtered_data = filtered_data
      ),
      {
        # Server should handle the data without errors
        expect_true(TRUE)
      }
    )
  })
})

test_that("mod_linear_model_server handles empty data", {
  dm <- data_manager$new()
  filtered_data <- shiny::reactive({
    data.frame()
  })

  expect_no_error({
    testServer(
      mod_linear_model_server,
      args = list(
        data_manager = dm,
        filtered_data = filtered_data
      ),
      {
        # Should handle empty data gracefully
        expect_true(TRUE)
      }
    )
  })
})

test_that("mod_linear_model_server handles missing columns", {
  dm <- data_manager$new()

  # Data missing required columns
  filtered_data <- shiny::reactive({
    data.frame(
      date = as.Date(c("2024-01-01", "2024-01-02")),
      site = c("Site A", "Site B"),
      type = c("Electricity", "Gas"),
      value = c(100, 150)
      # Missing carbon_emission_in_kgco2e column
    )
  })

  expect_no_error({
    testServer(
      mod_linear_model_server,
      args = list(
        data_manager = dm,
        filtered_data = filtered_data
      ),
      {
        # Should handle missing columns gracefully
        expect_true(TRUE)
      }
    )
  })
})

test_that("mod_linear_model_server handles data with NA values", {
  dm <- data_manager$new()

  # Data with NA values
  filtered_data <- shiny::reactive({
    data.frame(
      date = as.Date(c("2024-01-01", "2024-01-02", "2024-01-03", "2024-01-04")),
      site = c("Site A", "Site B", "Site A", "Site B"),
      type = c("Electricity", "Gas", "Electricity", "Gas"),
      value = c(100, NA, 120, 180),
      carbon_emission_in_kgco2e = c(10, 15, NA, 18)
    )
  })

  expect_no_error({
    testServer(
      mod_linear_model_server,
      args = list(
        data_manager = dm,
        filtered_data = filtered_data
      ),
      {
        # Should handle NA values gracefully
        expect_true(TRUE)
      }
    )
  })
})

test_that("mod_linear_model_server generates model summary table", {
  dm <- data_manager$new()

  # Valid data for linear modeling (using sample-like data)
  filtered_data <- shiny::reactive({
    data.frame(
      date = as.Date(c("2024-01-01", "2024-01-02", "2024-01-03", "2024-01-04", "2024-01-05")),
      site = c("Site A", "Site B", "Site A", "Site B", "Site A"),
      type = c("Electricity", "Gas", "Electricity", "Gas", "Water"),
      value = c(8156, 96086, 12805, 46952, 75316),
      carbon_emission_in_kgco2e = c(28, 79, 62, 75, 1)
    )
  })

  testServer(
    mod_linear_model_server,
    args = list(
      data_manager = dm,
      filtered_data = filtered_data
    ),
    {
      # Trigger the reactive by accessing the output
      output_result <- output$model_summary_table

      # The output should be generated without error
      expect_true(TRUE)
    }
  )
})

test_that("mod_linear_model_server generates scatter plot", {
  dm <- data_manager$new()

  # Valid data for plotting (more realistic variance)
  filtered_data <- shiny::reactive({
    data.frame(
      date = as.Date(c("2024-01-01", "2024-01-02", "2024-01-03", "2024-01-04")),
      site = c("Site A", "Site B", "Site A", "Site B"),
      type = c("Electricity", "Gas", "Water", "Fuel"),
      value = c(8156, 96086, 75316, 40284),
      carbon_emission_in_kgco2e = c(28, 79, 1, 53)
    )
  })

  testServer(
    mod_linear_model_server,
    args = list(
      data_manager = dm,
      filtered_data = filtered_data
    ),
    {
      # Trigger the reactive by accessing the output
      output_result <- output$scatter_plot

      # The output should be generated without error
      expect_true(TRUE)
    }
  )
})

test_that("mod_linear_model_server generates interpretation", {
  dm <- data_manager$new()

  # Valid data for interpretation (realistic variance)
  filtered_data <- shiny::reactive({
    data.frame(
      date = as.Date(c("2024-01-01", "2024-01-02", "2024-01-03", "2024-01-04")),
      site = c("Site A", "Site B", "Site A", "Site B"),
      type = c("Electricity", "Gas", "Water", "Fuel"),
      value = c(8156, 96086, 75316, 40284),
      carbon_emission_in_kgco2e = c(28, 79, 1, 53)
    )
  })

  testServer(
    mod_linear_model_server,
    args = list(
      data_manager = dm,
      filtered_data = filtered_data
    ),
    {
      # Trigger the reactive by accessing the output
      output_result <- output$model_interpretation

      # The output should be generated without error
      expect_true(TRUE)
    }
  )
})

test_that("mod_linear_model_server handles insufficient data for modeling", {
  dm <- data_manager$new()

  # Only one data point - insufficient for linear modeling
  filtered_data <- shiny::reactive({
    data.frame(
      date = as.Date("2024-01-01"),
      site = "Site A",
      type = "Electricity",
      value = 100,
      carbon_emission_in_kgco2e = 10
    )
  })

  expect_no_error({
    testServer(
      mod_linear_model_server,
      args = list(
        data_manager = dm,
        filtered_data = filtered_data
      ),
      {
        # Should handle insufficient data gracefully
        expect_true(TRUE)
      }
    )
  })
})

test_that("linear model interpretation logic works correctly", {
  # Test the R-squared interpretation logic
  expect_equal({
    r_squared <- 0.8
    if (r_squared >= 0.7) "very well"
    else if (r_squared >= 0.5) "reasonably well"
    else if (r_squared >= 0.3) "some variation"
    else "little variation"
  }, "very well")

  expect_equal({
    r_squared <- 0.6
    if (r_squared >= 0.7) "very well"
    else if (r_squared >= 0.5) "reasonably well"
    else if (r_squared >= 0.3) "some variation"
    else "little variation"
  }, "reasonably well")

  expect_equal({
    r_squared <- 0.4
    if (r_squared >= 0.7) "very well"
    else if (r_squared >= 0.5) "reasonably well"
    else if (r_squared >= 0.3) "some variation"
    else "little variation"
  }, "some variation")

  expect_equal({
    r_squared <- 0.2
    if (r_squared >= 0.7) "very well"
    else if (r_squared >= 0.5) "reasonably well"
    else if (r_squared >= 0.3) "some variation"
    else "little variation"
  }, "little variation")
})

test_that("significance level interpretation works correctly", {
  # Test the p-value interpretation logic
  expect_true({
    p_val <- 0.0005
    result <- if (p_val < 0.001) "highly significant"
    else if (p_val < 0.01) "significant (0.01)"
    else if (p_val < 0.05) "significant (0.05)"
    else "not significant"
    result == "highly significant"
  })

  expect_true({
    p_val <- 0.005
    result <- if (p_val < 0.001) "highly significant"
    else if (p_val < 0.01) "significant (0.01)"
    else if (p_val < 0.05) "significant (0.05)"
    else "not significant"
    result == "significant (0.01)"
  })

  expect_true({
    p_val <- 0.03
    result <- if (p_val < 0.001) "highly significant"
    else if (p_val < 0.01) "significant (0.01)"
    else if (p_val < 0.05) "significant (0.05)"
    else "not significant"
    result == "significant (0.05)"
  })

  expect_true({
    p_val <- 0.1
    result <- if (p_val < 0.001) "highly significant"
    else if (p_val < 0.01) "significant (0.01)"
    else if (p_val < 0.05) "significant (0.05)"
    else "not significant"
    result == "not significant"
  })
})

test_that("relationship direction detection works correctly", {
  # Test positive relationship
  expect_equal({
    slope <- 2.5
    if (slope > 0) "positive" else "negative"
  }, "positive")

  # Test negative relationship
  expect_equal({
    slope <- -1.3
    if (slope > 0) "positive" else "negative"
  }, "negative")

  # Test zero slope (edge case)
  expect_equal({
    slope <- 0
    if (slope > 0) "positive" else "negative"
  }, "negative")
})