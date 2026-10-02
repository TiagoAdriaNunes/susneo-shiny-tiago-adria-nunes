test_that("EnergyDataManager loads the packaged sample data by default", {
  dm <- EnergyDataManager$new()

  expect_s3_class(dm, "EnergyDataManager")
  expect_true(dm$has_data())
  expect_equal(nrow(dm$data), nrow(sample_data))
  expect_s3_class(dm$data$date, "Date")
})

test_that("EnergyDataManager cleans the data it is given", {
  raw <- data.frame(
    site = c("Site_A", "Site_A", "Site_B"),
    date = c("01-02-2025", "not a date", "2025-02-03"),
    type = c("Electricity", "Gas", "Water"),
    value = c("100", "200", "abc"),
    carbon_emission_in_kgco2e = c(10, 20, 30)
  )

  dm <- EnergyDataManager$new(raw)

  # Only the first row has a readable date and a numeric value
  expect_equal(nrow(dm$data), 1)
  expect_equal(dm$data$date, as.Date("2025-02-01"))
  expect_equal(dm$data$value, 100)
})

test_that("EnergyDataManager lists facilities, energy types and the date range", {
  dm <- EnergyDataManager$new(make_energy_data())

  expect_setequal(dm$facilities(), c("Site_A", "Site_B", "Site_C"))
  expect_setequal(dm$energy_types(), c("Electricity", "Gas", "Water"))
  expect_equal(dm$date_range(), as.Date(c("2025-01-01", "2025-01-02")))
})

test_that("EnergyDataManager$filter applies each filter and keeps everything without filters", {
  dm <- EnergyDataManager$new(make_energy_data())

  expect_equal(nrow(dm$filter()), 5)
  expect_equal(unique(dm$filter(facilities = "Site_A")$site), "Site_A")
  expect_equal(dm$filter(energy_types = "Gas")$value, 500)
  expect_equal(nrow(dm$filter(date_range = as.Date(c("2025-01-02", "2025-01-02")))), 2)
  expect_equal(nrow(dm$filter(facilities = "Site_A", energy_types = "Water")), 0)
})

test_that("EnergyDataManager$filter does not change the stored data", {
  dm <- EnergyDataManager$new(make_energy_data())

  dm$filter(facilities = "Site_A")

  expect_equal(nrow(dm$data), 5)
})

test_that("EnergyDataManager data is read-only", {
  dm <- EnergyDataManager$new(make_energy_data())

  expect_error(dm$data <- data.frame(), "read-only")
  expect_equal(nrow(dm$data), 5)
})

test_that("EnergyDataManager handles empty data", {
  dm <- EnergyDataManager$new(data.frame())

  expect_false(dm$has_data())
  expect_equal(dm$facilities(), character(0))
  expect_equal(dm$energy_types(), character(0))
  expect_equal(dm$date_range(), c(Sys.Date(), Sys.Date()))
  expect_equal(nrow(dm$filter(facilities = "Site_A")), 0)
})

test_that("EnergyDataManager rejects input that is not a data frame", {
  expect_error(EnergyDataManager$new("not a data frame"))
  expect_error(EnergyDataManager$new(NULL))
})
