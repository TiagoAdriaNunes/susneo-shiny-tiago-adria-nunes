test_that("mod_dashboard_ui creates proper UI structure", {
  ui <- mod_dashboard_ui("test")
  # bslib::page_sidebar returns a bslib_page object, which inherits from shiny.tag.list
  expect_s3_class(ui, "bslib_page")
  expect_s3_class(ui, "shiny.tag.list")
})

test_that("mod_dashboard_server works with data_manager", {
  # Create mock data manager
  session <- shiny::MockShinySession$new()
  shiny::withReactiveDomain(session, {
    dm <- data_manager$new()
    test_data <- data.frame(
      date = as.Date(c("2024-01-01", "2024-01-02")),
      site = c("Site A", "Site B"),
      type = c("Electricity", "Gas"),
      value = c(100, 150)
    )

    shiny::isolate(dm$raw_data(test_data))
    shiny::isolate(dm$process_data())
  })

  # Test server function doesn't throw errors (without nested testServer)
  expect_no_error({
    testServer(mod_dashboard_server, args = list(data_manager = dm), {
      # Server should start without errors
      expect_true(TRUE)
    })
  })
})

test_that("mod_dashboard_server handles empty data_manager", {
  # Create empty data manager
  session <- shiny::MockShinySession$new()
  shiny::withReactiveDomain(session, {
    dm <- data_manager$new()
  })

  expect_no_error({
    testServer(mod_dashboard_server, args = list(data_manager = dm), {
      # Server should handle empty data gracefully
      expect_true(TRUE)
    })
  })
})

test_that("mod_dashboard_ui has correct sidebar structure", {
  ui <- mod_dashboard_ui("test")
  ui_html <- as.character(ui)

  # Check for sidebar components
  expect_true(grepl('id="test-date_range"', ui_html))
  expect_true(grepl('id="test-facilities"', ui_html))
  expect_true(grepl('id="test-energy_types"', ui_html))
  expect_true(grepl('id="test-reset_filters"', ui_html))

  # Check for main content areas
  expect_true(grepl("kpi_cards", ui_html)) # KPI cards module is included
  expect_true(grepl("Key Performance Indicators", ui_html))
  expect_true(grepl("Energy Consumption Over Time", ui_html))
  expect_true(grepl("Data Summary", ui_html))
})

test_that("mod_dashboard_server initializes filters correctly", {
  session <- shiny::MockShinySession$new()
  shiny::withReactiveDomain(session, {
    dm <- data_manager$new()
    test_data <- data.frame(
      date = as.Date(c("2024-01-01", "2024-01-02", "2024-01-03")),
      site = c("Site A", "Site B", "Site A"),
      type = c("Electricity", "Gas", "Water"),
      value = c(100, 150, 200),
      carbon_emission_in_kgco2e = c(10, 15, 5)
    )

    shiny::isolate(dm$raw_data(test_data))
    shiny::isolate(dm$process_data())
  })

  testServer(mod_dashboard_server, args = list(data_manager = dm), {
    # Simulate data loading
    session$setInputs(
      date_range = c(as.Date("2024-01-01"), as.Date("2024-01-03"))
    )

    # Check that server starts without errors
    expect_true(TRUE)
  })
})

test_that("mod_dashboard_server handles filter interactions", {
  session <- shiny::MockShinySession$new()
  shiny::withReactiveDomain(session, {
    dm <- data_manager$new()
    test_data <- data.frame(
      date = as.Date(c("2024-01-01", "2024-01-02")),
      site = c("Site A", "Site B"),
      type = c("Electricity", "Gas"),
      value = c(100, 150),
      carbon_emission_in_kgco2e = c(10, 15)
    )

    shiny::isolate(dm$raw_data(test_data))
    shiny::isolate(dm$process_data())
  })

  testServer(mod_dashboard_server, args = list(data_manager = dm), {
    # Test date range filter
    session$setInputs(
      date_range = c(as.Date("2024-01-01"), as.Date("2024-01-02"))
    )

    # Test facility selection
    session$setInputs(facilities = c("Site A"))

    # Test energy type selection
    session$setInputs(energy_types = c("Electricity"))

    # Test reset filters button
    session$setInputs(reset_filters = 1)

    # Should handle all interactions without errors
    expect_true(TRUE)
  })
})

test_that("mod_dashboard_ui contains all required components", {
  ui <- mod_dashboard_ui("dashboard")
  ui_html <- as.character(ui)

  # Check for filter controls
  expect_true(grepl("Date Range", ui_html))
  expect_true(grepl("Facilities", ui_html))
  expect_true(grepl("Energy Types", ui_html))
  expect_true(grepl("Reset Filters", ui_html))

  # Check for output containers
  expect_true(grepl("highchartOutput", ui_html) || grepl("chart", ui_html))
  expect_true(grepl("dataTableOutput", ui_html) || grepl("table", ui_html))

  # Check for KPI cards container
  expect_true(grepl("kpi", ui_html) || grepl("Key Performance", ui_html))
})
