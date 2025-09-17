test_that("create_efficiency_value_box calculates efficiency correctly with valid data", {
  # Create mock data manager
  session <- shiny::MockShinySession$new()

  shiny::withReactiveDomain(session, {
    dm <- data_manager$new()

    # Test data with consumption and emissions
    test_data <- data.frame(
      site = c("Site_A", "Site_B"),
      date = c("01-08-2025", "02-08-2025"),
      type = c("Electricity", "Gas"),
      value = c(1000, 500),
      carbon_emission_in_kgco2e = c(100, 50)
    )

    # Create the efficiency value box
    result <- create_efficiency_value_box(test_data, dm)

    # Check that it returns a bslib value_box (which is rendered as a div)
    expect_true(inherits(result, "shiny.tag"))
    expect_equal(result$name, "div")

    # Convert to HTML and check content
    result_html <- as.character(result)

    # Check for correct title
    expect_true(grepl("Energy Efficiency Ratio", result_html))

    # Check for efficiency calculation (1500 consumption / 150 emissions = 10)
    expect_true(grepl("10", result_html))
    expect_true(grepl("units/kg CO2e", result_html))

    # Check for correct theme and icon
    expect_true(grepl("speedometer2", result_html))
    expect_true(grepl("success", result_html))
    expect_true(grepl("150px", result_html))
  })
})

test_that("create_efficiency_value_box handles zero emissions correctly", {
  session <- shiny::MockShinySession$new()

  shiny::withReactiveDomain(session, {
    dm <- data_manager$new()

    # Test data with zero emissions
    test_data <- data.frame(
      site = c("Site_A", "Site_B"),
      date = c("01-08-2025", "02-08-2025"),
      type = c("Electricity", "Gas"),
      value = c(1000, 500),
      carbon_emission_in_kgco2e = c(0, 0)
    )

    result <- create_efficiency_value_box(test_data, dm)
    result_html <- as.character(result)

    # When emissions are zero, efficiency should be 0
    expect_true(grepl("0 units/kg CO2e", result_html))
    expect_true(grepl("Energy Efficiency Ratio", result_html))
  })
})

test_that("create_efficiency_value_box handles empty data correctly", {
  session <- shiny::MockShinySession$new()

  shiny::withReactiveDomain(session, {
    dm <- data_manager$new()

    # Empty test data
    test_data <- data.frame(
      site = character(0),
      date = character(0),
      type = character(0),
      value = numeric(0),
      carbon_emission_in_kgco2e = numeric(0)
    )

    result <- create_efficiency_value_box(test_data, dm)
    result_html <- as.character(result)

    # Should still return a value box with zero efficiency
    expect_true(inherits(result, "shiny.tag"))
    expect_equal(result$name, "div")
    expect_true(grepl("Energy Efficiency Ratio", result_html))
    expect_true(grepl("0 units/kg CO2e", result_html))
  })
})

test_that("create_efficiency_value_box uses correct formatting", {
  session <- shiny::MockShinySession$new()

  shiny::withReactiveDomain(session, {
    dm <- data_manager$new()

    # Test data that results in a decimal efficiency ratio
    test_data <- data.frame(
      site = "Site_A",
      date = "01-08-2025",
      type = "Electricity",
      value = 1500,
      carbon_emission_in_kgco2e = 250
    )

    result <- create_efficiency_value_box(test_data, dm)
    result_html <- as.character(result)

    # Check that the efficiency is formatted correctly (1500/250 = 6)
    expect_true(grepl("6 units/kg CO2e", result_html))

    # Verify the format_number_with_commas function is used
    expect_true(grepl("units/kg CO2e", result_html))
  })
})

test_that("create_efficiency_value_box has correct bslib structure and content", {
  session <- shiny::MockShinySession$new()

  shiny::withReactiveDomain(session, {
    dm <- data_manager$new()

    test_data <- data.frame(
      site = "Site_A",
      date = "01-08-2025",
      type = "Electricity",
      value = 1000,
      carbon_emission_in_kgco2e = 100
    )

    result <- create_efficiency_value_box(test_data, dm)
    result_html <- as.character(result)

    # Check that it's a proper HTML element
    expect_true(inherits(result, "shiny.tag"))
    expect_equal(result$name, "div")

    # Check for the essential content
    expect_true(grepl('Energy Efficiency Ratio', result_html))
    expect_true(grepl('10 units/kg CO2e', result_html))

    # Check that it contains value box related classes/structure
    expect_true(grepl('value.box|bslib', result_html))
  })
})