# Working KPI tests using MockShinySession approach

test_that("data_manager KPI calculations work correctly", {
  session <- shiny::MockShinySession$new()

  shiny::withReactiveDomain(session, {
    dm <- data_manager$new()

    # Create test data
    test_data <- data.frame(
      site = c("Site_A", "Site_A", "Site_B", "Site_B", "Site_C"),
      date = as.Date(c("2025-01-01", "2025-01-02", "2025-01-01", "2025-01-02", "2025-01-01")),
      type = c("Electricity", "Gas", "Electricity", "Water", "Electricity"),
      value = c(1000, 500, 750, 300, 1200),
      carbon_emission_in_kgco2e = c(100, 50, 75, 30, 120)
    )

    # Test total consumption calculation
    total_consumption <- dm$calculate_total_consumption(test_data)
    expect_equal(total_consumption, 3750) # 1000 + 500 + 750 + 300 + 1200

    # Test total emissions calculation
    total_emissions <- dm$calculate_total_emissions(test_data)
    expect_equal(total_emissions, 375) # 100 + 50 + 75 + 30 + 120

    # Test average daily usage calculation
    avg_daily <- dm$calculate_average_daily_usage(test_data)
    # Day 1: 1000 + 750 + 1200 = 2950
    # Day 2: 500 + 300 = 800
    # Average: (2950 + 800) / 2 = 1875
    expect_equal(avg_daily, 1875)
  })
})

test_that("KPI calculations handle empty data correctly", {
  session <- shiny::MockShinySession$new()

  shiny::withReactiveDomain(session, {
    dm <- data_manager$new()
    empty_data <- data.frame()

    # Test with empty data
    expect_equal(dm$calculate_total_consumption(empty_data), 0)
    expect_equal(dm$calculate_total_emissions(empty_data), 0)
    expect_equal(dm$calculate_average_daily_usage(empty_data), 0)
  })
})

test_that("KPI calculations handle missing values correctly", {
  session <- shiny::MockShinySession$new()

  shiny::withReactiveDomain(session, {
    dm <- data_manager$new()

    # Test data with NA values
    test_data_na <- data.frame(
      site = c("Site_A", "Site_B", "Site_C"),
      date = as.Date(c("2025-01-01", "2025-01-01", "2025-01-01")),
      type = c("Electricity", "Gas", "Water"),
      value = c(1000, NA, 500),
      carbon_emission_in_kgco2e = c(100, 50, NA)
    )

    # Test total consumption with NA values
    total_consumption <- dm$calculate_total_consumption(test_data_na)
    expect_equal(total_consumption, 1500) # 1000 + 500, NA ignored

    # Test total emissions with NA values
    total_emissions <- dm$calculate_total_emissions(test_data_na)
    expect_equal(total_emissions, 150) # 100 + 50, NA ignored
  })
})

test_that("data preparation methods work correctly", {
  session <- shiny::MockShinySession$new()

  shiny::withReactiveDomain(session, {
    dm <- data_manager$new()

    test_data <- data.frame(
      site = c("Site_A", "Site_A", "Site_B", "Site_B"),
      date = as.Date(c("2025-01-01", "2025-01-02", "2025-01-01", "2025-01-02")),
      type = c("Electricity", "Gas", "Electricity", "Water"),
      value = c(1000, 500, 750, 300),
      carbon_emission_in_kgco2e = c(100, 50, 75, 30)
    )

    # Test time series data preparation
    time_series_data <- dm$prepare_time_series_data(test_data)
    expect_equal(nrow(time_series_data), 2) # Two unique dates
    expect_equal(time_series_data$total_value[1], 1750) # Day 1: 1000 + 750
    expect_equal(time_series_data$total_value[2], 800) # Day 2: 500 + 300

    # Test facility data preparation
    facility_data <- dm$prepare_facility_data(test_data)
    expect_equal(nrow(facility_data), 2) # Two unique sites
    expect_true(facility_data$total_value[1] >= facility_data$total_value[2]) # Should be sorted descending

    # Test summary data preparation
    summary_data <- dm$prepare_summary_data(test_data)
    expect_equal(nrow(summary_data), 4) # Four unique site-type combinations
    expect_true(all(c("site", "type", "total_consumption", "total_emissions",
                      "avg_consumption", "records") %in% names(summary_data)))
  })
})

test_that("data manager format_number method works correctly", {
  session <- shiny::MockShinySession$new()

  shiny::withReactiveDomain(session, {
    dm <- data_manager$new()

    # Test normal number formatting
    expect_equal(dm$format_number(1234), "1,234")
    expect_equal(dm$format_number(1234, "units"), "1,234 units")

    # Test with decimal numbers (should be rounded)
    expect_equal(dm$format_number(1234.56), "1,235")

    # Test with zero
    expect_equal(dm$format_number(0), "0")

    # Test with NA
    expect_equal(dm$format_number(NA), "--")

    # Test with NULL
    expect_equal(dm$format_number(NULL), "--")

    # Test with large numbers
    expect_equal(dm$format_number(1234567), "1,234,567")
  })
})
