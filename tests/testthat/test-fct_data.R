# Dates -----------------------------------------------------------------------

test_that("parse_energy_dates handles mixed formats and reads ambiguous dates day first", {
  parsed <- parse_energy_dates(
    c("01-08-2025", "2025-08-10", "15-08-2025", "08-13-2025", "8/9/2025", "not a date")
  )

  expect_equal(
    parsed,
    as.Date(c("2025-08-01", "2025-08-10", "2025-08-15", "2025-08-13", "2025-09-08", NA))
  )
})

# Cleaning --------------------------------------------------------------------

test_that("process_energy_data parses dates and drops rows it cannot use", {
  raw <- data.frame(
    site = c("A", "B", "C", "D", "E", "F"),
    date = c("01-08-2025", "8/9/2025", "2025-08-10", "15-08-2025", "garbage", "20-08-2025"),
    type = "Gas",
    value = c("1000", "500", "750", "300", "10", "abc"),
    carbon_emission_in_kgco2e = c("100", "x", "75", "30", "1", "2")
  )

  result <- process_energy_data(raw)

  expect_s3_class(result$date, "Date")
  # "garbage" has no valid date and "abc" is not a number
  expect_equal(result$site, c("A", "B", "C", "D"))
  expect_equal(result$value, c(1000, 500, 750, 300))
  # An unreadable emission becomes 0 instead of dropping the row
  expect_equal(result$carbon_emission_in_kgco2e, c(100, 0, 75, 30))
  expect_equal(rownames(result), as.character(1:4))
})

test_that("process_energy_data works without an emissions column", {
  raw <- data.frame(site = "A", date = "01-08-2025", type = "Gas", value = 5)
  result <- process_energy_data(raw)

  expect_equal(nrow(result), 1)
  expect_false("carbon_emission_in_kgco2e" %in% names(result))
})

test_that("process_energy_data handles empty input", {
  expect_equal(nrow(process_energy_data(data.frame())), 0)
})

# Loading ---------------------------------------------------------------------

test_that("load_sample_data loads the dataset from the data folder", {
  data <- load_sample_data()

  expect_equal(nrow(data), nrow(sample_data))
  expect_s3_class(data$date, "Date")
  expect_false(anyNA(data$date))
  expect_true(is.numeric(data$value))
  expect_setequal(
    get_energy_types(data),
    c("Electricity", "Fuel", "Gas", "Waste", "Water")
  )
})

# Lookups and filtering -------------------------------------------------------

test_that("lookup helpers return the unique values in the data", {
  data <- make_energy_data()

  expect_equal(sort(get_facilities(data)), c("Site_A", "Site_B", "Site_C"))
  expect_equal(sort(get_energy_types(data)), c("Electricity", "Gas", "Water"))
  expect_equal(get_date_range(data), as.Date(c("2025-01-01", "2025-01-02")))
})

test_that("lookup helpers handle empty data", {
  expect_identical(get_facilities(data.frame()), character(0))
  expect_identical(get_energy_types(data.frame()), character(0))
  expect_identical(get_facilities(make_energy_data()[0, ]), character(0))
  expect_equal(get_date_range(data.frame()), c(Sys.Date(), Sys.Date()))
})

test_that("filter_energy_data applies each filter and their combination", {
  data <- make_energy_data()

  # Date range is inclusive at both ends
  by_date <- filter_energy_data(data, date_range = as.Date(c("2025-01-02", "2025-01-02")))
  expect_equal(nrow(by_date), 2)

  by_site <- filter_energy_data(data, facilities = "Site_A")
  expect_equal(unique(by_site$site), "Site_A")

  by_type <- filter_energy_data(data, energy_types = c("Gas", "Water"))
  expect_equal(nrow(by_type), 2)

  combined <- filter_energy_data(
    data,
    date_range = as.Date(c("2025-01-01", "2025-01-01")),
    facilities = c("Site_A", "Site_B"),
    energy_types = "Electricity"
  )
  expect_equal(combined$value, c(1000, 750))
})

test_that("filter_energy_data keeps everything when no filter is given", {
  data <- make_energy_data()

  expect_equal(filter_energy_data(data), data)
  expect_equal(filter_energy_data(data, facilities = character(0), energy_types = NULL), data)
})

test_that("filter_energy_data handles empty data", {
  expect_equal(nrow(filter_energy_data(data.frame(), facilities = "A")), 0)
})

test_that("mixed_units_message only warns when several energy types are present", {
  expect_null(mixed_units_message(make_single_type_data()))
  expect_null(mixed_units_message(data.frame()))
  expect_match(mixed_units_message(make_energy_data()), "combines 3 energy types")
})

# Calculations ----------------------------------------------------------------

test_that("KPI calculations are correct", {
  data <- make_energy_data()

  expect_equal(calculate_total_consumption(data), 3750)
  expect_equal(calculate_total_emissions(data), 375)
  # Day 1: 1000 + 750 + 1200 = 2950, day 2: 500 + 300 = 800
  expect_equal(calculate_average_daily_usage(data), 1875)
})

test_that("KPI calculations return zero for empty or incomplete data", {
  expect_equal(calculate_total_consumption(data.frame()), 0)
  expect_equal(calculate_total_emissions(data.frame()), 0)
  expect_equal(calculate_average_daily_usage(data.frame()), 0)

  no_emissions <- make_energy_data()[, c("site", "date", "type", "value")]
  expect_equal(calculate_total_emissions(no_emissions), 0)
})

test_that("KPI calculations ignore missing values", {
  data <- data.frame(
    site = c("A", "B", "C"),
    date = as.Date("2025-01-01"),
    type = c("Electricity", "Gas", "Water"),
    value = c(1000, NA, 500),
    carbon_emission_in_kgco2e = c(100, 50, NA)
  )

  expect_equal(calculate_total_consumption(data), 1500)
  expect_equal(calculate_total_emissions(data), 150)
})

# Chart and table preparation -------------------------------------------------

test_that("prepare_time_series_data totals each day in date order", {
  result <- prepare_time_series_data(make_energy_data())

  expect_equal(result$date, as.Date(c("2025-01-01", "2025-01-02")))
  expect_equal(result$total_value, c(2950, 800))
})

test_that("prepare_facility_data totals each site, largest first", {
  result <- prepare_facility_data(make_energy_data())

  expect_equal(result$site, c("Site_A", "Site_C", "Site_B"))
  expect_equal(result$total_value, c(1500, 1200, 1050))
})

test_that("prepare_summary_data summarises each site and type", {
  result <- prepare_summary_data(make_energy_data())

  expect_equal(nrow(result), 5)
  expect_named(
    result,
    c("site", "type", "total_consumption", "total_emissions", "avg_consumption", "records")
  )
  expect_equal(result$total_consumption, sort(result$total_consumption, decreasing = TRUE))
})

test_that("prepare_summary_data works without an emissions column", {
  data <- make_energy_data()[, c("site", "date", "type", "value")]
  result <- prepare_summary_data(data)

  expect_equal(nrow(result), 5)
  expect_equal(result$total_emissions, rep(0, 5))
})

test_that("prepare functions return empty, correctly shaped results for empty data", {
  time_series <- prepare_time_series_data(data.frame())
  expect_equal(nrow(time_series), 0)
  expect_named(time_series, c("date", "total_value"))

  facilities <- prepare_facility_data(data.frame())
  expect_equal(nrow(facilities), 0)
  expect_named(facilities, c("site", "total_value"))

  expect_equal(nrow(prepare_summary_data(data.frame())), 0)
})
