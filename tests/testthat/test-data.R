test_that("sample_data exists and has correct structure", {
  expect_true(exists("sample_data"))
  expect_s3_class(sample_data, "data.frame")
})

test_that("sample_data has expected columns", {
  expected_cols <- c("id", "site", "date", "type", "value", "carbon_emission_in_kgco2e")
  expect_true(all(expected_cols %in% names(sample_data)))
  expect_equal(length(names(sample_data)), 6)
})

test_that("sample_data has correct column types", {
  expect_type(sample_data$id, "integer")
  expect_type(sample_data$site, "character")
  expect_type(sample_data$date, "character")
  expect_type(sample_data$type, "character")
  # Values can be integer or double - both are valid numeric types
  expect_true(is.numeric(sample_data$value))
  expect_true(is.numeric(sample_data$carbon_emission_in_kgco2e))
})

test_that("sample_data contains valid energy types", {
  # Check that type column contains only character values and has some data
  expect_type(sample_data$type, "character")
  expect_true(length(unique(sample_data$type)) > 0)
  # Verify that all types are valid strings (not empty)
  expect_true(all(nchar(sample_data$type) > 0))
})

test_that("sample_data has reasonable data ranges", {
  expect_true(all(sample_data$value >= 0))
  expect_true(all(sample_data$carbon_emission_in_kgco2e >= 0))
  expect_true(nrow(sample_data) > 0)
})