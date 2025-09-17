# Working data manager tests using MockShinySession approach

test_that("data_manager class exists and can be instantiated", {
  expect_true(exists("data_manager"))
  expect_true(R6::is.R6Class(data_manager))
})

test_that("data_manager initialization works correctly", {
  session <- shiny::MockShinySession$new()

  shiny::withReactiveDomain(session, {
    dm <- data_manager$new()

    # Test that reactive values are initialized
    expect_true(shiny::is.reactive(dm$raw_data))
    expect_true(shiny::is.reactive(dm$processed_data))

    # Test initial state using isolate()
    expect_equal(nrow(shiny::isolate(dm$raw_data())), 0)
    expect_equal(nrow(shiny::isolate(dm$processed_data())), 0)
    expect_false(shiny::isolate(dm$is_data_loaded()))
  })
})

test_that("data validation works correctly", {
  session <- shiny::MockShinySession$new()

  shiny::withReactiveDomain(session, {
    dm <- data_manager$new()

    # Valid data
    valid_data <- data.frame(
      site = c("Site_A", "Site_B"),
      date = c("01-01-2025", "02-01-2025"),
      type = c("Electricity", "Gas"),
      value = c(1000, 500)
    )
    expect_true(dm$validate_data(valid_data))

    # Invalid data
    invalid_data <- data.frame(
      site = c("Site_A", "Site_B"),
      date = c("01-01-2025", "02-01-2025"),
      type = c("Electricity", "Gas")
    )
    expect_false(dm$validate_data(invalid_data))
  })
})

test_that("data processing with mixed date formats", {
  session <- shiny::MockShinySession$new()

  shiny::withReactiveDomain(session, {
    dm <- data_manager$new()

    # Test data with mixed date formats
    mixed_date_data <- data.frame(
      site = c("Site_A", "Site_B", "Site_C", "Site_D"),
      date = c("01-08-2025", "8/9/2025", "2025-08-10", "15-08-2025"),
      type = c("Electricity", "Gas", "Water", "Fuel"),
      value = c(1000, 500, 750, 300),
      carbon_emission_in_kgco2e = c(100, 50, 75, 30)
    )

    shiny::isolate(dm$raw_data(mixed_date_data))
    shiny::isolate(dm$process_data())

    processed_data <- shiny::isolate(dm$processed_data())

    # Check that dates were parsed correctly
    expect_true(all(!is.na(processed_data$date)))
    expect_true(inherits(processed_data$date, "Date"))
    expect_equal(nrow(processed_data), 4)
  })
})

test_that("data access methods work correctly", {
  session <- shiny::MockShinySession$new()

  shiny::withReactiveDomain(session, {
    dm <- data_manager$new()

    test_data <- data.frame(
      site = c("Site_A", "Site_B", "Site_A"),
      date = c("01-08-2025", "02-08-2025", "03-08-2025"),
      type = c("Electricity", "Gas", "Water"),
      value = c(1000, 500, 750),
      carbon_emission_in_kgco2e = c(100, 50, 75)
    )

    shiny::isolate(dm$raw_data(test_data))
    shiny::isolate(dm$process_data())

    # Test facility access
    facilities <- shiny::isolate(dm$get_facilities())
    expect_equal(sort(facilities), c("Site_A", "Site_B"))

    # Test energy types access
    energy_types <- shiny::isolate(dm$get_energy_types())
    expect_equal(sort(energy_types), c("Electricity", "Gas", "Water"))

    # Test is_data_loaded
    expect_true(shiny::isolate(dm$is_data_loaded()))
  })
})